/**
 * Copyright (c) 2017 Razeware LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
 * distribute, sublicense, create a derivative work, and/or sell copies of the
 * Software in any work that is designed, intended, or marketed for pedagogical or
 * instructional purposes related to programming, coding, application development,
 * or information technology.  Permission for such use, copying, modification,
 * merger, publication, distribution, sublicensing, creation of derivative works,
 * or sale is expressly withheld.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import UIKit

class ArticleListController: UITableViewController {
  
  var source: Source?
  private var token: NSKeyValueObservation?
  private let formatter = DateFormatter()
    private var task: URLSessionDataTask?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    formatter.dateFormat = "MMM d, h:mm a"
    tableView.prefetchDataSource = self
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    tableView.estimatedRowHeight = 450
    tableView.rowHeight = UITableViewAutomaticDimension
    
    Utils.showDialog(in: self)
    guard let source = source else { return }
    token = NewsAPI.service.observe(\.articles) { _, _ in
      DispatchQueue.main.async {
        self.tableView.reloadData()
        Utils.dismissDialog(in: self)
      }
    }
    NewsAPI.service.fetchArticles(for: source)
  }
  
  override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)
    token?.invalidate()
    NewsAPI.service.resetArticles()
  }
}

// MARK: UITableViewDataSource

extension ArticleListController {
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return NewsAPI.service.articles.count
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "ArticleCell", for: indexPath) as! ArticleCell
    
    if let imageView = cell.viewWithTag(100) as? UIImageView {
        if let image = NewsAPI.service.articles[indexPath.row].image {
            imageView.image = image
        } else {
            imageView.image = nil
            self.downloadBanner(forItemAtIndex: indexPath.row)
        }
    }
    
    cell.render(article: NewsAPI.service.articles[indexPath.row], using: formatter)
    
    return cell
  }
    
   override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    if let url = URL(string: NewsAPI.service.articles[indexPath.row].sourceURL.absoluteString) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
}

extension ArticleListController{
    
    private func downloadBanner(forItemAtIndex index: Int) {
        if let imageUrl = NewsAPI.service.articles[index].imageURL{
            let task = URLSession.shared.dataTask(with: imageUrl) { data, response, error in
                guard let data = data, error == nil else { return }
                DispatchQueue.main.async {
                     let indexPath = IndexPath(row: index, section: 0)
                     if self.tableView.indexPathsForVisibleRows?.contains(indexPath) ?? false {
                        NewsAPI.service.articles[index].image = UIImage(data: data)
                    }
                }
            }
            task.resume()
            self.task = task
        }
    }
    
    private func cancelDownloadBanner(forItemAtIndex index: Int){
        guard let task = task else { return }
        task.cancel()
    }
}

extension ArticleListController: UITableViewDataSourcePrefetching {
    
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach { self.downloadBanner(forItemAtIndex: $0.row) }
    }
    
    func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach { self.cancelDownloadBanner(forItemAtIndex: $0.row) }
    }
}

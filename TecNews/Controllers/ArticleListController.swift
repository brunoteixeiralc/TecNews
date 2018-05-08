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
import RealmSwift
import SafariServices

class ArticleListController: UITableViewController {
  
  var articles:Results<RealmArticle>?
  var source: Source?
  var dismissSF:Bool = false
  private var token: NSKeyValueObservation?
  private let formatter = DateFormatter()
  private var task: URLSessionDataTask?
  private var searchController = UISearchController(searchResultsController: nil)
  private var baseArticles:[Article] = NewsAPI.service.articles
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    if UIApplication.shared.keyWindow?.traitCollection.forceTouchCapability == UIForceTouchCapability.available
    {registerForPreviewing(with: self, sourceView: view)}
    
    formatter.dateFormat = "MMM d, h:mm a"
    tableView.prefetchDataSource = self
    
    tableView.estimatedRowHeight = 450
    tableView.rowHeight = UITableViewAutomaticDimension
    
    refreshControl = UIRefreshControl()
    refreshControl?.tintColor = UIColor.white
    refreshControl?.addTarget(self, action: #selector(searchArticleRC), for: .valueChanged)
    
    searchController.searchBar.autocapitalizationType = .none
    searchController.delegate = self
    searchController.searchResultsUpdater = self
    searchController.dimsBackgroundDuringPresentation = false
    searchController.searchBar.delegate = self
    definesPresentationContext = true
    
    navigationItem.searchController = searchController
    navigationItem.hidesSearchBarWhenScrolling = true
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
    if !dismissSF{
        showDialog(in: self)
        guard let source = source else { return }
        token = NewsAPI.service.observe(\.articles) { _, _ in
            DispatchQueue.main.async {
                self.tableView.reloadData()
                dismissDialog(in: self)
            }
        }
        NewsAPI.service.fetchArticles(for: source)
    }
  }
  
  override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)
    token?.invalidate()
    
  }
    
   @objc func searchArticleRC(){
     token = NewsAPI.service.observe(\.articles) { _, _ in
        DispatchQueue.main.async {
            self.tableView.reloadData()
            self.refreshControl?.endRefreshing()
        }
     }
     NewsAPI.service.fetchArticles(for: source!)
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
            imageView.image = UIImage(named:"image")
            self.downloadBanner(forItemAtIndex: indexPath.row)
        }
    }
    
    cell.render(article: NewsAPI.service.articles[indexPath.row], using: formatter)
    return cell
  }
    
   override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    if let url = URL(string: NewsAPI.service.articles[indexPath.row].sourceURL.absoluteString) {
            var svc: SFSafariViewController?
            if #available(iOS 11.0, *) {
                svc = SFSafariViewController(url: url)
            } else {
                svc = SFSafariViewController(url: url, entersReaderIfAvailable: true)
            }
        svc?.delegate = self
        self.present(svc!, animated: true, completion: nil)
        }
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let article = NewsAPI.service.articles[indexPath.row]
        
        let shareAction = UIContextualAction(style: .normal, title: "") { [weak self] (action, view, completionHandler) in
            guard let `self` = self else{
                completionHandler(false)
                return
            }
            
            let activityViewController = UIActivityViewController(activityItems: [URL(string: article.sourceURL.absoluteString)!], applicationActivities: nil)
            self.present(activityViewController, animated: true, completion: {})
            
            completionHandler(true)
        }
        
        let favorite = UIContextualAction(style: .normal, title: "") { [weak self] (action, view, completionHandler) in
            guard self != nil else{
                completionHandler(false)
                return
            }
            
            let articleFav = RealmArticle(value: ["author":article.author,
                                                  "title":article.title,
                                                  "snippet":article.snippet,
                                                  "sourceURL":article.sourceURL.absoluteString,
                                                  "imageURL":article.imageURL,
                                                  "published":article.published])
            let realm = try! Realm()
            try! realm.write {
                realm.add(articleFav)
                
                (self?.navigationController?.childViewControllers[1] as! TabBarController).badgeBookmark()

                let hudView = HudView.hud(inView: (self?.navigationController?.view)!, animated: true)
                hudView.text = NSLocalizedString("add_bookmark", comment: "Localized kind: add_bookmark")
                let delayInSeconds = 1.0
                DispatchQueue.main.asyncAfter(deadline: .now() + delayInSeconds) {
                    hudView.hide()
                }
            }
            
            completionHandler(true)
        }
        
       shareAction.backgroundColor = #colorLiteral(red: 0.1725490196, green: 0.2431372549, blue: 0.3137254902, alpha: 1)
       shareAction.image = UIImage(named: "share")
       favorite.backgroundColor = UIColor.lightGray
       favorite.image = UIImage(named: "favorite")
       
       let configuration = UISwipeActionsConfiguration(actions: [favorite,shareAction])
       return configuration
        
    }
    
}

extension ArticleListController{
    
    private func downloadBanner(forItemAtIndex index: Int) {
        if let imageUrl = NewsAPI.service.articles[index].imageURL{
            if (URLValid(urlString: imageUrl)){
                let task = URLSession.shared.dataTask(with: URL(string:imageUrl)!) { data, response, error in
                    guard let data = data, error == nil else { return }
                    DispatchQueue.main.async {
                        let indexPath = IndexPath(row: index, section: 0)
                        if self.tableView.indexPathsForVisibleRows?.contains(indexPath) ?? false {
                            if NewsAPI.service.articles.count > 0{
                                NewsAPI.service.articles[index].image = UIImage(data: data)
                            }
                            
                        }
                    }
                }
                task.resume()
                self.task = task
            }
        }
    }
    
    private func cancelDownloadBanner(forItemAtIndex index: Int){
        guard let task = task else { return }
        task.cancel()
    }
}

extension ArticleListController: UISearchResultsUpdating{
    
    func filterContent(searchText:String){
        findMatches(searchText)
        tableView.reloadData()
    }
    
    func findMatches(_ searchText:String){
         NewsAPI.service.fetchArticles(for: source!, with: searchText)
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        //filterContent(searchText: searchController.searchBar.text!)
    }
    
}

extension ArticleListController: UISearchBarDelegate{
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        filterContent(searchText: searchBar.text!)
        searchController.searchBar.showsCancelButton = false
    }
}

extension ArticleListController : UISearchControllerDelegate{
    
    func willDismissSearchController(_ searchController: UISearchController) {
        filterContent(searchText: "")
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

extension ArticleListController: SFSafariViewControllerDelegate{
    
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        dismissSF = true
        controller.dismiss(animated: true, completion: nil)
    }
}

extension ArticleListController: UIViewControllerPreviewingDelegate{
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        guard let indexPath = tableView?.indexPathForRow(at: location) else { return nil }
        
        var svc: SFSafariViewController?
        if let url = URL(string: NewsAPI.service.articles[indexPath.row].sourceURL.absoluteString) {
            if #available(iOS 11.0, *) {
                svc = SFSafariViewController(url: url)
            } else {
                svc = SFSafariViewController(url: url, entersReaderIfAvailable: true)
            }
        }
       return svc
    }
    
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        navigationController?.pushViewController(viewControllerToCommit, animated: true)
    }
}

//
//  BookmarkListController.swift
//  TecNews
//
//  Created by Bruno Lemgruber on 11/04/2018.
//  Copyright © 2018 Razeware LLC. All rights reserved.
//

import UIKit
import Lottie

class BookmarkListController: UIViewController {

    @IBOutlet weak var tableview:UITableView!
    
    private let formatter = DateFormatter()
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        tableview.isHidden = true
        tabBarController?.title = "Let's read now. Choose an article."
        emptyBookmark()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        formatter.dateFormat = "MMM d, h:mm a"
        
    }
    
    func emptyBookmark(){
        
        let animationView = LOTAnimationView(name: "empty")
        animationView.contentMode = .scaleAspectFill
        animationView.frame = CGRect(x: self.view.frame.maxX, y: self.view.frame.maxY, width: self.view.frame.width, height: 350)
        animationView.center =  self.view.center
        animationView.loopAnimation = true
        animationView.play()
        view.addSubview(animationView)
    }
}

// MARK: UITableViewDataSource

extension BookmarkListController: UITableViewDelegate,UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ArticleCell", for: indexPath) as! ArticleCell

        //cell.render(article: NewsAPI.service.articles[indexPath.row], using: formatter)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if let url = URL(string: NewsAPI.service.articles[indexPath.row].sourceURL.absoluteString) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
}

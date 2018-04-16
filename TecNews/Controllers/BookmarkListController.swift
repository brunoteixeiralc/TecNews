//
//  BookmarkListController.swift
//  TecNews
//
//  Created by Bruno Lemgruber on 11/04/2018.
//  Copyright © 2018 Razeware LLC. All rights reserved.
//

import UIKit
import Lottie
import RealmSwift

class BookmarkListController: UIViewController {

    @IBOutlet weak var tableview:UITableView!
    
    private let formatter = DateFormatter()
    let animationView = LOTAnimationView(name: "empty")
    var articles:Results<RealmArticle>?
    let realm = try! Realm()
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        searchArticles()
        tabBarController?.title = "Let's read now. Choose an article."
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        formatter.dateFormat = "MMM d, h:mm a"
        
    }
    
    func emptyBookmark(){
    
        animationView.removeFromSuperview()
        animationView.contentMode = .scaleAspectFill
        animationView.frame = CGRect(x: self.view.frame.maxX, y: self.view.frame.maxY, width: self.view.frame.width, height: 350)
        animationView.center =  self.view.center
        animationView.loopAnimation = true
        animationView.play()
        view.addSubview(animationView)
    }
    
    func deleteArticleRealm(article:RealmArticle){
        try! realm.write {
            realm.delete(article)
            tableview.reloadData()
        }
    }
    
    func searchArticles(){
        articles = realm.objects(RealmArticle.self)
        if let articlesRealm = articles{
            if articlesRealm.count > 0{
                tableview.isHidden = false
                tableview.reloadData()
                animationView.removeFromSuperview()
            }else{
                self.tableview.isHidden = true
                emptyBookmark()
            }
        }else{
            self.tableview.isHidden = true
            emptyBookmark()
        }
    }
}

// MARK: UITableViewDataSource

extension BookmarkListController: UITableViewDelegate,UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let articleRealm = articles{
            return articleRealm.count
        }else{
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ArticleCell", for: indexPath) as! ArticleCell
        
        cell.render(article: articles![indexPath.row], using: formatter)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if let url = URL(string: articles![indexPath.row].sourceURL!) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCellEditingStyle.delete{
            deleteArticleRealm(article: articles![indexPath.row])
        }
    }
}

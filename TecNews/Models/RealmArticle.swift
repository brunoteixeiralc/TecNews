//
//  RealmArticle.swift
//  TecNews
//
//  Created by Bruno Lemgruber on 16/04/2018.
//  Copyright © 2018 Razeware LLC. All rights reserved.
//

import RealmSwift

class RealmArticle: Object{
    
    @objc dynamic var author: String? = nil
    @objc dynamic var title: String? = nil
    @objc dynamic var snippet: String? = nil
    @objc dynamic var sourceURL: String? = nil
    @objc dynamic var imageURL: String? = nil
    @objc dynamic var published: Date? = nil
    
    var image: UIImage? = nil
}

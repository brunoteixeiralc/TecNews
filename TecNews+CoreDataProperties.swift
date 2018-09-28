//
//  TecNews+CoreDataProperties.swift
//  
//
//  Created by Bruno Corrêa on 28/09/18.
//
//

import Foundation
import CoreData


extension TecNews {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TecNews> {
        return NSFetchRequest<TecNews>(entityName: "TecNews")
    }

    @NSManaged public var author: String?
    @NSManaged public var title: String?
    @NSManaged public var snippet: String?
    @NSManaged public var sourceURL: String?
    @NSManaged public var imageURL: String?
    @NSManaged public var published: NSDate?

}

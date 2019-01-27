//
//  RecommendBookList+CoreDataProperties.swift
//  honhaSukidesuka
//
//  Created by oyuka on 2018/09/16.
//  Copyright © 2018年 yuka. All rights reserved.
//
//

import Foundation
import CoreData


extension RecommendBookList {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<RecommendBookList> {
        return NSFetchRequest<RecommendBookList>(entityName: "RecommendBookList")
    }

    @NSManaged public var author: String?
    @NSManaged public var bookid: Int16
    @NSManaged public var createDate: NSDate?
    @NSManaged public var linkURL: String?
    @NSManaged public var recommendation: String?
    @NSManaged public var title: String?
    @NSManaged public var type: Int16

}

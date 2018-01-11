//
//  RecommendBookList+CoreDataProperties.swift
//  honhaSukidesuka
//
//  Created by yuka on 2018/01/11.
//  Copyright © 2018年 yuka. All rights reserved.
//
//

import Foundation
import CoreData


extension RecommendBookList {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<RecommendBookList> {
        return NSFetchRequest<RecommendBookList>(entityName: "RecommendBookList")
    }

    @NSManaged public var bookid: Int16
    @NSManaged public var title: String?
    @NSManaged public var author: String?
    @NSManaged public var recommendation: String?
    @NSManaged public var createDate: NSDate?
    @NSManaged public var linkURL: String?

}

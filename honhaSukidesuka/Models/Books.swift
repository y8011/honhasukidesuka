//
//  Books.swift
//  honhaSukidesuka
//
//  Created by oyuka on 2019/01/20.
//  Copyright © 2019 yuka. All rights reserved.
//

import Foundation

struct BookAPIResponse: Decodable{
    let items : [Book]
}

class Book: NSObject, Decodable {
    let kind: String
    let volumeInfo: Info?
}

struct Info: Decodable {
    let title: String
    let authors : [String]?
    let imageLinks: ImageLinks?
    let industryIdentifiers: [ISDN]?
    let publishedDate: String?
    let publisher: String?
}

struct ImageLinks : Decodable {
    let thumbnail: String
}

struct ISDN: Decodable {
    let identifier: String
    let type: String
}

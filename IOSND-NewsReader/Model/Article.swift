//
//  Article.swift
//  IODND-NewsReader
//
//  Created by Leandro Alves Santos on 18/08/18.
//  Copyright © 2018 Leandro Alves Santos. All rights reserved.
//

import UIKit

class Articles {
    var articlesList: [Articles]?
    static var selectedArticle: Int?
    static var sharedArticles = [Article]()
}

class Article: NSObject {
    
    var descript: String?
    var title: String?
    var url: String?
    var urlToImage: String?

}

//
//  NewsFeedModel.swift
//  NewsReader
//

import Foundation

struct NewsResponse: Decodable {
    var articles: [Article]?
    var status: String?
    var totalResults: Int?
}

struct Article: Decodable {
    var source: ArticleSource
    var author, title, description, url, urlToImage, publishedAt: String?
}

struct ArticleSource: Decodable {
    var   id, name: String?
}

//
//  Model.swift
//  FetchResultController
//
//  Created by Shalopay on 06.01.2023.
//

/*
 {
 "categories":[],
 "created_at":"2020-01-05 13:42:19.324003",
 "icon_url":"https://assets.chucknorris.host/img/avatar/chuck-norris.png",
 "id":"TkS7YJmNQ9ScqWXh0KaUNw",
 "updated_at":"2020-01-05 13:42:19.324003",
 "url":"https://api.chucknorris.io/jokes/TkS7YJmNQ9ScqWXh0KaUNw",
 "value":"Chuck Norris rammed a gold watch up Christopher Walken's ass."
 }
 */

import Foundation
struct JokeCodable: Codable {
    let categories: [String]
    let id: String
    let value: String
}
enum RequestJokes: CustomStringConvertible {
    case random
    case categoryName
    var description: String {
        switch self {
        case .random:
            return "https://api.chucknorris.io/jokes/random"
        case .categoryName:
            return "https://api.chucknorris.io/jokes/random?category="
        }
    }
}



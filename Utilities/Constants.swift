//
//  Constants.swift
//  Recipe
//
//  Created by gu xu on 4/29/25.
//

import Foundation

struct API {
    static let baseURL = "http://localhost:5656/api/recipe"
    
    static var randomURL: String {
        return "\(baseURL)/random"
    }

    static func searchURL(for keyword: String) -> String {
        return "\(baseURL)/search?q=\(keyword)"
    }
}

//
//  Constants.swift
//  Recipe
//
//  Created by gu xu on 4/29/25.
//

struct API {
//    static let baseURL = "http://8.153.165.146:5656/api"
    static let baseURL = "http://localhost:5656/api"
    
    static var randomURL: String {
        return "\(baseURL)/recipe/random"
    }

    static func searchURL(for keyword: String) -> String {
        return "\(baseURL)/recipe/search?q=\(keyword)"
    }
    
    static func detailURL(for recipeId: Int) -> String {
        return "\(baseURL)/recipe/\(recipeId)"
    }
    
    static var registerURL: String {
            return "\(baseURL)/user/register"
        }

    static var loginURL: String {
        return "\(baseURL)/user/login"
    }
    
    static var uploadImageURL: String {
            return "\(baseURL)/recipe/upload"
        }

    static var createRecipeURL: String {
        return "\(baseURL)/recipe/create"
    }
}

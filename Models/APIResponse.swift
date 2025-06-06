//
//  APIResponse.swift
//  Recipe
//
//  Created by gu xu on 4/28/25.
//

import Foundation

struct APIResponse: Decodable {
    let statusCode: Int
    let statusMessage: String
    let data: [Recipe]
}

struct APIResponseWithUser: Decodable {
    let statusCode: Int
    let statusMessage: String
    let data: User
}

struct RecipeDetailResponse: Decodable {
    let statusCode: Int
    let statusMessage: String
    let data: RecipeDetail
}

struct UploadResponse: Codable {
    struct UploadData: Codable {
        let url: String
    }
    let data: UploadData
    let statusCode: Int
    let statusMessage: String
}

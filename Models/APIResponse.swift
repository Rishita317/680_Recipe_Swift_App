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

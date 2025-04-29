//
//  Recipe.swift
//  Recipe
//
//  Created by gu xu on 4/28/25.
//

import Foundation

struct Recipe: Decodable {
    let recipeId: Int
    let recipeName: String
    let category: String
    let rating: String
    let recipePicture: String
    let createTime: String
    let creatorId: Int
    let modifyTime: String
    let postTime: String
    let recipeType: Int
    let status: Int
    
    var description: String {
        "Rating: \(rating)"
    }
}


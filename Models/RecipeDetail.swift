//
//  RecipeDetail.swift
//  Recipe
//
//  Created by gu xu on 4/29/25.
//

import Foundation

struct RecipeDetail: Decodable {
    let recipeId: Int
    let recipeName: String
    let category: String
    let rating: Double
    let recipePicture: String
    let createTime: String
    let creatorId: Int
    let modifyTime: String
    let postTime: String?
    let recipeType: Int
    let status: Int
    let description: String?
    let cookingTime: String?
    let difficulty: Int?
    let steps: [RecipeStep]?
    let ingredients: [Ingredient]?
    let reviews: [Review]?
}

struct Ingredient: Decodable {
    let ingredientId: Int
    let ingredientName: String
    let amount: String
    let category: Int
    let createTime: String
    let modifyTime: String
    let nutrition: String?
}

struct Review: Decodable {
    let reviewId: Int
    let userId: Int
    let userName: String
    let rating: Int
    let comment: String
    let createTime: String
    let modifyTime: String
    let status: Int
}

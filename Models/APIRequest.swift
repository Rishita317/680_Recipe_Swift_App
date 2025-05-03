//
//  APIRequest.swift
//  Recipe
//
//  Created by gu xu on 5/2/25.
//


struct CreateRecipeRequest: Encodable {
    let recipeName: String
    let category: Int
    let recipePicture: String
    let postTime: String?
    let recipeType: Int
    let description: String?
    let cookingTime: String?
    let difficulty: Int
    let steps: [RecipeStepForRequest]?
    let ingredients: [IngredientForRequest]?
    let userId: Int
}

struct IngredientForRequest: Encodable {
    let name: String
    let amount: String
    let category: Int
}

struct RecipeStepForRequest: Encodable {
    let stepDesc: String
    let stepImg: String
}

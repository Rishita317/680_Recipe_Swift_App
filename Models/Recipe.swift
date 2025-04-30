import Foundation

struct Recipe: Decodable {
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

    static var defaultRecipe: Recipe {
        Recipe(
            recipeId: 1,
            recipeName: "Chef John's Nashville Hot Chicken",
            category: "Dinner",
            rating: 4.0,
            recipePicture: "https://www.allrecipes.com/thmb/VpE1xykUpZ9GsVbCeQjR2oCTvME=/0x512/filters:no_upscale():max_bytes(150000):strip_icc():format(webp)/254804-chef-johns-nashville-hot-chicken-DDMFS-4x3-c1192bac5dfc43bba55056a33a17153f.jpg",
            createTime: "2024-03-19 03:32:31",
            creatorId: 1,
            modifyTime: "2024-03-19 22:54:44",
            postTime: "None",
            recipeType: 1,
            status: 1,
            description: "A spicy fried chicken dish popularized in Nashville, Tennessee. It’s crispy, juicy, and has a kick of cayenne heat.",
            cookingTime: "30min",
            difficulty: 3,
            steps: [
                RecipeStep(stepDesc: "Marinate chicken in buttermilk and spices overnight.", stepImg: ""),
                RecipeStep(stepDesc: "Heat oil in a deep fryer to 350°F (175°C).", stepImg: "")
            ]
        )
    }
}

struct RecipeStep: Decodable {
    let stepDesc: String
    let stepImg: String
}

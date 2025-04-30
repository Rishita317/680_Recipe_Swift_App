import SwiftUI

struct RecipeDetailView: View {
    let recipeId: Int
    @State private var recipeDetail: RecipeDetail?
    @State private var isLoading = true
    @State private var hasError = false

    var body: some View {
        VStack {
            if isLoading {
                ProgressView("Loading...")
                    .padding()
            } else if let recipe = recipeDetail {
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        if let url = URL(string: recipe.recipePicture) {
                            AsyncImage(url: url) { phase in
                                if let image = phase.image {
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                } else if phase.error != nil {
                                    Color.red
                                } else {
                                    Color.gray.opacity(0.1)
                                }
                            }
                            .frame(height: 200)
                            .clipped()
                            .cornerRadius(15)
                        }

                        Text(recipe.recipeName)
                            .font(.title)
                            .bold()

                        if let description = recipe.description {
                            Text(description)
                                .font(.body)
                        }

                        if let cookingTime = recipe.cookingTime {
                            Text("Cooking Time: \(cookingTime)")
                                .font(.subheadline)
                        }

                        if let difficulty = recipe.difficulty {
                            Text("Difficulty: \(difficulty)/5")
                                .font(.subheadline)
                        }

                        if let ingredients = recipe.ingredients {
                            Text("Ingredients:")
                                .font(.headline)
                            ForEach(ingredients, id: \.ingredientId) { ingredient in
                                Text("- \(ingredient.amount) \(ingredient.ingredientName)")
                                    .font(.body)
                            }
                        }

                        if let steps = recipe.steps {
                            Text("Steps:")
                                .font(.headline)
                            ForEach(steps.indices, id: \.self) { index in
                                Text("\(index + 1). \(steps[index].stepDesc)")
                                    .font(.body)
                            }
                        }

                        if let reviews = recipe.reviews {
                            Text("Reviews:")
                                .font(.headline)
                            ForEach(reviews, id: \.reviewId) { review in
                                VStack(alignment: .leading) {
                                    Text("\(review.userName):")
                                        .font(.subheadline)
                                        .bold()
                                    Text("Rating: \(review.rating)/5")
                                        .font(.subheadline)
                                    Text(review.comment)
                                        .font(.body)
                                }
                                .padding(.vertical, 4)
                            }
                        }
                    }
                    .padding()
                }
            } else if hasError {
                Text("Failed to load recipe details.")
                    .foregroundColor(.red)
            }
        }
        .navigationTitle("Recipe Details")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            Task {
                await fetchRecipeDetail()
            }
        }
    }

    @MainActor
    func fetchRecipeDetail() async {
        guard let url = URL(string: API.detailURL(for: recipeId)) else {
            hasError = true
            isLoading = false
            return
        }
        print(recipeId)
        print(url)

        do {
            let (data, response) = try await URLSession.shared.data(from: url)

            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                hasError = true
                isLoading = false
                return
            }

            let apiResponse = try JSONDecoder().decode(RecipeDetailResponse.self, from: data)
            recipeDetail = apiResponse.data
        } catch {
            print("❌ Error fetching recipe detail: \(error.localizedDescription)")
            hasError = true
        }
        isLoading = false
    }
}

struct RecipeDetailResponse: Decodable {
    let statusCode: Int
    let statusMessage: String
    let data: RecipeDetail
}

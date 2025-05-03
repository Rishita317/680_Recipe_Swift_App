import SwiftUI

struct RecipeDetailView: View {
    let recipeId: Int
    @State private var recipeDetail: RecipeDetail?
    @State private var isLoading = true
    @State private var hasError = false
    @State private var userRating: Int = 0
    @State private var isLiked: Bool = false
    @State private var newComment: String = ""
    @State private var didJustSubmitReview = false
    @AppStorage("userId") private var userId: Int?

    var body: some View {
        VStack {
            if isLoading {
                ProgressView("Loading...")
                    .padding()
            } else if let recipe = recipeDetail {
                ScrollView {
                    VStack(spacing: 20) {
                        if let url = URL(string: recipe.recipePicture) {
                            AsyncImage(url: url) { phase in
                                if let image = phase.image {
                                    image
                                        .resizable()
                                        .scaledToFill()
                                } else if phase.error != nil {
                                    Color.red
                                } else {
                                    Color.gray.opacity(0.1)
                                }
                            }
                            .frame(height: 200)
                            .clipped()
                            .cornerRadius(15)
                            .padding(.horizontal)
                        }

                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text(recipe.recipeName)
                                    .font(.title)
                                    .bold()
                                Spacer()
                                Button {
                                    toggleFavorite()
                                } label: {
                                    Image(systemName: isLiked ? "heart.fill" : "heart")
                                        .foregroundColor(isLiked ? .red : .gray)
                                }
                                Button {
                                    shareRecipe(recipe)
                                } label: {
                                    Image(systemName: "square.and.arrow.up")
                                }
                            }
                            
                            if recipe.rating > 0 {
                                HStack(spacing: 4) {
                                    ForEach(1...5, id: \.self) { star in
                                        Image(systemName: star <= Int(recipe.rating.rounded()) ? "star.fill" : "star")
                                            .resizable()
                                            .frame(width: 16, height: 16)
                                            .foregroundColor(.yellow)
                                    }
                                    Text(String(format: "%.1f", recipe.rating))
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                            }


                            if let description = recipe.description {
                                Text(description)
                                    .font(.body)
                                    .foregroundColor(.secondary)
                            }

                            HStack(spacing: 16) {
                                if let cookingTime = recipe.cookingTime {
                                    Label(cookingTime, systemImage: "clock")
                                }
                                if let difficulty = recipe.difficulty {
                                    let label = ["Easy", "Medium", "Hard"][max(0, min(2, difficulty - 1))]
                                    Label(label, systemImage: "flame.fill")
                                }
                            }
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        }
                        .padding(.horizontal)

                        Divider()

                        if let ingredients = recipe.ingredients {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("🧂 Ingredients")
                                    .font(.headline)
                                ForEach(ingredients, id: \.ingredientId) { ingredient in
                                    Text("• \(ingredient.amount) \(ingredient.ingredientName)")
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                            .padding(.horizontal)

                        }

                        if let steps = recipe.steps {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("📋 Steps")
                                    .font(.headline)
                                ForEach(steps.indices, id: \.self) { i in
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Step \(i + 1):").bold()
                                        Text(steps[i].stepDesc)
                                    }
                                    .padding(.vertical, 4)
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                            .padding(.horizontal)
                        }

                        VStack(alignment: .leading, spacing: 12) {
                            Text("⭐️ Leave a Review")
                                .font(.headline)

                            HStack {
                                ForEach(1...5, id: \ .self) { star in
                                    Image(systemName: star <= userRating ? "star.fill" : "star")
                                        .resizable()
                                        .frame(width: 24, height: 24)
                                        .foregroundColor(.yellow)
                                        .onTapGesture {
                                            userRating = star
                                        }
                                }
                            }

                            TextField("Write a comment...", text: $newComment, axis: .vertical)
                                .textFieldStyle(.roundedBorder)
                                .lineLimit(2...4)

                            Button("Submit Review") {
                                submitReview()
                            }
                            .buttonStyle(.borderedProminent)
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                        .padding(.horizontal)

                        if let reviews = recipe.reviews {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("💬 Reviews")
                                    .font(.headline)

                                ForEach(reviews, id: \ .reviewId) { review in
                                    VStack(alignment: .leading, spacing: 4) {
                                        HStack {
                                            Text(review.userName).bold()
                                            Spacer()
                                            Text("⭐️ \(review.rating)")
                                                .foregroundColor(.yellow)
                                        }
                                        Text(review.comment)
                                            .foregroundColor(.secondary)
                                    }
                                    .padding()
                                    .background(Color.white)
                                    .cornerRadius(10)
                                    .shadow(radius: 1)
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    .padding(.bottom)
                }
            } else if hasError {
                Text("Failed to load recipe details.")
                    .foregroundColor(.red)
                    .padding()
            }
        }
        .navigationTitle("Recipe Details")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            Task { await fetchRecipeDetail() }
        }
    }

    @MainActor
    func fetchRecipeDetail() async {
        guard let url = URL(string: API.detailURL(for: recipeId)) else {
            hasError = true
            isLoading = false
            return
        }

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
            isLiked = apiResponse.data.status == 1
            if !didJustSubmitReview,
               let userId = userId,
               let existingReview = apiResponse.data.reviews?.first(where: { $0.userId == userId }) {
                userRating = existingReview.rating
                newComment = existingReview.comment
            }
            didJustSubmitReview = false // reset for future reloads
        } catch {
            print("❌ Error fetching recipe detail: \(error.localizedDescription)")
            hasError = true
        }
        isLoading = false
    }

    func shareRecipe(_ recipe: RecipeDetail) {
        let activityVC = UIActivityViewController(activityItems: [recipe.recipeName], applicationActivities: nil)
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootVC = windowScene.windows.first?.rootViewController {
            rootVC.present(activityVC, animated: true)
        }
    }

    func toggleFavorite() {

        guard let userId else { return }
        let status = isLiked ? 1 : 0
        guard let url = URL(string: API.favoriteRecipeURL) else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = [
            "recipeId": String(recipeId),
            "userId": userId,
            "status": status
        ]

        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        URLSession.shared.dataTask(with: request) { data, _, _ in
            DispatchQueue.main.async {
                isLiked.toggle()
            }
        }.resume()
    }

    func submitReview() {
        guard let userId, !newComment.isEmpty, userRating > 0 else { return }
        guard let url = URL(string: API.rateAndCommentURL) else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = [
            "recipeId": recipeId,
            "userId": userId,
            "comment": newComment,
            "rating": userRating
        ]

        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        URLSession.shared.dataTask(with: request) { data, _, _ in
            DispatchQueue.main.async {
                newComment = ""
                userRating = 0
                didJustSubmitReview = true
                Task {
                    await fetchRecipeDetail()
                }
            }

        }.resume()
    }
}

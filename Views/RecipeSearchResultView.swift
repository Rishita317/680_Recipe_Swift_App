import SwiftUI

struct RecipeSearchResultView: View {
    let keyword: String
    @State private var recipes: [Recipe] = []
    @State private var showNoResults = false
    @State private var isLoading = true
    
    var body: some View {
        VStack {
            if isLoading {
                ProgressView("Searching...")
                    .padding(.top, 50)
            } else if showNoResults {
                VStack(spacing: 10) {
                    Image(systemName: "magnifyingglass.circle")
                        .font(.system(size: 64))
                        .foregroundColor(.gray)
                    Text("No recipes found")
                        .font(.headline)
                        .foregroundColor(.gray)
                }
                .padding(.top, 50)
            } else {
                ScrollView {
                    LazyVStack(spacing: 20) {
                        ForEach(recipes, id: \.recipeId) { recipe in
                            RecipeCardView(
                                title: recipe.recipeName,
                                description: recipe.description ?? "",
                                pictureURL: recipe.recipePicture,
                                rating: recipe.rating
                            )
                        }
                    }
                    .padding()
                }
            }
        }
        .navigationTitle("Search Results")
        .task {
            await searchRecipes()
        }
    }
    
    @MainActor
    func searchRecipes() async {
        guard let url = URL(string: API.searchURL(for: keyword)) else { return }
        
        do {
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                showNoResults = true
                isLoading = false
                return
            }

            let apiResponse = try JSONDecoder().decode(APIResponse.self, from: data)
            if apiResponse.statusCode == 0 {
                if apiResponse.data.isEmpty {
                    showNoResults = true
                } else {
                    recipes = apiResponse.data
                    showNoResults = false
                }
            } else {
                showNoResults = true
            }
        } catch {
            print("❌ Search error: \(error.localizedDescription)")
            showNoResults = true
        }
        isLoading = false
    }
}

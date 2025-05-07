//
//  FavoritesView.swift
//  Recipe
//
//  Created by Pankuri Khare on 5/6/25.
//

import SwiftUI

struct FavoritesView: View {
    @State private var allRecipes: [Recipe] = []
    @State private var isLoading = true

    var favoriteRecipes: [Recipe] {
        allRecipes.filter { $0.status == 1 }
    }

    var body: some View {
        NavigationStack {
            VStack {
                if isLoading {
                    ProgressView("Loading favorites...")
                        .padding()
                } else if favoriteRecipes.isEmpty {
                    Text("You haven't favorited anything yet ❤️")
                        .font(.headline)
                        .foregroundColor(.gray)
                        .padding()
                } else {
                    ScrollView {
                        LazyVStack(spacing: 20) {
                            ForEach(favoriteRecipes, id: \.recipeId) { recipe in
                                RecipeCardView(recipe: recipe)
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Favorites")
        }
        .task {
            await fetchAllRecipes()
        }
    }

    func fetchAllRecipes() async {
        guard let url = URL(string: API.randomURL) else { return }

        do {
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            let (data, response) = try await URLSession.shared.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else { return }

            let apiResponse = try JSONDecoder().decode(APIResponse.self, from: data)
            if apiResponse.statusCode == 0 {
                allRecipes = apiResponse.data
            }
        } catch {
            print("❌ Error fetching favorites: \(error.localizedDescription)")
        }

        isLoading = false
    }
}

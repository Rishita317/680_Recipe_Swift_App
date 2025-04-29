//
//  ContentView.swift
//  RecipeTest
//
//  Created by Rishita Meharishi on 4/21/25.
//

import SwiftUI

struct Recipe: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let category: String
}

struct RecipeView: View {
    @State private var searchText = ""
    @State private var selectedCategory = "All"
    
    let categories = ["All", "Breakfast", "Lunch", "Dinner", "Dessert", "Snacks"]
    
    @State private var recipes: [Recipe] = [
        Recipe(title: "Pancakes", description: "Fluffy breakfast pancakes.", category: "Breakfast"),
        Recipe(title: "Caesar Salad", description: "Fresh and crisp.", category: "Lunch"),
        Recipe(title: "Grilled Chicken", description: "Perfectly grilled for dinner.", category: "Dinner"),
        Recipe(title: "Chocolate Cake", description: "Rich and moist dessert.", category: "Dessert"),
        Recipe(title: "Fruit Smoothie", description: "Refreshing snack option.", category: "Snacks")
    ]
    
    var filteredRecipes: [Recipe] {
        recipes.filter {
            (searchText.isEmpty || $0.title.localizedCaseInsensitiveContains(searchText)) &&
            (selectedCategory == "All" || $0.category == selectedCategory)
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                
                // Search Bar
                TextField("Search recipes...", text: $searchText)
                    .padding(10)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                    .padding([.top, .horizontal])
                
                // Tabs (Categories)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 15) {
                        ForEach(categories, id: \.self) { category in
                            Button(action: {
                                selectedCategory = category
                            }) {
                                Text(category)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                                    .background(selectedCategory == category ? Color.blue.opacity(0.3) : Color.blue.opacity(0.1))
                                    .foregroundColor(.blue)
                                    .cornerRadius(20)
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 5)
                }
                
                // Recipe Cards
                ScrollView {
                    LazyVStack(spacing: 20) {
                        ForEach(filteredRecipes) { recipe in
                            RecipeCardView(title: recipe.title, description: recipe.description)
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Recipes")
        }
    }
}

struct RecipeCardView: View {
    var title: String
    var description: String

    var body: some View {
        VStack(alignment: .leading) {
            Image("recipe_placeholder") // Make sure you have a placeholder image asset
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(height: 180)
                .clipped()
                .cornerRadius(15)
                .accessibilityLabel("\(title) image")
            
            Text(title)
                .font(.headline)
                .padding(.top, 5)
            
            Text(description)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

struct RecipeListView: View {
    var category: String
    var recipes: [Recipe]
    
    var body: some View {
        VStack {
            Text("\(category) Recipes")
                .font(.largeTitle)
                .bold()
                .padding()
            
            ScrollView {
                LazyVStack(spacing: 20) {
                    ForEach(recipes.filter { $0.category == category || category == "All" }) { recipe in
                        RecipeCardView(title: recipe.title, description: recipe.description)
                    }
                }
                .padding()
            }
        }
        .navigationTitle(category)
    }
}

#Preview {
    RecipeView()
}

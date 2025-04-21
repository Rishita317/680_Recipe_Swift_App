//
//  ContentView.swift
//  RecipeTest
//
//  Created by Rishita Meharishi on 4/21/25.
//

import SwiftUI

struct RecipeView: View {
    @State private var searchText = ""
    
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
                        ForEach(["All", "Breakfast", "Lunch", "Dinner", "Dessert", "Snacks"], id: \.self) { category in
                            Text(category)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(Color.blue.opacity(0.1))
                                .foregroundColor(.blue)
                                .cornerRadius(20)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 5)
                }

                // Recipe Cards
                ScrollView {
                    LazyVStack(spacing: 20) {
                        ForEach(0..<10) { index in
                            RecipeCardView()
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
    var body: some View {
        VStack(alignment: .leading) {
            Image("recipe_placeholder") // replace with actual image asset name
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(height: 180)
                .clipped()
                .cornerRadius(15)
            
            Text("Recipe Title")
                .font(.headline)
                .padding(.top, 5)
            
            Text("A short description of the recipe goes here.")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

#Preview {
    RecipeView()
}


import SwiftUI

struct RecipeCardView: View {
    var recipe: Recipe
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        NavigationLink(destination: RecipeDetailView(recipeId: recipe.recipeId)) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    // Image
                    if let url = URL(string: recipe.recipePicture), !recipe.recipePicture.isEmpty {
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
                        .frame(height: 180)
                        .frame(maxWidth: .infinity)
                        .clipped()
                        .cornerRadius(15)
                    } else {
                        Image("recipe_placeholder")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 180)
                            .frame(maxWidth: .infinity)
                            .clipped()
                            .cornerRadius(15)
                    }

                    // 🔥 FIERY TAGS
                    HStack(spacing: 10) {
                        if !recipe.category.isEmpty {
                            Text(recipe.category.uppercased())
                                .font(.caption2)
                                .fontWeight(.bold)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(
                                    LinearGradient(
                                        colors: [Color.red, Color.orange],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .foregroundColor(.white)
                                .cornerRadius(15)
                                .shadow(color: .orange.opacity(0.4), radius: 4, x: 0, y: 2)
                        }

                        if let difficulty = recipe.difficulty, difficulty > 0 {
                            let levels = ["EASY", "MEDIUM", "HARD"]
                            let levelText = levels[max(0, min(2, difficulty - 1))]
                            Text(levelText)
                                .font(.caption2)
                                .fontWeight(.bold)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(
                                    LinearGradient(
                                        colors: [Color.purple, Color.blue],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .foregroundColor(.white)
                                .cornerRadius(15)
                                .shadow(color: .blue.opacity(0.4), radius: 4, x: 0, y: 2)
                        }
                    }

                    // Recipe Name
                    Text(recipe.recipeName)
                        .font(.headline)

                    // Description
                    Text(recipe.description ?? "")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.leading)

                    // Rating
                    HStack(spacing: 2) {
                        ForEach(0..<5) { i in
                            Image(systemName: i < Int(recipe.rating) ? "star.fill" : (recipe.rating >= Double(i) + 0.5 ? "star.lefthalf.fill" : "star"))
                                .foregroundColor(.yellow)
                        }

                        Text(String(format: "%.1f", recipe.rating))
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .padding(.leading, 6)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(15)
            .overlay(
                RoundedRectangle(cornerRadius: 15)
                    .stroke(
                        colorScheme == .dark ? Color.white.opacity(0.15) : Color.clear,
                        lineWidth: 1.5
                    )
            )
            .shadow(
                color: colorScheme == .dark ? Color.white.opacity(0.2) : Color.black.opacity(0.1),
                radius: colorScheme == .dark ? 8 : 5,
                x: 0,
                y: 3
            )
        }
    }
}

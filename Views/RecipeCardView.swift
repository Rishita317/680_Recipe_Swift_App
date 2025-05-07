import SwiftUI

struct RecipeCardView: View {
    var recipe: Recipe
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        NavigationLink(destination: RecipeDetailView(recipeId: recipe.recipeId)) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
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

                    Text(recipe.recipeName)
                        .font(.headline)

                    Text(recipe.description ?? "")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.leading)

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

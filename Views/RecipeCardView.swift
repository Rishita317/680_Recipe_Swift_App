import SwiftUI

struct RecipeCardView: View {
    var recipe: Recipe

    var body: some View {
        NavigationLink(destination: RecipeDetailView(recipeId: recipe.recipeId)) {
            VStack(alignment: .leading) {
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
                    .clipped()
                    .cornerRadius(15)
                } else {
                    Image("recipe_placeholder")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 180)
                        .clipped()
                        .cornerRadius(15)
                }

                Text(recipe.recipeName)
                    .font(.headline)
                    .padding(.top, 5)

                Text(recipe.description ?? "")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.bottom, 4)

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
            .padding()
            .background(Color.white)
            .cornerRadius(15)
            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        }
    }
}

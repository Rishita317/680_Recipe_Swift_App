//
//  RecipeCardView.swift
//  Recipe
//
//  Created by gu xu on 4/28/25.
//

import SwiftUI

struct RecipeCardView: View {
    var title: String
    var description: String
    var pictureURL: String

    var body: some View {
        VStack(alignment: .leading) {
            if let url = URL(string: pictureURL), !pictureURL.isEmpty {
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

#Preview {
    RecipeCardView(
        title: "Sample Recipe",
        description: "Rating: 5.0",
        pictureURL: ""
    )
}


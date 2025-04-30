import SwiftUI

struct RecipeCardView: View {
    var title: String
    var description: String
    var pictureURL: String
    var rating: Double

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
                .padding(.bottom, 4)
            
            HStack(spacing: 2) {
                ForEach(0..<5) { i in
                    Image(systemName: i < Int(rating) ? "star.fill" : (rating >= Double(i) + 0.5 ? "star.lefthalf.fill" : "star"))
                        .foregroundColor(.yellow)
                }
                
                Text(String(format: "%.1f", rating))
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

#Preview {
    RecipeCardView(
        title: "Sample Recipe",
        description: "A delicious test recipe",
        pictureURL: "",
        rating: 4.5
    )
}

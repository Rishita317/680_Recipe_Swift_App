import SwiftUI

struct CreateRecipeView: View {
    var body: some View {
        NavigationStack {
            VStack {
                Text("Create Recipe")
                    .font(.title)
                    .padding()

                Spacer()
            }
            .navigationTitle("Create")
        }
    }
}

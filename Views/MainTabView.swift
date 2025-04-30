import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            RecipeView()
                .tabItem {
                    Label("Recipes", systemImage: "list.bullet")
                }

            CreateRecipeView()
                .tabItem {
                    Label("Create", systemImage: "plus.circle")
                }

            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.crop.circle")
                }
        }
    }
}

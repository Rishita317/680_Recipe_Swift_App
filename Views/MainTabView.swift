import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            RecipeView()
                .tabItem {
                    Label("Recipes", systemImage: "list.bullet")
                }
                .tag(0)

            CreateRecipeView()
                .tabItem {
                    Label("Create", systemImage: "plus.circle")
                }
                .tag(1)

            ProfileView(selectedTab: $selectedTab)
                .tabItem {
                    Label("Profile", systemImage: "person.crop.circle")
                }
                .tag(2)
        }
    }
}

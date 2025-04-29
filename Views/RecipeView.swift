import SwiftUI

struct RecipeView: View {
    @State private var searchText = ""
    @State private var isSearching = false
    @State private var searchKeyword = ""
    
    @State private var selectedCategory = "All"
    let categories = ["All", "Breakfast", "Lunch", "Dinner", "Dessert", "Snacks"]
    
    @State private var recipes: [Recipe] = [
        Recipe(
            recipeId: 1,
            recipeName: "Chef John's Nashville Hot Chicken",
            category: "Dinner",
            rating: "4.0",
            recipePicture: "https://www.allrecipes.com/thmb/VpE1xykUpZ9GsVbCeQjR2oCTvME=/0x512/filters:no_upscale():max_bytes(150000):strip_icc():format(webp)/254804-chef-johns-nashville-hot-chicken-DDMFS-4x3-c1192bac5dfc43bba55056a33a17153f.jpg",
            createTime: "2024-03-19 03:32:31",
            creatorId: 1,
            modifyTime: "2024-03-19 22:54:44",
            postTime: "2024-03-18 20:32:12",
            recipeType: 1,
            status: 1
        )
    ]
    
    var filteredRecipes: [Recipe] {
        recipes.filter {
            (searchText.isEmpty || $0.recipeName.localizedCaseInsensitiveContains(searchText)) &&
            (selectedCategory == "All" || $0.category == selectedCategory)
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Search bar
                HStack {
                    TextField("Search recipes...", text: $searchText)
                        .padding(10)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(10)
                        .onSubmit {
                            if !searchText.isEmpty {
                                searchKeyword = searchText
                                isSearching = true
                                searchText = ""
                            }
                        }
                    
                    NavigationLink(destination: RecipeSearchResultView(keyword: searchKeyword), isActive: $isSearching) {
                        EmptyView()
                    }
                    .hidden()
                }
                .padding([.top, .horizontal])
                
                // Categories
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
                
                // Recipe List
                ScrollView {
                    LazyVStack(spacing: 20) {
                        ForEach(filteredRecipes, id: \.recipeId) { recipe in
                            RecipeCardView(
                                title: recipe.recipeName,
                                description: recipe.description,
                                pictureURL: recipe.recipePicture
                            )
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Recipes")
        }
        .task {
            await fetchRandomRecipes()
        }
    }
    
    @MainActor
    func fetchRandomRecipes() async {
        guard let url = URL(string: "https://yourapi.com/api/recipe/random") else { return }
        
        do {
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else { return }
            let apiResponse = try JSONDecoder().decode(APIResponse.self, from: data)
            if apiResponse.statusCode == 0 {
                recipes = apiResponse.data
            }
        } catch {
            print("Fetch error: \(error.localizedDescription)")
        }
    }
}

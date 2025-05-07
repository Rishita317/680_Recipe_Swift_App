import SwiftUI

struct RecipeView: View {
    @AppStorage("isLoggedIn") var isLoggedIn: Bool = false
    @AppStorage("userName") var userName: String = ""

    @State private var searchText = ""
    @State private var isSearching = false
    @State private var searchKeyword = ""

    @State private var selectedCategory = "All"
    let categories = ["All", "Breakfast", "Lunch", "Dinner", "Dessert", "Snacks"]

    @State private var selectedDifficulty: String? = nil
    @State private var tempSelectedDifficulty: String? = nil

    @State private var maxCookingTime: Double? = nil
    @State private var tempMaxCookingTime: Double = 120

    @State private var showFilterSheet = false

    let difficulties = ["Easy", "Medium", "Hard"]
    let cookingTimeRange: ClosedRange<Double> = 0...120

    @State private var recipes: [Recipe] = [Recipe.defaultRecipe]

    var filteredRecipes: [Recipe] {
        recipes.filter { recipe in
            let matchesSearch = searchText.isEmpty || recipe.recipeName.localizedCaseInsensitiveContains(searchText)
            let matchesCategory = selectedCategory == "All" || recipe.category == selectedCategory

            let matchesDifficulty: Bool = {
                guard let selected = selectedDifficulty,
                      let index = difficulties.firstIndex(of: selected) else { return true }
                return recipe.difficulty == index + 1
            }()

            let matchesCookingTime: Bool = {
                guard let max = maxCookingTime,
                      let rawTime = recipe.cookingTime,
                      let parsedTime = parseCookingTime(rawTime) else { return true }
                return parsedTime <= Int(max)
            }()

            return matchesSearch && matchesCategory && matchesDifficulty && matchesCookingTime
        }
    }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
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

                    // Category pills
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(categories, id: \.self) { category in
                                Button(action: {
                                    selectedCategory = category
                                }) {
                                    Text(category)
                                        .font(.subheadline)
                                        .padding(.vertical, 8)
                                        .padding(.horizontal, 16)
                                        .background(
                                            RoundedRectangle(cornerRadius: 20)
                                                .fill(selectedCategory == category ? Color.blue.opacity(0.3) : Color.blue.opacity(0.1))
                                        )
                                        .foregroundColor(.blue)
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
                                RecipeCardView(recipe: recipe)
                            }
                        }
                        .padding()
                    }
                }

                // Floating Filter Button (FAB Style)
                Button {
                    tempSelectedDifficulty = selectedDifficulty
                    tempMaxCookingTime = maxCookingTime ?? 120
                    showFilterSheet = true
                } label: {
                    Label("Filter", systemImage: "line.3.horizontal.decrease.circle")
                        .font(.subheadline)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(Color(.systemBackground))
                        .foregroundColor(.blue)
                        .clipShape(Capsule())
                        .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
                }
                .padding()
            }
            .navigationTitle("Recipes")
        }
        .sheet(isPresented: $showFilterSheet) {
            filterSheet
        }
        .task {
            await fetchRandomRecipes()
        }
    }

    var filterSheet: some View {
        NavigationView {
            Form {
                Section(header: Text("Difficulty")) {
                    ForEach(difficulties, id: \.self) { level in
                        HStack {
                            Text(level)
                            Spacer()
                            if tempSelectedDifficulty == level {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.blue)
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            tempSelectedDifficulty = tempSelectedDifficulty == level ? nil : level
                        }
                    }
                }

                Section(header: Text("Max Cooking Time")) {
                    VStack(alignment: .leading) {
                        Slider(value: $tempMaxCookingTime, in: cookingTimeRange, step: 5)
                        Text("≤ \(Int(tempMaxCookingTime)) min")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    .padding(.vertical, 6)
                }
            }
            .navigationTitle("Filters")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Clear") {
                        tempSelectedDifficulty = nil
                        selectedDifficulty = nil
                        tempMaxCookingTime = 120
                        maxCookingTime = nil
                        showFilterSheet = false
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Apply") {
                        selectedDifficulty = tempSelectedDifficulty
                        maxCookingTime = tempMaxCookingTime < 120 ? tempMaxCookingTime : nil
                        showFilterSheet = false
                    }
                }
            }
        }
    }

    func parseCookingTime(_ raw: String) -> Int? {
        let lower = raw.lowercased()
        var total = 0

        let hourPattern = #"(\d+)\s*(hour|hr)"#
        let minPattern = #"(\d+)\s*(min|minute)"#

        if let hourMatch = lower.range(of: hourPattern, options: .regularExpression) {
            let hourText = lower[hourMatch]
            if let hour = Int(hourText.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()) {
                total += hour * 60
            }
        }

        if let minMatch = lower.range(of: minPattern, options: .regularExpression) {
            let minText = lower[minMatch]
            if let mins = Int(minText.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()) {
                total += mins
            }
        }

        return total > 0 ? total : nil
    }

    @MainActor
    func fetchRandomRecipes() async {
        guard let url = URL(string: API.randomURL) else { return }
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
            print("❌ Failed to load recipes: \(error.localizedDescription)")
            recipes = [Recipe.defaultRecipe]
        }
    }
}

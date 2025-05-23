import SwiftUI

struct ProfileView: View {
    @Binding var selectedTab: Int

    @AppStorage("isLoggedIn") var isLoggedIn: Bool = false
    @AppStorage("userName") var userName: String = ""
    @AppStorage("userEmail") var userEmail: String = ""
    @AppStorage("userId") private var userId: Int?
    @AppStorage("isDarkMode") private var isDarkMode = false

    @State private var myRecipes: [Recipe] = []
    @State private var isLoading = true
    @State private var errorMessage: String?
    @State private var recentlyViewed: [Recipe] = []
    

    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground).ignoresSafeArea()

                VStack {
                    if isLoggedIn {
                        if isLoading {
                            ProgressView("Loading your recipes...")
                                .padding()
                        } else if let errorMessage = errorMessage {
                            errorView(message: errorMessage)
                        } else {
                            recipeContent
                        }
                    } else {
                        loggedOutView
                    }
                }
                .padding(.top)
            }
            .navigationTitle("My Profile")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                if isLoggedIn {
                    fetchUserRecipes()
                }
            }
        }
    }

    private var recipeContent: some View {
        ScrollView {
            VStack(spacing: 20) {
                profileHeader

                if myRecipes.isEmpty {
                    emptyRecipePrompt
                } else {
                    VStack(alignment: .leading, spacing: 15) {
                        Text("My Recipes")
                            .font(.headline)
                            .padding(.horizontal)

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 16) {
                                ForEach(myRecipes, id: \.recipeId) { recipe in
                                    RecipeCardView(recipe: recipe)
                                        .frame(width: 200)
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                }

                Button("Log Out") {
                    isLoggedIn = false
                    userName = ""
                    userEmail = ""
                    userId = nil
                }
                .font(.body)
                .foregroundColor(.red)
                .padding(.top)
            }
            .padding(.vertical)
        }
    }

    private var profileHeader: some View {
        VStack(spacing: 10) {
            AsyncImage(url: URL(string: "https://placekitten.com/200/200")) { image in
                image.resizable().aspectRatio(contentMode: .fill)
            } placeholder: {
                Image(systemName: "person.crop.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(.gray)
            }
            .frame(width: 80, height: 80)
            .clipShape(Circle())
            .shadow(radius: 3)

            Text(userName)
                .font(.title2)
                .fontWeight(.bold)

            Text(userEmail)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Toggle(isOn: $isDarkMode) {
                Label("Dark Mode", systemImage: "moon.fill")
            }
            .toggleStyle(SwitchToggleStyle(tint: .orange))
            .padding(.horizontal)

        }
    }

    private var emptyRecipePrompt: some View {
        Button {
            selectedTab = 1 // Switch to Create tab
        } label: {
            VStack(spacing: 15) {
                Image(systemName: "plus.circle")
                    .resizable()
                    .frame(width: 60, height: 60)
                    .foregroundColor(.gray.opacity(0.7))
                Text("No Recipes Yet")
                    .font(.title3)
                    .fontWeight(.semibold)
                Text("Start sharing your favorite dishes with the community.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            .padding(.top, 50)
        }
    }

    private var loggedOutView: some View {
        VStack(spacing: 25) {
            Image(systemName: "fork.knife.circle.fill")
                .resizable()
                .frame(width: 100, height: 100)
                .foregroundColor(.orange)

            Text("Sign in to view your profile")
                .font(.title3)
                .fontWeight(.medium)

            Text("Access your recipes and more.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            NavigationLink("Log In") {
                LoginView()
            }
            .buttonStyle(.borderedProminent)
            .tint(.orange)

            NavigationLink("Create an Account") {
                RegisterView()
            }
            .buttonStyle(.bordered)
            .tint(.orange)
        }
        .padding(40)
    }

    private func errorView(message: String) -> some View {
        VStack(spacing: 10) {
            Image(systemName: "exclamationmark.triangle")
                .resizable()
                .frame(width: 50, height: 50)
                .foregroundColor(.orange)
            Text("Failed to load recipes")
                .font(.headline)
            Text(message)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding()
    }

    private func fetchUserRecipes() {
        guard let userId = userId else {
            self.errorMessage = "Invalid user ID."
            self.isLoading = false
            return
        }

        guard let url = URL(string: API.uerRecipeURL(for: userId)) else {
            self.errorMessage = "Invalid URL."
            self.isLoading = false
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                self.isLoading = false

                if let error = error {
                    self.errorMessage = error.localizedDescription
                    return
                }

                guard let data = data else {
                    self.errorMessage = "No data received from server."
                    return
                }

                do {
                    let decoded = try JSONDecoder().decode(APIResponse.self, from: data)
                    self.myRecipes = decoded.data
                } catch {
                    self.errorMessage = "Failed to decode response: \(error.localizedDescription)"
                }
            }
        }.resume()
    }
}

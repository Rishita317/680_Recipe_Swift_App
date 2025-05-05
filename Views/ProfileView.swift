import SwiftUI

struct EditProfileView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var userName: String
    @Binding var userEmail: String
    @State private var editedName: String
    @State private var editedEmail: String

    init(userName: Binding<String>, userEmail: Binding<String>) {
        self._userName = usera Name
        self._userEmail = userEmail
        self._editedName = State(initialValue: userName.wrappedValue)
        self._editedEmail = State(initialValue: userEmail.wrappedValue)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Name")) {
                    TextField("Name", text: $editedName)
                }

                Section(header: Text("Email")) {
                    TextField("Email", text: $editedEmail)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                }
            }
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        userName = editedName
                        userEmail = editedEmail
                        dismiss()
                    }
                    .disabled(editedName.isEmpty || editedEmail.isEmpty)
                }
            }
        }
    }
}


struct ProfileView: View {
    @AppStorage("isLoggedIn") var isLoggedIn: Bool = false
    @AppStorage("userName") var userName: String = ""
    @AppStorage("userEmail") var userEmail: String = ""
    @AppStorage("userId") var userId: Int = 0
    @State private var showEditProfile = false

    @State private var myRecipes: [Recipe] = [
        Recipe.defaultRecipe,
        Recipe(
            recipeId: 2,
            recipeName: "Homemade Pizza Dough",
            category: "Baking",
            rating: 4.5,
            recipePicture: "https://www.allrecipes.com/thmb/4hm-I7-RxESm7hG3bBNmch8YaJs=/1500x0/filters:no_upscale():max_bytes(150000):strip_icc()/6776_pizza-dough_ddmfs_4x3_1473-e52613e8d4114e9b8ed8c6a125268c4c.jpg",
            createTime: "2024-03-25 14:22:11",
            creatorId: 1,
            modifyTime: "2024-03-25 16:45:32",
            postTime: "2024-03-25 16:45:32",
            recipeType: 1,
            status: 1,
            description: "Simple and delicious homemade pizza dough that's perfect for family pizza night.",
            cookingTime: "20min",
            difficulty: 2,
            steps: [
                RecipeStep(stepDesc: "Mix flour, yeast, salt, and warm water.", stepImg: ""),
                RecipeStep(stepDesc: "Knead until smooth and elastic.", stepImg: "")
            ]
        )
    ]

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if isLoggedIn {
                    ScrollView {
                        VStack(spacing: 20) {
                            // Profile Header
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

                                Button("Edit Profile") {
                                    showEditProfile = true
                                }
                                .font(.subheadline)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 6)
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(8)
                            }

                            // My Recipes Section
                            if myRecipes.isEmpty {
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
                            } else {
                                VStack(alignment: .leading, spacing: 15) {
                                    Text("My Recipes")
                                        .font(.headline)
                                        .padding(.horizontal)

                                    ForEach(myRecipes, id: \.recipeId) { recipe in
                                        RecipeCardView(recipe: recipe)
                                            .padding(.horizontal)
                                    }
                                }
                            }
                        }
                        .padding(.vertical)
                    }
                    .sheet(isPresented: $showEditProfile) {
                        EditProfileView(userName: $userName, userEmail: $userEmail)
                    }
                } else {
                    VStack(spacing: 25) {
                        Image(systemName: "fork.knife.circle.fill")
                            .resizable()
                            .frame(width: 100, height: 100)
                            .foregroundColor(.orange)

                        Text("Sign in to view your profile")
                            .font(.title3)
                            .fontWeight(.medium)

                        Text("Access your recipes and update your profile.")
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
            }
            .navigationTitle("My Profile")
            .navigationBarTitleDisplayMode(.inline)
            .background(Color(.systemGroupedBackground))
        }
    }
}

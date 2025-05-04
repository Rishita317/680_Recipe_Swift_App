import SwiftUI
import PhotosUI

struct IngredientInput: Identifiable {
    var id = UUID()
    var name: String = ""
    var amount: String = ""
    var category: Int = 0
}

struct CreateRecipeView: View {
    @AppStorage("userId") private var userId: Int?
    @State private var recipeName = ""
    @State private var category = "Dinner"
    @State private var description = ""
    @State private var cookingTime = ""
    @State private var difficulty = 1
    @State private var steps: [RecipeStep] = [RecipeStep(stepDesc: "", stepImg: "")]
    @State private var ingredients: [IngredientInput] = [IngredientInput()]
    @State private var selectedImage: UIImage?
    @State private var photosPickerItem: PhotosPickerItem?
    @State private var recipeImageUrl: String = ""

    @State private var showLoginAlert = false
    @State private var navigateToLogin = false

    @State private var createdRecipeId: Int?
    @State private var selectedRecipeId: Int?
    @State private var navigateToSuccess = false
    @State private var navigateToDetail = false

    let categories = ["Breakfast", "Lunch", "Dinner", "Dessert", "Snack"]
    let difficultyLevels = [1, 2, 3]
    let difficultyLabels = ["Easy", "Medium", "Hard"]

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Recipe Photo")) {
                    HStack {
                        Spacer()
                        if let selectedImage {
                            Image(uiImage: selectedImage)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 150, height: 150)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                        } else {
                            Image(systemName: "photo")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 50, height: 50)
                                .foregroundColor(.gray)
                                .frame(width: 150, height: 150)
                                .background(Color(.systemGray5))
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                        Spacer()
                    }
                    .padding(.vertical)

                    PhotosPicker(selection: $photosPickerItem, matching: .images) {
                        Label("Select Photo", systemImage: "photo")
                    }
                    .onChange(of: photosPickerItem) { _, _ in
                        Task {
                            if let item = photosPickerItem,
                               let data = try? await item.loadTransferable(type: Data.self),
                               let image = UIImage(data: data) {
                                selectedImage = image
                                if let url = await uploadImage(image: image) {
                                    recipeImageUrl = url
                                }
                            }
                            photosPickerItem = nil
                        }
                    }
                }

                Section(header: Text("Basic Information")) {
                    TextField("Recipe Name", text: $recipeName)
                    Picker("Category", selection: $category) {
                        ForEach(categories, id: \.self) { Text($0) }
                    }
                    TextField("Cooking Time (e.g. 30min)", text: $cookingTime)
                    Picker("Difficulty", selection: $difficulty) {
                        ForEach(difficultyLevels, id: \.self) { Text(difficultyLabels[$0 - 1]).tag($0) }
                    }
                    TextField("Description", text: $description, axis: .vertical).lineLimit(3...)
                }

                Section(header: Text("Ingredients")) {
                    ForEach($ingredients) { $ingredient in
                        HStack {
                            TextField("Name", text: $ingredient.name)
                            TextField("Amount", text: $ingredient.amount)
                        }
                    }
                    Button("Add Ingredient") {
                        ingredients.append(IngredientInput())
                    }
                    if ingredients.count > 1 {
                        Button("Remove Last", role: .destructive) {
                            ingredients.removeLast()
                        }
                    }
                }

                Section(header: Text("Preparation Steps")) {
                    ForEach(Array(steps.enumerated()), id: \.offset) { index, step in
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Step \(index + 1)")
                                .font(.subheadline)
                                .foregroundColor(.secondary)

                            TextField("Step description", text: Binding(
                                get: { steps[index].stepDesc },
                                set: { newValue in
                                    var step = steps[index]
                                    step = RecipeStep(stepDesc: newValue, stepImg: step.stepImg)
                                    steps[index] = step
                                }
                            ), axis: .vertical)
                            .lineLimit(3...)

                            PhotosPicker(selection: Binding<PhotosPickerItem?>(
                                get: { nil },
                                set: { newItem in
                                    Task {
                                        if let newItem,
                                           let data = try? await newItem.loadTransferable(type: Data.self),
                                           let image = UIImage(data: data),
                                           let url = await uploadImage(image: image) {
                                            var step = steps[index]
                                            step = RecipeStep(stepDesc: step.stepDesc, stepImg: url)
                                            steps[index] = step
                                        }
                                    }
                                }
                            ), matching: .images) {
                                Label("Add Step Image", systemImage: "photo")
                            }
                        }
                    }

                    Button("Add Step") { steps.append(RecipeStep(stepDesc: "", stepImg: "")) }
                    if steps.count > 1 {
                        Button("Remove Last Step", role: .destructive) { steps.removeLast() }
                    }
                }
            }
            .navigationTitle("Create Recipe")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Clear") {
                        clearForm()
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        if userId == nil {
                            showLoginAlert = true
                        } else {
                            Task { await saveRecipe() }
                        }
                    }
                    .disabled(recipeName.isEmpty || recipeImageUrl.isEmpty || steps.contains { $0.stepDesc.isEmpty })
                }
            }
            .alert("Login Required", isPresented: $showLoginAlert) {
                Button("Go to Login") {
                    navigateToLogin = true
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Please log in to create a recipe.")
            }
            .navigationDestination(isPresented: $navigateToSuccess) {
                if let id = createdRecipeId {
                    SuccessScreen(
                        recipeId: id,
                        onAddAnother: {
                            clearForm()
                            navigateToSuccess = false
                        },
                        onView: {
                            selectedRecipeId = id
                            navigateToSuccess = false
                            navigateToDetail = true
                        }
                    )
                }
            }
            .navigationDestination(isPresented: $navigateToDetail) {
                if let id = selectedRecipeId {
                    RecipeDetailView(recipeId: id)
                }
            }
        }
    }

    private func uploadImage(image: UIImage) async -> String? {
        guard let data = image.jpegData(compressionQuality: 0.7) else { return nil }

        var request = URLRequest(url: URL(string: API.uploadImageURL)!)
        request.httpMethod = "POST"

        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        var body = Data()
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"image.jpg\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(data)
        body.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)

        let (responseData, _) = try! await URLSession.shared.upload(for: request, from: body)
        let decoded = try? JSONDecoder().decode(UploadResponse.self, from: responseData)
        return decoded?.data.url
    }

    private func saveRecipe() async {
        guard let userId else { return }

        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy, HH:mm:ss"
        let now = formatter.string(from: Date())

        let ingredientData = ingredients.map {
            IngredientForRequest(name: $0.name, amount: $0.amount, category: $0.category)
        }

        let stepData = steps.map {
            RecipeStepForRequest(stepDesc: $0.stepDesc, stepImg: $0.stepImg)
        }

        let payload = CreateRecipeRequest(
            recipeName: recipeName,
            category: categories.firstIndex(of: category) ?? 0,
            recipePicture: recipeImageUrl,
            postTime: now,
            recipeType: categories.firstIndex(of: category) ?? 0,
            description: description,
            cookingTime: cookingTime,
            difficulty: difficulty,
            steps: stepData,
            ingredients: ingredientData,
            userId: userId
        )

        guard let encoded = try? JSONEncoder().encode(payload) else { return }
        var request = URLRequest(url: URL(string: API.createRecipeURL)!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = encoded

        let (responseData, _) = try! await URLSession.shared.data(for: request)
        if let decoded = try? JSONDecoder().decode(CreateRecipeResponse.self, from: responseData) {
            DispatchQueue.main.async {
                createdRecipeId = decoded.data.recipeId
                navigateToSuccess = true
            }
        }
    }

    private func clearForm() {
        recipeName = ""
        category = "Dinner"
        description = ""
        cookingTime = ""
        difficulty = 1
        steps = [RecipeStep(stepDesc: "", stepImg: "")]
        ingredients = [IngredientInput()]
        selectedImage = nil
        recipeImageUrl = ""
    }
}

struct SuccessScreen: View {
    let recipeId: Int
    let onAddAnother: () -> Void
    let onView: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "checkmark.circle.fill")
                .resizable()
                .frame(width: 80, height: 80)
                .foregroundColor(.green)
                .scaleEffect(1.1)
                .transition(.scale.combined(with: .opacity))
                .animation(.easeOut, value: recipeId)

            Text("Recipe Created Successfully!")
                .font(.title2)
                .bold()

            HStack(spacing: 24) {
                Button("Add Another") {
                    onAddAnother()
                }
                .buttonStyle(.bordered)

                Button("View Recipe") {
                    onView()
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding()
    }
}

private struct CreateRecipeResponse: Decodable {
    struct DataContent: Decodable {
        let recipeId: Int
    }
    let data: DataContent
}

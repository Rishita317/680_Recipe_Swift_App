// The user should be able to add their own recipe
// Should be a ble to upload a picture

import SwiftUI
import PhotosUI

struct CreateRecipeView: View {
    @State private var recipeName = ""
    @State private var category = "Dinner"
    @State private var description = ""
    @State private var cookingTime = ""
    @State private var difficulty = 1
    @State private var steps: [RecipeStep] = [RecipeStep(stepDesc: "", stepImg: "")]
    @State private var selectedImage: UIImage?
    @State private var photosPickerItem: PhotosPickerItem?
    
    let categories = ["Breakfast", "Lunch", "Dinner", "Dessert", "Snack"]
    let difficultyLevels = [1, 2, 3, 4, 5]
    
    var body: some View {
        NavigationStack {
            Form {
                // Recipe Photo Section
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
                            if let photosPickerItem,
                               let data = try? await photosPickerItem.loadTransferable(type: Data.self) {
                                if let image = UIImage(data: data) {
                                    selectedImage = image
                                }
                            }
                            photosPickerItem = nil
                        }
                    }
                }
                
                // Basic Info Section
                Section(header: Text("Basic Information")) {
                    TextField("Recipe Name", text: $recipeName)
                    
                    Picker("Category", selection: $category) {
                        ForEach(categories, id: \.self) { category in
                            Text(category)
                        }
                    }
                    
                    TextField("Cooking Time (e.g. 30min)", text: $cookingTime)
                    
                    Picker("Difficulty", selection: $difficulty) {
                        ForEach(difficultyLevels, id: \.self) { level in
                            Text("\(level)").tag(level)
                        }
                    }
                    
                    TextField("Description", text: $description, axis: .vertical)
                        .lineLimit(3...)
                }
                
                // Steps Section
                Section(header: Text("Preparation Steps")) {
                    ForEach(Array(steps.enumerated()), id: \.offset) { index, step in
                        VStack(alignment: .leading) {
                            Text("Step \(index + 1)")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            TextField("Step description", text: Binding(
                                get: { steps[index].stepDesc },
                                set: { steps[index].stepDesc = $0 }
                            ), axis: .vertical)
                            .lineLimit(3...)
                            
                            // You could add image upload for each step here if needed
                        }
                    }
                    
                    Button(action: addStep) {
                        Label("Add Step", systemImage: "plus")
                    }
                    
                    if steps.count > 1 {
                        Button(action: removeStep) {
                            Label("Remove Last Step", systemImage: "minus")
                                .foregroundColor(.red)
                        }
                    }
                }
            }
            .navigationTitle("Create Recipe")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        saveRecipe()
                    }
                    .disabled(recipeName.isEmpty || steps.contains(where: { $0.stepDesc.isEmpty }))
                }
            }
        }
    }
    
    private func addStep() {
        steps.append(RecipeStep(stepDesc: "", stepImg: ""))
    }
    
    private func removeStep() {
        if steps.count > 1 {
            steps.removeLast()
        }
    }
    
    private func saveRecipe() {
        // Convert UIImage to base64 string if needed for your API
        var imageString = ""
        if let selectedImage = selectedImage,
           let imageData = selectedImage.jpegData(compressionQuality: 0.7) {
            imageString = imageData.base64EncodedString()
        }
        
        // Create the recipe object
        let newRecipe = Recipe(
            recipeId: 0, // Will be assigned by server
            recipeName: recipeName,
            category: category,
            rating: 0.0, // Default rating
            recipePicture: imageString,
            createTime: getCurrentDateTimeString(),
            creatorId: 1, // Replace with actual user ID
            modifyTime: getCurrentDateTimeString(),
            postTime: nil,
            recipeType: 1, // Default type
            status: 1, // Active status
            description: description.isEmpty ? nil : description,
            cookingTime: cookingTime.isEmpty ? nil : cookingTime,
            difficulty: difficulty,
            steps: steps
        )
        
        // Here you would send the recipe to your backend
        print("Saving recipe: \(newRecipe)")
        
        // API call would go here
        // await saveRecipeToAPI(recipe: newRecipe)
    }
    
    private func getCurrentDateTimeString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter.string(from: Date())
    }
}

// Preview
#Preview {
    CreateRecipeView()
}

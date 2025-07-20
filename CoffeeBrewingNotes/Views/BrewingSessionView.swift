import SwiftUI
import CoreData

struct BrewingSessionView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Coffee.name, ascending: true)],
        animation: .default)
    private var coffees: FetchedResults<Coffee>
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Recipe.usageCount, ascending: false)],
        animation: .default)
    private var recipes: FetchedResults<Recipe>
    
    @State private var selectedCoffee: Coffee?
    @State private var selectedRecipe: Recipe?
    @State private var notes = ""
    @State private var rating: Int = 0
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Select Coffee")) {
                    if coffees.isEmpty {
                        Text("No coffees available. Add some coffees first!")
                            .foregroundColor(.secondary)
                    } else {
                        Picker("Coffee", selection: $selectedCoffee) {
                            Text("Select a coffee").tag(Coffee?.none)
                            ForEach(Array(coffees), id: \.self) { coffee in
                                Text("\(coffee.wrappedName) - \(coffee.wrappedRoaster)")
                                    .tag(Coffee?.some(coffee))
                            }
                        }
                    }
                }
                
                Section(header: Text("Select Recipe")) {
                    if recipes.isEmpty {
                        Text("No recipes available. Add some recipes first!")
                            .foregroundColor(.secondary)
                    } else {
                        Picker("Recipe", selection: $selectedRecipe) {
                            Text("Select a recipe").tag(Recipe?.none)
                            ForEach(Array(recipes), id: \.self) { recipe in
                                VStack(alignment: .leading) {
                                    Text("\(recipe.wrappedName)")
                                        .font(.headline)
                                    Text("\(recipe.wrappedBrewingMethod) - Used \(recipe.usageCount) times")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                .tag(Recipe?.some(recipe))
                            }
                        }
                    }
                }
                
                if let recipe = selectedRecipe {
                    RecipeDetailsSection(recipe: recipe)
                }
                
                Section(header: Text("Brewing Notes")) {
                    TextEditor(text: $notes)
                        .frame(minHeight: 100)
                    
                    VStack(alignment: .leading) {
                        Text("Rating (Optional)")
                            .font(.headline)
                        
                        HStack {
                            ForEach(1...5, id: \.self) { star in
                                Button(action: {
                                    rating = star
                                }) {
                                    Image(systemName: star <= rating ? "star.fill" : "star")
                                        .foregroundColor(star <= rating ? .yellow : .gray)
                                        .font(.title2)
                                }
                            }
                            
                            if rating > 0 {
                                Button("Clear") {
                                    rating = 0
                                }
                                .font(.caption)
                                .foregroundColor(.secondary)
                            }
                        }
                    }
                }
                
                Section {
                    Button("Save Brewing Session") {
                        saveBrewingSession()
                    }
                    .disabled(selectedCoffee == nil || selectedRecipe == nil)
                }
            }
            .navigationTitle("New Brew Session")
            .alert("Session Saved", isPresented: $showingAlert) {
                Button("OK") {
                    resetForm()
                }
            } message: {
                Text(alertMessage)
            }
        }
    }
    
    private func saveBrewingSession() {
        guard let coffee = selectedCoffee,
              let recipe = selectedRecipe else { return }
        
        let persistence = PersistenceController.shared
        let _ = persistence.createBrewingNote(
            coffee: coffee,
            recipe: recipe,
            notes: notes,
            rating: Int16(rating)
        )
        
        alertMessage = "Brewing session saved successfully!"
        showingAlert = true
    }
    
    private func resetForm() {
        selectedCoffee = nil
        selectedRecipe = nil
        notes = ""
        rating = 0
    }
}

struct RecipeDetailsSection: View {
    let recipe: Recipe
    
    var body: some View {
        Section(header: Text("Recipe Details")) {
            VStack(spacing: 8) {
                HStack {
                    Text("Method:")
                        .fontWeight(.semibold)
                    Spacer()
                    Text(recipe.wrappedBrewingMethod)
                }
                
                HStack {
                    Text("Grinder:")
                        .fontWeight(.semibold)
                    Spacer()
                    Text("\(recipe.wrappedGrinder) - \(recipe.grindSize)")
                }
                
                HStack {
                    Text("Water Temp:")
                        .fontWeight(.semibold)
                    Spacer()
                    Text("\(recipe.waterTemp)°C")
                }
                
                HStack {
                    Text("Dose:")
                        .fontWeight(.semibold)
                    Spacer()
                    Text("\(recipe.dose, specifier: "%.1f")g")
                }
                
                HStack {
                    Text("Brew Time:")
                        .fontWeight(.semibold)
                    Spacer()
                    Text("\(recipe.brewTime)s")
                }
                
                if recipe.supportsBloom && recipe.bloomAmount > 0 {
                    HStack {
                        Text("Bloom:")
                            .fontWeight(.semibold)
                        Spacer()
                        Text("\(recipe.bloomAmount, specifier: "%.1f")g for \(recipe.bloomTime)s")
                    }
                }
                
                if recipe.isPourOver && recipe.secondPour > 0 {
                    HStack {
                        Text("Pours:")
                            .fontWeight(.semibold)
                        Spacer()
                        VStack(alignment: .trailing) {
                            Text("2nd: \(recipe.secondPour, specifier: "%.1f")g")
                            if recipe.thirdPour > 0 {
                                Text("3rd: \(recipe.thirdPour, specifier: "%.1f")g")
                            }
                            if recipe.fourthPour > 0 {
                                Text("4th: \(recipe.fourthPour, specifier: "%.1f")g")
                            }
                        }
                        .font(.caption)
                    }
                }
                
                if recipe.isEspresso {
                    HStack {
                        Text("Water Out:")
                            .fontWeight(.semibold)
                        Spacer()
                        Text("\(recipe.waterOut, specifier: "%.1f")g")
                    }
                }
                
                if recipe.isAeropress {
                    HStack {
                        Text("Type:")
                            .fontWeight(.semibold)
                        Spacer()
                        Text(recipe.wrappedAeropressType)
                    }
                    
                    if recipe.plungeTime > 0 {
                        HStack {
                            Text("Plunge Time:")
                                .fontWeight(.semibold)
                            Spacer()
                            Text("\(recipe.plungeTime)s")
                        }
                    }
                }
            }
            .font(.caption)
        }
    }
}

#Preview {
    BrewingSessionView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
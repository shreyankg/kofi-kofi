import SwiftUI
import CoreData

struct ContentView: View {
    var body: some View {
        TabView {
            SimpleCoffeeListView()
                .tabItem {
                    Image(systemName: "cup.and.saucer")
                    Text("Coffees")
                }
            
            RecipeTabView()
                .tabItem {
                    Image(systemName: "list.bullet.rectangle")
                    Text("Recipes")
                }
            
            BrewingTabView()
                .tabItem {
                    Image(systemName: "plus.circle")
                    Text("Brew")
                }
            
            NotesHistoryTabView()
                .tabItem {
                    Image(systemName: "book")
                    Text("Notes")
                }
            
            PreferencesView()
                .tabItem {
                    Image(systemName: "gear")
                    Text("Settings")
                }
        }
    }
}

struct RecipeTabView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Recipe.usageCount, ascending: false)],
        animation: .default)
    private var recipes: FetchedResults<Recipe>
    
    @State private var showingAddRecipe = false
    @State private var showingEditRecipe = false
    @State private var selectedRecipe: Recipe? = nil
    @State private var searchText = ""
    
    var filteredRecipes: [Recipe] {
        if searchText.isEmpty {
            return Array(recipes)
        } else {
            return recipes.filter { recipe in
                (recipe.name ?? "").localizedCaseInsensitiveContains(searchText) ||
                (recipe.brewingMethod ?? "").localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var body: some View {
        NavigationView {
            List {
                ForEach(filteredRecipes, id: \.self) { recipe in
                    RecipeRowView(recipe: recipe)
                        .onTapGesture {
                            selectedRecipe = recipe
                            showingEditRecipe = true
                        }
                }
                .onDelete(perform: deleteRecipes)
            }
            .navigationTitle("Recipes")
            .searchable(text: $searchText, prompt: "Search recipes...")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddRecipe = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddRecipe) {
                AddRecipeTabView()
            }
            .sheet(isPresented: $showingEditRecipe) {
                if let recipe = selectedRecipe {
                    EditRecipeTabView(recipe: recipe)
                }
            }
        }
    }
    
    private func deleteRecipes(offsets: IndexSet) {
        withAnimation {
            offsets.map { filteredRecipes[$0] }.forEach(viewContext.delete)
            
            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

struct RecipeRowView: View {
    let recipe: Recipe
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(recipe.wrappedBrewingMethod)
                    .font(.headline)
                    .lineLimit(1)
                Spacer()
                Text("\(recipe.usageCount) uses")
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(Color.blue.opacity(0.2))
                    .cornerRadius(4)
            }
            
            HStack {
                Text("\(recipe.wrappedGrindSize) • \(recipe.wrappedGrinder)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Spacer()
                Text("\(recipe.dose, specifier: "%.1f")g")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            HStack {
                Text("→ \(recipe.finalWeightString)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Spacer()
                Text("\(recipe.brewTime)s")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

struct AddRecipeTabView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    @StateObject private var preferencesManager = PreferencesManager.shared
    
    @State private var brewingMethod = ""
    @State private var grinder = ""
    @State private var grindSize = ""
    @State private var waterTemp: Int = 0
    @State private var dose: Double = 0.0
    @State private var brewTime: Int = 0
    
    // Pour-over specific
    @State private var bloomAmount: Double = 0.0
    @State private var bloomTime: Int = 0
    @State private var secondPour: Double = 0.0
    @State private var thirdPour: Double = 0.0
    @State private var fourthPour: Double = 0.0
    
    // Espresso specific
    @State private var waterOut: Double = 0.0
    
    // Aeropress specific
    @State private var aeropressType = "Normal"
    @State private var plungeTime: Int = 0
    
    private var selectedMethod: String {
        brewingMethod
    }
    
    private var isPourOver: Bool {
        selectedMethod.contains("V60") || selectedMethod.contains("Kalita")
    }
    
    private var isEspresso: Bool {
        selectedMethod.contains("Espresso")
    }
    
    private var isFrenchPress: Bool {
        selectedMethod.contains("French Press")
    }
    
    private var isAeropress: Bool {
        selectedMethod.contains("Aeropress")
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Recipe Details")) {
                    Picker("Brewing Method", selection: $brewingMethod) {
                        ForEach(brewingMethods, id: \.self) { method in
                            Text(method).tag(method)
                        }
                    }
                }
                
                Section(header: Text("Basic Parameters")) {
                    Picker("Grinder", selection: $grinder) {
                        ForEach(grinders, id: \.self) { grinder in
                            Text(grinder).tag(grinder)
                        }
                    }
                    
                    HStack {
                        Text("Grind Size")
                        Spacer()
                        TextField("e.g. 20, 3.2, coarse", text: $grindSize)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .frame(width: 120)
                    }
                    
                    HStack {
                        Text("Water Temp (°C)")
                        Spacer()
                        TextField("°C", value: $waterTemp, format: .number)
                            .keyboardType(.numberPad)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .frame(width: 80)
                    }
                    
                    HStack {
                        Text("Dose (g)")
                        Spacer()
                        TextField("Grams", value: $dose, format: .number)
                            .keyboardType(.decimalPad)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .frame(width: 80)
                    }
                    
                    HStack {
                        Text("Brew Time (s)")
                        Spacer()
                        TextField("Seconds", value: $brewTime, format: .number)
                            .keyboardType(.numberPad)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .frame(width: 80)
                    }
                }
                
                // Method-specific sections
                if isPourOver {
                    PourOverTabSection(
                        bloomAmount: $bloomAmount,
                        bloomTime: $bloomTime,
                        secondPour: $secondPour,
                        thirdPour: $thirdPour,
                        fourthPour: $fourthPour
                    )
                } else if isEspresso {
                    EspressoTabSection(waterOut: $waterOut)
                } else if isFrenchPress {
                    FrenchPressTabSection(
                        bloomAmount: $bloomAmount,
                        bloomTime: $bloomTime,
                        secondPour: $secondPour
                    )
                } else if isAeropress {
                    AeropressTabSection(
                        aeropressType: $aeropressType,
                        bloomAmount: $bloomAmount,
                        bloomTime: $bloomTime,
                        secondPour: $secondPour,
                        plungeTime: $plungeTime
                    )
                }
            }
            .navigationTitle("Add Recipe")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                // Initialize defaults from preferences
                if brewingMethod.isEmpty && !brewingMethods.isEmpty {
                    brewingMethod = brewingMethods.first ?? ""
                }
                if grinder.isEmpty && !grinders.isEmpty {
                    grinder = grinders.first ?? ""
                }
                if waterTemp == 0 {
                    waterTemp = preferencesManager.defaultWaterTemp
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveRecipe()
                    }
                    .disabled(brewingMethod.isEmpty || grinder.isEmpty || grindSize.isEmpty || dose <= 0 || hasValidationErrors)
                }
            }
        }
    }
    
    private var brewingMethods: [String] {
        preferencesManager.enabledBrewingMethods
    }
    
    private var grinders: [String] {
        preferencesManager.enabledGrinders
    }
    
    private var hasValidationErrors: Bool {
        if supportsPours {
            if secondPour > 0 && secondPour <= bloomAmount { return true }
            if thirdPour > 0 && thirdPour <= secondPour { return true }
            if fourthPour > 0 && fourthPour <= thirdPour { return true }
        }
        return false
    }
    
    private var supportsPours: Bool {
        isPourOver || isFrenchPress || isAeropress
    }
    
    private func saveRecipe() {
        let recipe = Recipe(context: viewContext)
        recipe.id = UUID()
        recipe.name = nil // Name is now auto-generated
        recipe.brewingMethod = brewingMethod
        recipe.grinder = grinder
        recipe.grindSize = grindSize
        recipe.waterTemp = Int32(waterTemp)
        recipe.dose = dose
        recipe.brewTime = Int32(brewTime)
        recipe.usageCount = 0
        recipe.dateCreated = Date()
        
        // Set method-specific attributes
        if isPourOver || isFrenchPress || isAeropress {
            recipe.bloomAmount = bloomAmount
            recipe.bloomTime = Int32(bloomTime)
            recipe.secondPour = secondPour
        }
        
        if isPourOver {
            recipe.thirdPour = thirdPour
            recipe.fourthPour = fourthPour
        }
        
        if isEspresso {
            recipe.waterOut = waterOut
        }
        
        if isAeropress {
            recipe.aeropressType = aeropressType
            recipe.plungeTime = Int32(plungeTime)
        }
        
        do {
            try viewContext.save()
            dismiss()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
}

struct EditRecipeTabView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    @StateObject private var preferencesManager = PreferencesManager.shared
    
    let recipe: Recipe
    
    @State private var brewingMethod = ""
    @State private var grinder = ""
    @State private var grindSize = ""
    @State private var waterTemp: Int = 0
    @State private var dose: Double = 0.0
    @State private var brewTime: Int = 0
    
    // Pour-over specific
    @State private var bloomAmount: Double = 0.0
    @State private var bloomTime: Int = 0
    @State private var secondPour: Double = 0.0
    @State private var thirdPour: Double = 0.0
    @State private var fourthPour: Double = 0.0
    
    // Espresso specific
    @State private var waterOut: Double = 0.0
    
    // Aeropress specific
    @State private var aeropressType = "Normal"
    @State private var plungeTime: Int = 0
    
    private var selectedMethod: String {
        brewingMethod
    }
    
    private var isPourOver: Bool {
        selectedMethod.contains("V60") || selectedMethod.contains("Kalita")
    }
    
    private var isEspresso: Bool {
        selectedMethod.contains("Espresso")
    }
    
    private var isFrenchPress: Bool {
        selectedMethod.contains("French Press")
    }
    
    private var isAeropress: Bool {
        selectedMethod.contains("Aeropress")
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Recipe Details")) {
                    Picker("Brewing Method", selection: $brewingMethod) {
                        ForEach(brewingMethods, id: \.self) { method in
                            Text(method).tag(method)
                        }
                    }
                }
                
                Section(header: Text("Basic Parameters")) {
                    Picker("Grinder", selection: $grinder) {
                        ForEach(grinders, id: \.self) { grinder in
                            Text(grinder).tag(grinder)
                        }
                    }
                    
                    HStack {
                        Text("Grind Size")
                        Spacer()
                        TextField("e.g. 20, 3.2, coarse", text: $grindSize)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .frame(width: 120)
                    }
                    
                    HStack {
                        Text("Water Temp (°C)")
                        Spacer()
                        TextField("°C", value: $waterTemp, format: .number)
                            .keyboardType(.numberPad)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .frame(width: 80)
                    }
                    
                    HStack {
                        Text("Dose (g)")
                        Spacer()
                        TextField("Grams", value: $dose, format: .number)
                            .keyboardType(.decimalPad)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .frame(width: 80)
                    }
                    
                    HStack {
                        Text("Brew Time (s)")
                        Spacer()
                        TextField("Seconds", value: $brewTime, format: .number)
                            .keyboardType(.numberPad)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .frame(width: 80)
                    }
                }
                
                // Method-specific sections
                if isPourOver {
                    PourOverTabSection(
                        bloomAmount: $bloomAmount,
                        bloomTime: $bloomTime,
                        secondPour: $secondPour,
                        thirdPour: $thirdPour,
                        fourthPour: $fourthPour
                    )
                } else if isEspresso {
                    EspressoTabSection(waterOut: $waterOut)
                } else if isFrenchPress {
                    FrenchPressTabSection(
                        bloomAmount: $bloomAmount,
                        bloomTime: $bloomTime,
                        secondPour: $secondPour
                    )
                } else if isAeropress {
                    AeropressTabSection(
                        aeropressType: $aeropressType,
                        bloomAmount: $bloomAmount,
                        bloomTime: $bloomTime,
                        secondPour: $secondPour,
                        plungeTime: $plungeTime
                    )
                }
            }
            .navigationTitle("Edit Recipe")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                // Load recipe values
                brewingMethod = recipe.brewingMethod ?? ""
                grinder = recipe.grinder ?? ""
                grindSize = recipe.grindSize ?? ""
                waterTemp = Int(recipe.waterTemp)
                dose = recipe.dose
                brewTime = Int(recipe.brewTime)
                
                // Method-specific values
                bloomAmount = recipe.bloomAmount
                bloomTime = Int(recipe.bloomTime)
                secondPour = recipe.secondPour
                thirdPour = recipe.thirdPour
                fourthPour = recipe.fourthPour
                waterOut = recipe.waterOut
                aeropressType = recipe.aeropressType ?? "Normal"
                plungeTime = Int(recipe.plungeTime)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveRecipe()
                    }
                    .disabled(brewingMethod.isEmpty || grinder.isEmpty || grindSize.isEmpty || dose <= 0 || hasValidationErrors)
                }
            }
        }
    }
    
    private var brewingMethods: [String] {
        preferencesManager.enabledBrewingMethods
    }
    
    private var grinders: [String] {
        preferencesManager.enabledGrinders
    }
    
    private var hasValidationErrors: Bool {
        if supportsPours {
            if secondPour > 0 && secondPour <= bloomAmount { return true }
            if thirdPour > 0 && thirdPour <= secondPour { return true }
            if fourthPour > 0 && fourthPour <= thirdPour { return true }
        }
        return false
    }
    
    private var supportsPours: Bool {
        isPourOver || isFrenchPress || isAeropress
    }
    
    private func saveRecipe() {
        recipe.brewingMethod = brewingMethod
        recipe.grinder = grinder
        recipe.grindSize = grindSize
        recipe.waterTemp = Int32(waterTemp)
        recipe.dose = dose
        recipe.brewTime = Int32(brewTime)
        
        // Set method-specific attributes
        if isPourOver || isFrenchPress || isAeropress {
            recipe.bloomAmount = bloomAmount
            recipe.bloomTime = Int32(bloomTime)
            recipe.secondPour = secondPour
        }
        
        if isPourOver {
            recipe.thirdPour = thirdPour
            recipe.fourthPour = fourthPour
        }
        
        if isEspresso {
            recipe.waterOut = waterOut
        }
        
        if isAeropress {
            recipe.aeropressType = aeropressType
            recipe.plungeTime = Int32(plungeTime)
        }
        
        do {
            try viewContext.save()
            dismiss()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
}

struct BrewingTabView: View {
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
                                Text("\(coffee.name ?? "Unknown") - \(coffee.roaster ?? "Unknown")")
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
                                    Text("\(recipe.name ?? "Unknown")")
                                        .font(.headline)
                                    Text("\(recipe.brewingMethod ?? "Unknown") - Used \(recipe.usageCount) times")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                .tag(Recipe?.some(recipe))
                            }
                        }
                    }
                }
                
                if let recipe = selectedRecipe {
                    RecipeDetailsTabSection(recipe: recipe)
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

struct RecipeDetailsTabSection: View {
    let recipe: Recipe
    
    private var wrappedBrewingMethod: String {
        recipe.brewingMethod ?? "Unknown Method"
    }
    
    private var wrappedGrinder: String {
        recipe.grinder ?? "Unknown Grinder"
    }
    
    private var isPourOver: Bool {
        let method = wrappedBrewingMethod.lowercased()
        return method.contains("v60") || method.contains("kalita") || method.contains("chemex")
    }
    
    private var isEspresso: Bool {
        wrappedBrewingMethod.lowercased().contains("espresso")
    }
    
    private var isAeropress: Bool {
        wrappedBrewingMethod.lowercased().contains("aeropress")
    }
    
    private var supportsPours: Bool {
        isPourOver || wrappedBrewingMethod.lowercased().contains("french press") || isAeropress
    }
    
    var body: some View {
        Section(header: Text("Recipe Details")) {
            VStack(spacing: 8) {
                HStack {
                    Text("Method:")
                        .fontWeight(.semibold)
                    Spacer()
                    Text(wrappedBrewingMethod)
                }
                
                HStack {
                    Text("Grinder:")
                        .fontWeight(.semibold)
                    Spacer()
                    Text("\(wrappedGrinder) - \(recipe.wrappedGrindSize)")
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
                
                if supportsPours && recipe.bloomAmount > 0 {
                    HStack {
                        Text("Bloom:")
                            .fontWeight(.semibold)
                        Spacer()
                        Text("\(recipe.bloomAmount, specifier: "%.1f")g for \(recipe.bloomTime)s")
                    }
                }
                
                if isPourOver && recipe.secondPour > 0 {
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
                
                if isEspresso {
                    HStack {
                        Text("Water Out:")
                            .fontWeight(.semibold)
                        Spacer()
                        Text("\(recipe.waterOut, specifier: "%.1f")g")
                    }
                }
                
                if isAeropress {
                    HStack {
                        Text("Type:")
                            .fontWeight(.semibold)
                        Spacer()
                        Text(recipe.aeropressType ?? "Normal")
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

// Method-specific sections for Add Recipe
struct PourOverTabSection: View {
    @Binding var bloomAmount: Double
    @Binding var bloomTime: Int
    @Binding var secondPour: Double
    @Binding var thirdPour: Double
    @Binding var fourthPour: Double
    
    private var validationErrors: [String] {
        var errors: [String] = []
        
        if secondPour > 0 && secondPour <= bloomAmount {
            errors.append("2nd pour must be greater than bloom (\(String(format: "%.0f", bloomAmount))g)")
        }
        
        if thirdPour > 0 && thirdPour <= secondPour {
            errors.append("3rd pour must be greater than 2nd pour (\(String(format: "%.0f", secondPour))g)")
        }
        
        if fourthPour > 0 && fourthPour <= thirdPour {
            errors.append("4th pour must be greater than 3rd pour (\(String(format: "%.0f", thirdPour))g)")
        }
        
        return errors
    }
    
    var body: some View {
        Section(header: Text("Pour Schedule")) {
            HStack {
                Text("Bloom (g)")
                Spacer()
                TextField("Grams", value: $bloomAmount, format: .number)
                    .keyboardType(.decimalPad)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(width: 80)
            }
            
            HStack {
                Text("Bloom Time (s)")
                Spacer()
                TextField("Seconds", value: $bloomTime, format: .number)
                    .keyboardType(.numberPad)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(width: 80)
            }
            
            HStack {
                Text("2nd Pour (g)")
                Spacer()
                TextField("Grams", value: $secondPour, format: .number)
                    .keyboardType(.decimalPad)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(width: 80)
            }
            
            HStack {
                Text("3rd Pour (g)")
                Spacer()
                TextField("Grams", value: $thirdPour, format: .number)
                    .keyboardType(.decimalPad)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(width: 80)
            }
            
            HStack {
                Text("4th Pour (g)")
                Spacer()
                TextField("Grams", value: $fourthPour, format: .number)
                    .keyboardType(.decimalPad)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(width: 80)
            }
            
            // Display validation errors
            ForEach(validationErrors, id: \.self) { error in
                Text(error)
                    .font(.caption)
                    .foregroundColor(.red)
            }
        }
    }
}

struct EspressoTabSection: View {
    @Binding var waterOut: Double
    
    var body: some View {
        Section(header: Text("Espresso Parameters")) {
            HStack {
                Text("Water Out (g)")
                Spacer()
                TextField("Grams", value: $waterOut, format: .number)
                    .keyboardType(.decimalPad)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(width: 80)
            }
        }
    }
}

struct FrenchPressTabSection: View {
    @Binding var bloomAmount: Double
    @Binding var bloomTime: Int
    @Binding var secondPour: Double
    
    private var validationErrors: [String] {
        var errors: [String] = []
        
        if secondPour > 0 && secondPour <= bloomAmount {
            errors.append("2nd pour must be greater than bloom (\(String(format: "%.0f", bloomAmount))g)")
        }
        
        return errors
    }
    
    var body: some View {
        Section(header: Text("French Press Pour Schedule")) {
            HStack {
                Text("Bloom (g)")
                Spacer()
                TextField("Grams", value: $bloomAmount, format: .number)
                    .keyboardType(.decimalPad)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(width: 80)
            }
            
            HStack {
                Text("Bloom Time (s)")
                Spacer()
                TextField("Seconds", value: $bloomTime, format: .number)
                    .keyboardType(.numberPad)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(width: 80)
            }
            
            HStack {
                Text("2nd Pour (g)")
                Spacer()
                TextField("Grams", value: $secondPour, format: .number)
                    .keyboardType(.decimalPad)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(width: 80)
            }
            
            // Display validation errors
            ForEach(validationErrors, id: \.self) { error in
                Text(error)
                    .font(.caption)
                    .foregroundColor(.red)
            }
        }
    }
}

struct AeropressTabSection: View {
    @Binding var aeropressType: String
    @Binding var bloomAmount: Double
    @Binding var bloomTime: Int
    @Binding var secondPour: Double
    @Binding var plungeTime: Int
    
    private var aeropressTypes: [String] {
        ["Normal", "Inverted"]
    }
    
    private var validationErrors: [String] {
        var errors: [String] = []
        
        if secondPour > 0 && secondPour <= bloomAmount {
            errors.append("2nd pour must be greater than bloom (\(String(format: "%.0f", bloomAmount))g)")
        }
        
        return errors
    }
    
    var body: some View {
        Section(header: Text("Aeropress Parameters")) {
            Picker("Type", selection: $aeropressType) {
                ForEach(aeropressTypes, id: \.self) { type in
                    Text(type).tag(type)
                }
            }
            
            HStack {
                Text("Bloom (g)")
                Spacer()
                TextField("Grams", value: $bloomAmount, format: .number)
                    .keyboardType(.decimalPad)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(width: 80)
            }
            
            HStack {
                Text("Bloom Time (s)")
                Spacer()
                TextField("Seconds", value: $bloomTime, format: .number)
                    .keyboardType(.numberPad)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(width: 80)
            }
            
            HStack {
                Text("2nd Pour (g)")
                Spacer()
                TextField("Grams", value: $secondPour, format: .number)
                    .keyboardType(.decimalPad)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(width: 80)
            }
            
            HStack {
                Text("Plunge Time (s)")
                Spacer()
                TextField("Seconds", value: $plungeTime, format: .number)
                    .keyboardType(.numberPad)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(width: 80)
            }
            
            // Display validation errors
            ForEach(validationErrors, id: \.self) { error in
                Text(error)
                    .font(.caption)
                    .foregroundColor(.red)
            }
        }
    }
}

struct NotesHistoryTabView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \BrewingNote.dateCreated, ascending: false)],
        animation: .default)
    private var brewingNotes: FetchedResults<BrewingNote>
    
    @State private var searchText = ""
    @State private var selectedRatingFilter: Int = 0 // 0 = all ratings
    @State private var showingFilterOptions = false
    
    var filteredNotes: [BrewingNote] {
        var notes = Array(brewingNotes)
        
        // Filter by search text
        if !searchText.isEmpty {
            notes = notes.filter { note in
                (note.coffee?.name ?? "").localizedCaseInsensitiveContains(searchText) ||
                (note.recipe?.name ?? "").localizedCaseInsensitiveContains(searchText) ||
                (note.recipe?.brewingMethod ?? "").localizedCaseInsensitiveContains(searchText) ||
                (note.notes ?? "").localizedCaseInsensitiveContains(searchText)
            }
        }
        
        // Filter by rating
        if selectedRatingFilter > 0 {
            notes = notes.filter { $0.rating == selectedRatingFilter }
        }
        
        return notes
    }
    
    var body: some View {
        NavigationView {
            VStack {
                if brewingNotes.isEmpty {
                    ContentUnavailableView {
                        Label("No Brewing Notes", systemImage: "book")
                    } description: {
                        Text("Start brewing and rating your coffee to see your history here.")
                    }
                } else {
                    List {
                        ForEach(filteredNotes, id: \.self) { note in
                            BrewingNoteRowView(note: note)
                        }
                        .onDelete(perform: deleteNotes)
                    }
                    .searchable(text: $searchText, prompt: "Search notes, coffee, or recipes...")
                }
            }
            .navigationTitle("Brewing History")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingFilterOptions = true }) {
                        Image(systemName: selectedRatingFilter > 0 ? "line.3.horizontal.decrease.circle.fill" : "line.3.horizontal.decrease.circle")
                    }
                }
            }
            .sheet(isPresented: $showingFilterOptions) {
                FilterOptionsView(selectedRating: $selectedRatingFilter)
            }
        }
    }
    
    private func deleteNotes(offsets: IndexSet) {
        withAnimation {
            offsets.map { filteredNotes[$0] }.forEach(viewContext.delete)
            
            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

struct BrewingNoteRowView: View {
    let note: BrewingNote
    
    private var coffeeName: String {
        note.coffee?.name ?? "Unknown Coffee"
    }
    
    private var roasterName: String {
        note.coffee?.roaster ?? "Unknown Roaster"
    }
    
    private var recipeName: String {
        note.recipe?.name ?? "Unknown Recipe"
    }
    
    private var brewingMethod: String {
        note.recipe?.brewingMethod ?? "Unknown Method"
    }
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: note.dateCreated ?? Date())
    }
    
    private var ratingStars: String {
        guard note.rating > 0 else { return "No rating" }
        return String(repeating: "★", count: Int(note.rating)) + String(repeating: "☆", count: 5 - Int(note.rating))
    }
    
    private var hasNotes: Bool {
        !(note.notes ?? "").isEmpty
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Header with coffee and date
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(coffeeName)
                        .font(.headline)
                        .foregroundColor(.primary)
                    Text(roasterName)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 2) {
                    Text(formattedDate)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    // Rating display
                    if note.rating > 0 {
                        HStack(spacing: 1) {
                            ForEach(1...5, id: \.self) { star in
                                Image(systemName: star <= note.rating ? "star.fill" : "star")
                                    .foregroundColor(star <= note.rating ? .yellow : .gray)
                                    .font(.caption)
                            }
                        }
                    } else {
                        Text("No rating")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            // Recipe info
            HStack {
                Text(recipeName)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.blue)
                
                Text("•")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text(brewingMethod)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
            }
            
            // Notes preview (if available)
            if hasNotes {
                Text(note.notes ?? "")
                    .font(.caption)
                    .foregroundColor(.primary)
                    .lineLimit(3)
                    .padding(.top, 2)
            }
        }
        .padding(.vertical, 4)
    }
}

struct FilterOptionsView: View {
    @Binding var selectedRating: Int
    @Environment(\.dismiss) private var dismiss
    
    private let ratingOptions = [
        (0, "All Ratings"),
        (5, "5 Stars"),
        (4, "4 Stars"),
        (3, "3 Stars"),
        (2, "2 Stars"),
        (1, "1 Star")
    ]
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Filter by Rating")) {
                    ForEach(ratingOptions, id: \.0) { rating, title in
                        HStack {
                            Text(title)
                            
                            Spacer()
                            
                            if rating > 0 {
                                HStack(spacing: 1) {
                                    ForEach(1...5, id: \.self) { star in
                                        Image(systemName: star <= rating ? "star.fill" : "star")
                                            .foregroundColor(star <= rating ? .yellow : .gray)
                                            .font(.caption)
                                    }
                                }
                            }
                            
                            if selectedRating == rating {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.blue)
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            selectedRating = rating
                        }
                    }
                }
                
                Section {
                    Button("Clear All Filters") {
                        selectedRating = 0
                    }
                    .foregroundColor(.red)
                }
            }
            .navigationTitle("Filter Options")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct PreferencesView: View {
    @StateObject private var preferencesManager = PreferencesManager.shared
    @State private var showingAddBrewingMethod = false
    @State private var showingAddGrinder = false
    @State private var newBrewingMethod = ""
    @State private var newGrinder = ""
    
    var body: some View {
        NavigationView {
            Form {
                // Default Temperature Section
                Section(header: Text("Default Settings")) {
                    HStack {
                        Text("Default Water Temp (°C)")
                        Spacer()
                        TextField("Temperature", value: $preferencesManager.defaultWaterTemp, format: .number)
                            .keyboardType(.numberPad)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .frame(width: 80)
                            .onChange(of: preferencesManager.defaultWaterTemp) { _ in
                                preferencesManager.saveDefaultWaterTemp()
                            }
                    }
                }
                
                // Brewing Methods Section
                Section(header: Text("Brewing Methods")) {
                    ForEach(preferencesManager.allAvailableBrewingMethods, id: \.self) { method in
                        HStack {
                            Text(method)
                            Spacer()
                            if preferencesManager.customBrewingMethods.contains(method) {
                                Button("Remove") {
                                    preferencesManager.removeCustomBrewingMethod(method)
                                }
                                .foregroundColor(.red)
                                .font(.caption)
                            }
                            Toggle("", isOn: Binding(
                                get: { preferencesManager.isBrewingMethodEnabled(method) },
                                set: { _ in preferencesManager.toggleBrewingMethod(method) }
                            ))
                        }
                    }
                    
                    Button("Add Custom Brewing Method") {
                        showingAddBrewingMethod = true
                    }
                    .foregroundColor(.blue)
                }
                
                // Grinders Section
                Section(header: Text("Grinders")) {
                    ForEach(preferencesManager.allAvailableGrinders, id: \.self) { grinder in
                        HStack {
                            Text(grinder)
                            Spacer()
                            if preferencesManager.customGrinders.contains(grinder) {
                                Button("Remove") {
                                    preferencesManager.removeCustomGrinder(grinder)
                                }
                                .foregroundColor(.red)
                                .font(.caption)
                            }
                            Toggle("", isOn: Binding(
                                get: { preferencesManager.isGrinderEnabled(grinder) },
                                set: { _ in preferencesManager.toggleGrinder(grinder) }
                            ))
                        }
                    }
                    
                    Button("Add Custom Grinder") {
                        showingAddGrinder = true
                    }
                    .foregroundColor(.blue)
                }
                
                // Information Section
                Section(header: Text("Information")) {
                    Text("At least one brewing method and one grinder must remain enabled.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle("Settings")
            .alert("Add Brewing Method", isPresented: $showingAddBrewingMethod) {
                TextField("Method name", text: $newBrewingMethod)
                Button("Add") {
                    preferencesManager.addCustomBrewingMethod(newBrewingMethod)
                    newBrewingMethod = ""
                }
                Button("Cancel", role: .cancel) {
                    newBrewingMethod = ""
                }
            } message: {
                Text("Enter a new brewing method name")
            }
            .alert("Add Grinder", isPresented: $showingAddGrinder) {
                TextField("Grinder name", text: $newGrinder)
                Button("Add") {
                    preferencesManager.addCustomGrinder(newGrinder)
                    newGrinder = ""
                }
                Button("Cancel", role: .cancel) {
                    newGrinder = ""
                }
            } message: {
                Text("Enter a new grinder name")
            }
        }
    }
}

#Preview {
    ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
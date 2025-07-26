import SwiftUI
import CoreData

// Global helper function for ordinal suffixes
func getOrdinalSuffix(_ number: Int) -> String {
    switch number {
    case 1, 21, 31: return "st"
    case 2, 22, 32: return "nd"
    case 3, 23, 33: return "rd"
    default: return "th"
    }
}

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
            
            BrewingNotesTabView()
                .tabItem {
                    Image(systemName: "book.pages")
                    Text("Brewing")
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
        animation: .easeInOut(duration: 0.3))
    private var recipes: FetchedResults<Recipe>
    
    @State private var showingAddRecipe = false
    @State private var showingEditRecipe = false
    @State private var selectedRecipe: Recipe? = nil
    @State private var searchText = ""
    @State private var refreshID = UUID()
    
    var filteredRecipes: [Recipe] {
        if searchText.isEmpty {
            return Array(recipes)
        } else {
            return recipes.filter { recipe in
                recipe.wrappedName.localizedCaseInsensitiveContains(searchText) ||
                (recipe.brewingMethod ?? "").localizedCaseInsensitiveContains(searchText) ||
                (recipe.grinder ?? "").localizedCaseInsensitiveContains(searchText)
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
            .id(refreshID)
            .navigationTitle("Recipes")
            .searchable(text: $searchText, prompt: "Search recipes...")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddRecipe = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddRecipe, onDismiss: {
                // Trigger UI refresh when add sheet dismisses
                refreshID = UUID()
            }) {
                AddRecipeTabView()
            }
            .sheet(isPresented: $showingEditRecipe, onDismiss: {
                // Trigger UI refresh when edit sheet dismisses
                refreshID = UUID()
            }) {
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
    
    private var displayBrewingMethod: String {
        let method = recipe.wrappedBrewingMethod
        if Recipe.isAeropressMethod(method) && recipe.wrappedAeropressType == "Inverted" {
            return "\(method) (Inverted)"
        } else if recipe.isPourOver && recipe.pourCount > 0 {
            let pourText = recipe.pourCount == 1 ? "pour" : "pours"
            return "\(method) - \(recipe.pourCount) \(pourText)"
        }
        return method
    }
    
    private var formattedBrewTime: String {
        let totalSeconds = Int(recipe.brewTime)
        if totalSeconds >= 60 {
            let minutes = totalSeconds / 60
            let seconds = totalSeconds % 60
            return "\(minutes)m \(seconds)s"
        } else {
            return "\(totalSeconds)s"
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(displayBrewingMethod)
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
                Text(formattedBrewTime)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            HStack {
                Text("\(recipe.dose, specifier: "%.1f")g → \(recipe.finalWeightString)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Spacer()
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
    @State private var pours: [Double] = [0.0] // Start with 2nd pour
    
    // Espresso specific
    @State private var waterOut: Double = 0.0
    
    // Aeropress specific
    @State private var aeropressType = "Normal"
    @State private var plungeTime: Int = 0
    
    private var selectedMethod: String {
        brewingMethod
    }
    
    private var isPourOver: Bool {
        Recipe.isPourOverMethod(selectedMethod)
    }
    
    private var isEspresso: Bool {
        Recipe.isEspressoMethod(selectedMethod)
    }
    
    private var isFrenchPress: Bool {
        Recipe.isFrenchPressMethod(selectedMethod)
    }
    
    private var isAeropress: Bool {
        Recipe.isAeropressMethod(selectedMethod)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Equipment")) {
                    Picker("Brewing Method", selection: $brewingMethod) {
                        ForEach(brewingMethods, id: \.self) { method in
                            Text(method).tag(method)
                        }
                    }
                    
                    Picker("Grinder", selection: $grinder) {
                        ForEach(grinders, id: \.self) { grinder in
                            Text(grinder).tag(grinder)
                        }
                    }
                }
                
                Section(header: Text("Basic Parameters")) {
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
                }
                
                // Method-specific sections
                if isPourOver {
                    PourOverTabSection(
                        bloomAmount: $bloomAmount,
                        bloomTime: $bloomTime,
                        pours: $pours
                    )
                } else if isEspresso {
                    EspressoTabSection(waterOut: $waterOut)
                } else if isFrenchPress {
                    FrenchPressTabSection(
                        bloomAmount: $bloomAmount,
                        bloomTime: $bloomTime,
                        secondPour: Binding(
                            get: { pours.first ?? 0.0 },
                            set: { newValue in
                                if pours.isEmpty {
                                    pours = [newValue]
                                } else {
                                    pours[0] = newValue
                                }
                            }
                        )
                    )
                } else if isAeropress {
                    AeropressTabSection(
                        aeropressType: $aeropressType,
                        bloomAmount: $bloomAmount,
                        bloomTime: $bloomTime,
                        secondPour: Binding(
                            get: { pours.first ?? 0.0 },
                            set: { newValue in
                                if pours.isEmpty {
                                    pours = [newValue]
                                } else {
                                    pours[0] = newValue
                                }
                            }
                        ),
                        plungeTime: $plungeTime
                    )
                }
                
                // Brew Time Section - Always last
                Section(header: Text("Timing")) {
                    HStack {
                        Text("Brew Time (s)")
                        Spacer()
                        TextField("Seconds", value: $brewTime, format: .number)
                            .keyboardType(.numberPad)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .frame(width: 80)
                    }
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
                // Ensure we have at least one pour for pour-over methods
                if pours.isEmpty {
                    pours = [0.0]
                }
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
    
    private var brewingMethods: [String] {
        preferencesManager.enabledBrewingMethods
    }
    
    private var grinders: [String] {
        preferencesManager.enabledGrinders
    }
    
    private var hasValidationErrors: Bool {
        if supportsPours && isPourOver {
            for (index, pour) in pours.enumerated() {
                if pour > 0 {
                    let previousAmount = index == 0 ? bloomAmount : pours[index - 1]
                    if pour <= previousAmount {
                        return true
                    }
                }
            }
        }
        return false
    }
    
    private var supportsPours: Bool {
        Recipe.supportsPours(selectedMethod)
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
            
            // Set pours from dynamic array (support up to 10 pours)
            recipe.secondPour = pours.indices.contains(0) ? pours[0] : 0.0
            if isPourOver {
                recipe.thirdPour = pours.indices.contains(1) ? pours[1] : 0.0
                recipe.fourthPour = pours.indices.contains(2) ? pours[2] : 0.0
                recipe.fifthPour = pours.indices.contains(3) ? pours[3] : 0.0
                recipe.sixthPour = pours.indices.contains(4) ? pours[4] : 0.0
                recipe.seventhPour = pours.indices.contains(5) ? pours[5] : 0.0
                recipe.eighthPour = pours.indices.contains(6) ? pours[6] : 0.0
                recipe.ninthPour = pours.indices.contains(7) ? pours[7] : 0.0
                recipe.tenthPour = pours.indices.contains(8) ? pours[8] : 0.0
            }
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
    @State private var pours: [Double] = []
    
    // Espresso specific
    @State private var waterOut: Double = 0.0
    
    // Aeropress specific
    @State private var aeropressType = "Normal"
    @State private var plungeTime: Int = 0
    
    private var selectedMethod: String {
        brewingMethod
    }
    
    private var isPourOver: Bool {
        Recipe.isPourOverMethod(selectedMethod)
    }
    
    private var isEspresso: Bool {
        Recipe.isEspressoMethod(selectedMethod)
    }
    
    private var isFrenchPress: Bool {
        Recipe.isFrenchPressMethod(selectedMethod)
    }
    
    private var isAeropress: Bool {
        Recipe.isAeropressMethod(selectedMethod)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Equipment")) {
                    Picker("Brewing Method", selection: $brewingMethod) {
                        ForEach(brewingMethods, id: \.self) { method in
                            Text(method).tag(method)
                        }
                    }
                    
                    Picker("Grinder", selection: $grinder) {
                        ForEach(grinders, id: \.self) { grinder in
                            Text(grinder).tag(grinder)
                        }
                    }
                }
                
                Section(header: Text("Basic Parameters")) {
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
                }
                
                // Method-specific sections
                if isPourOver {
                    PourOverTabSection(
                        bloomAmount: $bloomAmount,
                        bloomTime: $bloomTime,
                        pours: $pours
                    )
                } else if isEspresso {
                    EspressoTabSection(waterOut: $waterOut)
                } else if isFrenchPress {
                    FrenchPressTabSection(
                        bloomAmount: $bloomAmount,
                        bloomTime: $bloomTime,
                        secondPour: Binding(
                            get: { pours.first ?? 0.0 },
                            set: { newValue in
                                if pours.isEmpty {
                                    pours = [newValue]
                                } else {
                                    pours[0] = newValue
                                }
                            }
                        )
                    )
                } else if isAeropress {
                    AeropressTabSection(
                        aeropressType: $aeropressType,
                        bloomAmount: $bloomAmount,
                        bloomTime: $bloomTime,
                        secondPour: Binding(
                            get: { pours.first ?? 0.0 },
                            set: { newValue in
                                if pours.isEmpty {
                                    pours = [newValue]
                                } else {
                                    pours[0] = newValue
                                }
                            }
                        ),
                        plungeTime: $plungeTime
                    )
                }
                
                // Brew Time Section - Always last
                Section(header: Text("Timing")) {
                    HStack {
                        Text("Brew Time (s)")
                        Spacer()
                        TextField("Seconds", value: $brewTime, format: .number)
                            .keyboardType(.numberPad)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .frame(width: 80)
                    }
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
                
                // Load pours into dynamic array (support up to 10 pours)
                var loadedPours: [Double] = []
                if recipe.secondPour > 0 {
                    loadedPours.append(recipe.secondPour)
                }
                if recipe.thirdPour > 0 {
                    loadedPours.append(recipe.thirdPour)
                }
                if recipe.fourthPour > 0 {
                    loadedPours.append(recipe.fourthPour)
                }
                if recipe.fifthPour > 0 {
                    loadedPours.append(recipe.fifthPour)
                }
                if recipe.sixthPour > 0 {
                    loadedPours.append(recipe.sixthPour)
                }
                if recipe.seventhPour > 0 {
                    loadedPours.append(recipe.seventhPour)
                }
                if recipe.eighthPour > 0 {
                    loadedPours.append(recipe.eighthPour)
                }
                if recipe.ninthPour > 0 {
                    loadedPours.append(recipe.ninthPour)
                }
                if recipe.tenthPour > 0 {
                    loadedPours.append(recipe.tenthPour)
                }
                // Ensure at least one pour for pour-over methods
                if loadedPours.isEmpty {
                    loadedPours = [0.0]
                }
                pours = loadedPours
                
                waterOut = recipe.waterOut
                aeropressType = recipe.aeropressType ?? "Normal"
                plungeTime = Int(recipe.plungeTime)
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
    
    private var brewingMethods: [String] {
        preferencesManager.enabledBrewingMethods
    }
    
    private var grinders: [String] {
        preferencesManager.enabledGrinders
    }
    
    private var hasValidationErrors: Bool {
        if supportsPours && isPourOver {
            for (index, pour) in pours.enumerated() {
                if pour > 0 {
                    let previousAmount = index == 0 ? bloomAmount : pours[index - 1]
                    if pour <= previousAmount {
                        return true
                    }
                }
            }
        }
        return false
    }
    
    private var supportsPours: Bool {
        Recipe.supportsPours(selectedMethod)
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
            
            // Set pours from dynamic array (support up to 10 pours)
            recipe.secondPour = pours.indices.contains(0) ? pours[0] : 0.0
            if isPourOver {
                recipe.thirdPour = pours.indices.contains(1) ? pours[1] : 0.0
                recipe.fourthPour = pours.indices.contains(2) ? pours[2] : 0.0
                recipe.fifthPour = pours.indices.contains(3) ? pours[3] : 0.0
                recipe.sixthPour = pours.indices.contains(4) ? pours[4] : 0.0
                recipe.seventhPour = pours.indices.contains(5) ? pours[5] : 0.0
                recipe.eighthPour = pours.indices.contains(6) ? pours[6] : 0.0
                recipe.ninthPour = pours.indices.contains(7) ? pours[7] : 0.0
                recipe.tenthPour = pours.indices.contains(8) ? pours[8] : 0.0
            }
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
            
            // Ensure UI reflects changes by processing pending changes and refreshing
            viewContext.processPendingChanges()
            
            // Post notification to force UI refresh
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: .NSManagedObjectContextDidSave, object: viewContext)
            }
            
            dismiss()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
}

struct BrewingNotesTabView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \BrewingNote.dateCreated, ascending: false)],
        animation: .easeInOut(duration: 0.3))
    private var brewingNotes: FetchedResults<BrewingNote>
    
    @State private var showingAddNote = false
    @State private var showingEditNote = false
    @State private var showingNoteDetail = false
    @State private var selectedNote: BrewingNote? = nil
    @State private var searchText = ""
    @State private var selectedRatingFilter: Int = 0 // 0 = all ratings
    @State private var showingFilterOptions = false
    @State private var refreshID = UUID()
    
    var filteredNotes: [BrewingNote] {
        var notes = Array(brewingNotes)
        
        // Filter by search text
        if !searchText.isEmpty {
            notes = notes.filter { note in
                (note.coffee?.name ?? "").localizedCaseInsensitiveContains(searchText) ||
                (note.recipe?.wrappedName ?? "").localizedCaseInsensitiveContains(searchText) ||
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
                        Label("No Brewing Notes", systemImage: "book.pages")
                    } description: {
                        Text("Start brewing and rating your coffee to see your history here.")
                    } actions: {
                        Button("Start Brewing") {
                            showingAddNote = true
                        }
                        .buttonStyle(.borderedProminent)
                    }
                } else {
                    List {
                        ForEach(filteredNotes, id: \.self) { note in
                            BrewingNoteRowView(note: note)
                                .onTapGesture {
                                    selectedNote = note
                                    showingNoteDetail = true
                                }
                        }
                        .onDelete(perform: deleteNotes)
                    }
                    .id(refreshID)
                    .searchable(text: $searchText, prompt: "Search notes, coffee, or recipes...")
                }
            }
            .navigationTitle("Brewing Notes")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { showingFilterOptions = true }) {
                        Image(systemName: selectedRatingFilter > 0 ? "line.3.horizontal.decrease.circle.fill" : "line.3.horizontal.decrease.circle")
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddNote = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingFilterOptions) {
                FilterOptionsView(selectedRating: $selectedRatingFilter)
            }
            .sheet(isPresented: $showingAddNote, onDismiss: {
                // Trigger UI refresh when add sheet dismisses
                refreshID = UUID()
            }) {
                AddBrewingNoteView()
            }
            .sheet(isPresented: $showingEditNote, onDismiss: {
                // Trigger UI refresh when edit sheet dismisses
                refreshID = UUID()
            }) {
                if let note = selectedNote {
                    EditBrewingNoteView(note: note)
                }
            }
            .sheet(isPresented: $showingNoteDetail, onDismiss: {
                // Trigger UI refresh when detail sheet dismisses
                refreshID = UUID()
            }) {
                if let note = selectedNote {
                    BrewingNoteView(note: note)
                }
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

struct AddBrewingNoteView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
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
                                    Text(formatRecipeDisplayName(for: recipe))
                                        .font(.headline)
                                    Text("Used \(recipe.usageCount) times")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                .tag(Recipe?.some(recipe))
                            }
                        }
                    }
                }
                
                if let recipe = selectedRecipe {
                    Section(header: Text("Recipe Details")) {
                        RecipeDetailView(recipe: recipe)
                    }
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
                                    // If tapping the same star that's already selected, clear the rating
                                    if rating == star {
                                        rating = 0
                                    } else {
                                        rating = star
                                    }
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
            }
            .navigationTitle("New Brew Session")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveBrewingSession()
                    }
                    .disabled(selectedCoffee == nil || selectedRecipe == nil)
                }
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
        
        dismiss()
    }
}

struct EditBrewingNoteView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Coffee.name, ascending: true)],
        animation: .default)
    private var coffees: FetchedResults<Coffee>
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Recipe.usageCount, ascending: false)],
        animation: .default)
    private var recipes: FetchedResults<Recipe>
    
    let note: BrewingNote
    
    @State private var selectedCoffee: Coffee?
    @State private var selectedRecipe: Recipe?
    @State private var notes = ""
    @State private var rating: Int = 0
    
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
                                    Text(formatRecipeDisplayName(for: recipe))
                                        .font(.headline)
                                    Text("Used \(recipe.usageCount) times")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                .tag(Recipe?.some(recipe))
                            }
                        }
                    }
                }
                
                if let recipe = selectedRecipe {
                    Section(header: Text("Recipe Details")) {
                        RecipeDetailView(recipe: recipe)
                    }
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
                                    // If tapping the same star that's already selected, clear the rating
                                    if rating == star {
                                        rating = 0
                                    } else {
                                        rating = star
                                    }
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
                
                Section(header: Text("Session Info")) {
                    HStack {
                        Text("Created:")
                            .fontWeight(.semibold)
                        Spacer()
                        Text(note.formattedDate)
                            .foregroundColor(.secondary)
                    }
                    .font(.caption)
                }
            }
            .navigationTitle("Edit Brew Session")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                // Load note values
                selectedCoffee = note.coffee
                selectedRecipe = note.recipe
                notes = note.notes ?? ""
                rating = Int(note.rating)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveBrewingNote()
                    }
                    .disabled(selectedCoffee == nil || selectedRecipe == nil)
                }
            }
        }
    }
    
    private func saveBrewingNote() {
        guard let coffee = selectedCoffee,
              let recipe = selectedRecipe else { return }
        
        note.coffee = coffee
        note.recipe = recipe
        note.notes = notes
        note.rating = Int16(rating)
        
        do {
            try viewContext.save()
            
            // Ensure UI reflects changes by processing pending changes and refreshing
            viewContext.processPendingChanges()
            
            // Post notification to force UI refresh
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: .NSManagedObjectContextDidSave, object: viewContext)
            }
            
            dismiss()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
}

// MARK: - New Detail Views

struct BrewingNoteView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    
    let note: BrewingNote
    @State private var showingEditNote = false
    @State private var refreshID = UUID()
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    // Coffee Information Section
                    CoffeeInfoSection(coffee: note.coffee)
                    
                    // Recipe Details Section
                    RecipeDetailView(recipe: note.recipe)
                    
                    // Brewing Notes Section
                    BrewingNotesSection(note: note)
                }
                .padding()
            }
            .navigationTitle("Brewing Session")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Edit") {
                        showingEditNote = true
                    }
                }
            }
            .sheet(isPresented: $showingEditNote, onDismiss: {
                refreshID = UUID()
            }) {
                EditBrewingNoteView(note: note)
            }
        }
        .id(refreshID)
    }
}

struct CoffeeInfoSection: View {
    let coffee: Coffee?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Coffee")
                .font(.headline)
                .fontWeight(.bold)
            
            if let coffee = coffee {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text("Name:")
                            .fontWeight(.semibold)
                            .font(.caption)
                        Spacer()
                        Text(coffee.wrappedName)
                            .font(.caption)
                    }
                    
                    HStack {
                        Text("Roaster:")
                            .fontWeight(.semibold)
                            .font(.caption)
                        Spacer()
                        Text(coffee.wrappedRoaster)
                            .font(.caption)
                    }
                    
                    HStack {
                        Text("Origin:")
                            .fontWeight(.semibold)
                            .font(.caption)
                        Spacer()
                        Text(coffee.wrappedOrigin)
                            .font(.caption)
                    }
                    
                    HStack {
                        Text("Processing:")
                            .fontWeight(.semibold)
                            .font(.caption)
                        Spacer()
                        Text(coffee.wrappedProcessing)
                            .font(.caption)
                    }
                    
                    HStack {
                        Text("Roast Level:")
                            .fontWeight(.semibold)
                            .font(.caption)
                        Spacer()
                        Text(coffee.wrappedRoastLevel)
                            .font(.caption)
                    }
                }
                .padding(8)
                .background(Color(.systemGray6))
                .cornerRadius(8)
            } else {
                Text("No coffee information available")
                    .foregroundColor(.secondary)
                    .italic()
            }
        }
    }
}

struct RecipeDetailView: View {
    let recipe: Recipe?
    
    private var wrappedBrewingMethod: String {
        recipe?.brewingMethod ?? "Unknown Method"
    }
    
    private var wrappedGrinder: String {
        recipe?.grinder ?? "Unknown Grinder"
    }
    
    private var isPourOver: Bool {
        guard let recipe = recipe else { return false }
        return Recipe.isPourOverMethod(recipe.wrappedBrewingMethod)
    }
    
    private var isFrenchPress: Bool {
        guard let recipe = recipe else { return false }
        return Recipe.isFrenchPressMethod(recipe.wrappedBrewingMethod)
    }
    
    private var isEspresso: Bool {
        guard let recipe = recipe else { return false }
        return Recipe.isEspressoMethod(recipe.wrappedBrewingMethod)
    }
    
    private var isAeropress: Bool {
        guard let recipe = recipe else { return false }
        return Recipe.isAeropressMethod(recipe.wrappedBrewingMethod)
    }
    
    private var supportsPours: Bool {
        guard let recipe = recipe else { return false }
        return Recipe.supportsPours(recipe.wrappedBrewingMethod)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Recipe")
                .font(.headline)
                .fontWeight(.bold)
            
            if let recipe = recipe {
                VStack(alignment: .leading, spacing: 4) {
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
                    
                    // Method-specific details
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
                            VStack(alignment: .trailing, spacing: 2) {
                                if recipe.secondPour > 0 {
                                    Text("2nd: \(recipe.secondPour, specifier: "%.1f")g")
                                        .font(.caption)
                                }
                                if recipe.thirdPour > 0 {
                                    Text("3rd: \(recipe.thirdPour, specifier: "%.1f")g")
                                        .font(.caption)
                                }
                                if recipe.fourthPour > 0 {
                                    Text("4th: \(recipe.fourthPour, specifier: "%.1f")g")
                                        .font(.caption)
                                }
                                if recipe.fifthPour > 0 {
                                    Text("5th: \(recipe.fifthPour, specifier: "%.1f")g")
                                        .font(.caption)
                                }
                                if recipe.sixthPour > 0 {
                                    Text("6th: \(recipe.sixthPour, specifier: "%.1f")g")
                                        .font(.caption)
                                }
                                if recipe.seventhPour > 0 {
                                    Text("7th: \(recipe.seventhPour, specifier: "%.1f")g")
                                        .font(.caption)
                                }
                                if recipe.eighthPour > 0 {
                                    Text("8th: \(recipe.eighthPour, specifier: "%.1f")g")
                                        .font(.caption)
                                }
                                if recipe.ninthPour > 0 {
                                    Text("9th: \(recipe.ninthPour, specifier: "%.1f")g")
                                        .font(.caption)
                                }
                                if recipe.tenthPour > 0 {
                                    Text("10th: \(recipe.tenthPour, specifier: "%.1f")g")
                                        .font(.caption)
                                }
                            }
                        }
                    }
                    
                    if isEspresso && recipe.waterOut > 0 {
                        HStack {
                            Text("Water Out:")
                                .fontWeight(.semibold)
                            Spacer()
                            Text("\(recipe.waterOut, specifier: "%.1f")g")
                        }
                    }
                    
                    if isAeropress {
                        if !recipe.wrappedAeropressType.isEmpty {
                            HStack {
                                Text("Type:")
                                    .fontWeight(.semibold)
                                Spacer()
                                Text(recipe.wrappedAeropressType)
                            }
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
                    
                    // Brew Time - Always last
                    HStack {
                        Text("Brew Time:")
                            .fontWeight(.semibold)
                        Spacer()
                        Text("\(recipe.brewTime)s")
                    }
                }
                .font(.caption)
                .padding(8)
                .background(Color(.systemGray6))
                .cornerRadius(8)
            } else {
                Text("No recipe information available")
                    .foregroundColor(.secondary)
                    .italic()
            }
        }
    }
}

struct BrewingNotesSection: View {
    let note: BrewingNote
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Notes")
                .font(.headline)
                .fontWeight(.bold)
            
            VStack(alignment: .leading, spacing: 4) {
                if note.rating > 0 {
                    HStack {
                        Text("Rating:")
                            .fontWeight(.semibold)
                            .font(.caption)
                        Spacer()
                        HStack(spacing: 2) {
                            ForEach(1...5, id: \.self) { star in
                                Image(systemName: star <= note.rating ? "star.fill" : "star")
                                    .foregroundColor(star <= note.rating ? .yellow : .gray)
                                    .font(.caption)
                            }
                        }
                    }
                }
                
                if !note.wrappedNotes.isEmpty {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Notes:")
                            .fontWeight(.semibold)
                            .font(.caption)
                        Text(note.wrappedNotes)
                            .font(.caption)
                    }
                } else {
                    Text("No notes recorded")
                        .foregroundColor(.secondary)
                        .italic()
                        .font(.caption)
                }
            }
            .padding(8)
            .background(Color(.systemGray6))
            .cornerRadius(8)
        }
    }
}


// Method-specific sections for Add Recipe
struct PourOverTabSection: View {
    @Binding var bloomAmount: Double
    @Binding var bloomTime: Int
    @Binding var pours: [Double]
    
    private var validationErrors: [String] {
        var errors: [String] = []
        
        for (index, pour) in pours.enumerated() {
            if pour > 0 {
                let previousAmount = index == 0 ? bloomAmount : pours[index - 1]
                let previousName = index == 0 ? "bloom (\(String(format: "%.0f", bloomAmount))g)" : "\(index + 1)\(getOrdinalSuffix(index + 1)) pour (\(String(format: "%.0f", previousAmount))g)"
                
                if pour <= previousAmount {
                    errors.append("\(index + 2)\(getOrdinalSuffix(index + 2)) pour must be greater than \(previousName)")
                }
            }
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
            
            // Dynamic pour fields
            ForEach(pours.indices, id: \.self) { index in
                HStack {
                    Text("\(index + 2)\(getOrdinalSuffix(index + 2)) Pour (g)")
                    Spacer()
                    TextField("Grams", value: $pours[index], format: .number)
                        .keyboardType(.decimalPad)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .frame(width: 80)
                    
                    // Show remove button for pours beyond the first (2nd pour is required)
                    if index > 0 {
                        Button(action: {
                            pours.remove(at: index)
                        }) {
                            Image(systemName: "minus.circle.fill")
                                .foregroundColor(.red)
                        }
                        .buttonStyle(BorderlessButtonStyle())
                    }
                }
            }
            
            // Add Pour button (limit to reasonable number of pours)
            if pours.count < 9 {
                Button(action: {
                    pours.append(0.0)
                }) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(.blue)
                        Text("Add Pour")
                    }
                }
                .buttonStyle(BorderlessButtonStyle())
            }
            
            // Display validation errors
            ForEach(validationErrors, id: \.self) { error in
                Text(error)
                    .font(.caption)
                    .foregroundColor(.red)
            }
        }
        .onAppear {
            // Ensure we have at least one pour (2nd pour)
            if pours.isEmpty {
                pours = [0.0]
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


struct BrewingNoteRowView: View {
    let note: BrewingNote
    
    private var coffeeName: String {
        note.coffee?.name ?? "Unknown Coffee"
    }
    
    private var roasterName: String {
        note.coffee?.roaster ?? "Unknown Roaster"
    }
    
    private var recipeName: String {
        guard let recipe = note.recipe else { return "Unknown Recipe" }
        return formatRecipeDisplayName(for: recipe)
    }
    
    private var grinder: String {
        note.recipe?.wrappedGrinder ?? "Unknown Grinder"
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
                
                Text(grinder)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
            }
            
            // Dose and final weight
            if let recipe = note.recipe {
                HStack {
                    Text("\(recipe.dose, specifier: "%.1f")g → \(recipe.finalWeightString)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Spacer()
                }
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

// MARK: - Helper Functions

private func formatRecipeDisplayName(for recipe: Recipe) -> String {
    let method = recipe.wrappedBrewingMethod
    if Recipe.isAeropressMethod(method) && recipe.wrappedAeropressType == "Inverted" {
        return "\(method) (Inverted)"
    } else if recipe.isPourOver && recipe.pourCount > 0 {
        let pourText = recipe.pourCount == 1 ? "pour" : "pours"
        return "\(method) - \(recipe.pourCount) \(pourText)"
    }
    return method
}

#Preview {
    ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
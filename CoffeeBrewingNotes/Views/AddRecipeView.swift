import SwiftUI

struct AddRecipeView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var name = ""
    @State private var brewingMethod = "V60-01"
    @State private var grinder = "Baratza Encore"
    @State private var grindSize: Int = 20
    @State private var waterTemp: Int = 93
    @State private var dose: Double = 20.0
    @State private var brewTime: Int = 240
    
    // Pour-over specific
    @State private var bloomAmount: Double = 40.0
    @State private var bloomTime: Int = 30
    @State private var secondPour: Double = 100.0
    @State private var thirdPour: Double = 180.0
    @State private var fourthPour: Double = 0.0
    
    // Espresso specific
    @State private var waterOut: Double = 40.0
    
    // Aeropress specific
    @State private var aeropressType = "Normal"
    @State private var plungeTime: Int = 30
    
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
                    TextField("Recipe Name", text: $name)
                    
                    Picker("Brewing Method", selection: $brewingMethod) {
                        ForEach(Recipe.brewingMethods, id: \.self) { method in
                            Text(method).tag(method)
                        }
                    }
                }
                
                Section(header: Text("Basic Parameters")) {
                    Picker("Grinder", selection: $grinder) {
                        ForEach(Recipe.grinders, id: \.self) { grinder in
                            Text(grinder).tag(grinder)
                        }
                    }
                    
                    HStack {
                        Text("Grind Size")
                        Spacer()
                        TextField("Grind Size", value: $grindSize, format: .number)
                            .keyboardType(.numberPad)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .frame(width: 80)
                    }
                    
                    HStack {
                        Text("Water Temperature")
                        Spacer()
                        TextField("°C", value: $waterTemp, format: .number)
                            .keyboardType(.numberPad)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .frame(width: 80)
                    }
                    
                    HStack {
                        Text("Dose")
                        Spacer()
                        TextField("Grams", value: $dose, format: .number)
                            .keyboardType(.decimalPad)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .frame(width: 80)
                    }
                    
                    HStack {
                        Text("Brew Time")
                        Spacer()
                        TextField("Seconds", value: $brewTime, format: .number)
                            .keyboardType(.numberPad)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .frame(width: 80)
                    }
                }
                
                // Method-specific sections
                if isPourOver {
                    PourOverSection(
                        bloomAmount: $bloomAmount,
                        bloomTime: $bloomTime,
                        secondPour: $secondPour,
                        thirdPour: $thirdPour,
                        fourthPour: $fourthPour
                    )
                } else if isEspresso {
                    EspressoSection(waterOut: $waterOut)
                } else if isFrenchPress {
                    FrenchPressSection(
                        bloomAmount: $bloomAmount,
                        bloomTime: $bloomTime,
                        secondPour: $secondPour
                    )
                } else if isAeropress {
                    AeropressSection(
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
                    .disabled(name.isEmpty)
                }
            }
        }
    }
    
    private func saveRecipe() {
        let recipe = Recipe(context: viewContext)
        recipe.id = UUID()
        recipe.name = name
        recipe.brewingMethod = brewingMethod
        recipe.grinder = grinder
        recipe.grindSize = Int32(grindSize)
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

struct PourOverSection: View {
    @Binding var bloomAmount: Double
    @Binding var bloomTime: Int
    @Binding var secondPour: Double
    @Binding var thirdPour: Double
    @Binding var fourthPour: Double
    
    var body: some View {
        Section(header: Text("Pour Schedule")) {
            HStack {
                Text("Bloom Amount")
                Spacer()
                TextField("Grams", value: $bloomAmount, format: .number)
                    .keyboardType(.decimalPad)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(width: 80)
            }
            
            HStack {
                Text("Bloom Time")
                Spacer()
                TextField("Seconds", value: $bloomTime, format: .number)
                    .keyboardType(.numberPad)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(width: 80)
            }
            
            HStack {
                Text("2nd Pour")
                Spacer()
                TextField("Grams", value: $secondPour, format: .number)
                    .keyboardType(.decimalPad)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(width: 80)
            }
            
            HStack {
                Text("3rd Pour")
                Spacer()
                TextField("Grams", value: $thirdPour, format: .number)
                    .keyboardType(.decimalPad)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(width: 80)
            }
            
            HStack {
                Text("4th Pour (Optional)")
                Spacer()
                TextField("Grams", value: $fourthPour, format: .number)
                    .keyboardType(.decimalPad)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(width: 80)
            }
        }
    }
}

struct EspressoSection: View {
    @Binding var waterOut: Double
    
    var body: some View {
        Section(header: Text("Espresso Parameters")) {
            HStack {
                Text("Water Out")
                Spacer()
                TextField("Grams", value: $waterOut, format: .number)
                    .keyboardType(.decimalPad)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(width: 80)
            }
        }
    }
}

struct FrenchPressSection: View {
    @Binding var bloomAmount: Double
    @Binding var bloomTime: Int
    @Binding var secondPour: Double
    
    var body: some View {
        Section(header: Text("French Press Pour Schedule")) {
            HStack {
                Text("Bloom Amount")
                Spacer()
                TextField("Grams", value: $bloomAmount, format: .number)
                    .keyboardType(.decimalPad)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(width: 80)
            }
            
            HStack {
                Text("Bloom Time")
                Spacer()
                TextField("Seconds", value: $bloomTime, format: .number)
                    .keyboardType(.numberPad)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(width: 80)
            }
            
            HStack {
                Text("2nd Pour")
                Spacer()
                TextField("Grams", value: $secondPour, format: .number)
                    .keyboardType(.decimalPad)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(width: 80)
            }
        }
    }
}

struct AeropressSection: View {
    @Binding var aeropressType: String
    @Binding var bloomAmount: Double
    @Binding var bloomTime: Int
    @Binding var secondPour: Double
    @Binding var plungeTime: Int
    
    var body: some View {
        Section(header: Text("Aeropress Parameters")) {
            Picker("Type", selection: $aeropressType) {
                ForEach(Recipe.aeropressTypes, id: \.self) { type in
                    Text(type).tag(type)
                }
            }
            
            HStack {
                Text("Bloom Amount")
                Spacer()
                TextField("Grams", value: $bloomAmount, format: .number)
                    .keyboardType(.decimalPad)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(width: 80)
            }
            
            HStack {
                Text("Bloom Time")
                Spacer()
                TextField("Seconds", value: $bloomTime, format: .number)
                    .keyboardType(.numberPad)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(width: 80)
            }
            
            HStack {
                Text("2nd Pour")
                Spacer()
                TextField("Grams", value: $secondPour, format: .number)
                    .keyboardType(.decimalPad)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(width: 80)
            }
            
            HStack {
                Text("Plunge Time")
                Spacer()
                TextField("Seconds", value: $plungeTime, format: .number)
                    .keyboardType(.numberPad)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(width: 80)
            }
        }
    }
}

#Preview {
    AddRecipeView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
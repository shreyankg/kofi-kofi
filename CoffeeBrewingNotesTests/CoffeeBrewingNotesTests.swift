import XCTest
import CoreData
@testable import CoffeeBrewingNotes

final class CoffeeBrewingNotesTests: XCTestCase {
    
    var persistenceController: PersistenceController!
    var context: NSManagedObjectContext!
    
    override func setUpWithError() throws {
        persistenceController = PersistenceController(inMemory: true)
        context = persistenceController.container.viewContext
    }
    
    override func tearDownWithError() throws {
        persistenceController = nil
        context = nil
    }
    
    // MARK: - Coffee Tests
    
    func testCoffeeCreation() throws {
        let coffee = Coffee(context: context)
        coffee.id = UUID()
        coffee.name = "Ethiopian Yirgacheffe"
        coffee.roaster = "Blue Bottle Coffee"
        coffee.processing = "Washed"
        coffee.roastLevel = "Light"
        coffee.origin = "Ethiopia"
        coffee.dateAdded = Date()
        
        try context.save()
        
        XCTAssertEqual(coffee.wrappedName, "Ethiopian Yirgacheffe")
        XCTAssertEqual(coffee.wrappedRoaster, "Blue Bottle Coffee")
        XCTAssertEqual(coffee.wrappedProcessing, "Washed")
        XCTAssertEqual(coffee.wrappedRoastLevel, "Light")
        XCTAssertEqual(coffee.wrappedOrigin, "Ethiopia")
    }
    
    func testCoffeeDefaults() throws {
        let coffee = Coffee(context: context)
        
        XCTAssertEqual(coffee.wrappedName, "Unknown Coffee")
        XCTAssertEqual(coffee.wrappedRoaster, "Unknown Roaster")
        XCTAssertEqual(coffee.wrappedProcessing, "Unknown")
        XCTAssertEqual(coffee.wrappedRoastLevel, "Medium")
        XCTAssertEqual(coffee.wrappedOrigin, "Unknown Origin")
    }
    
    func testCoffeeRoastLevelIndex() throws {
        let coffee = Coffee(context: context)
        coffee.roastLevel = "Medium Dark"
        
        XCTAssertEqual(coffee.roastLevelIndex, 3)
        
        coffee.roastLevelIndex = 1
        XCTAssertEqual(coffee.roastLevel, "Medium Light")
    }
    
    func testCoffeeRoastLevelOptions() throws {
        let expectedOptions = [
            "Light", "Medium Light", "Medium", "Medium Dark", "Dark", "Extra Dark"
        ]
        
        XCTAssertEqual(Coffee.roastLevelOptions, expectedOptions)
    }
    
    // MARK: - ProcessingMethod Tests
    
    func testProcessingMethodCreation() throws {
        let method = ProcessingMethod(context: context)
        method.id = UUID()
        method.name = "Washed"
        method.usageCount = 0
        method.dateCreated = Date()
        
        try context.save()
        
        XCTAssertEqual(method.wrappedName, "Washed")
        XCTAssertEqual(method.wrappedUsageCount, 0)
        XCTAssertNotNil(method.wrappedDateCreated)
    }
    
    func testProcessingMethodDefaults() throws {
        let method = ProcessingMethod(context: context)
        
        XCTAssertEqual(method.wrappedName, "Unknown")
        XCTAssertEqual(method.wrappedUsageCount, 0)
    }
    
    func testProcessingMethodUsageIncrement() throws {
        let method = ProcessingMethod(context: context)
        method.name = "Natural"
        method.usageCount = 2
        
        method.incrementUsageCount()
        
        XCTAssertEqual(method.usageCount, 3)
    }
    
    func testProcessingMethodFetchOrCreate() throws {
        // Test creating new method
        let newMethod = ProcessingMethod.fetchOrCreate(name: "Honey", context: context)
        XCTAssertEqual(newMethod.wrappedName, "Honey")
        XCTAssertEqual(newMethod.wrappedUsageCount, 0)
        
        // Test fetching existing method
        let existingMethod = ProcessingMethod.fetchOrCreate(name: "Honey", context: context)
        XCTAssertEqual(newMethod, existingMethod)
    }
    
    func testProcessingMethodSeedDefaults() throws {
        ProcessingMethod.seedDefaultMethods(context: context)
        
        let request: NSFetchRequest<ProcessingMethod> = ProcessingMethod.fetchRequest()
        let methods = try context.fetch(request)
        
        XCTAssertGreaterThanOrEqual(methods.count, 7)
        
        let methodNames = methods.map { $0.wrappedName }
        XCTAssertTrue(methodNames.contains("Washed"))
        XCTAssertTrue(methodNames.contains("Honey"))
        XCTAssertTrue(methodNames.contains("Natural"))
    }
    
    func testProcessingMethodSorting() throws {
        // Create methods with different usage counts
        let method1 = ProcessingMethod.fetchOrCreate(name: "Washed", context: context)
        method1.usageCount = 5
        
        let method2 = ProcessingMethod.fetchOrCreate(name: "Natural", context: context)
        method2.usageCount = 10
        
        let method3 = ProcessingMethod.fetchOrCreate(name: "Honey", context: context)
        method3.usageCount = 2
        
        try context.save()
        
        let sortedMethods = ProcessingMethod.getAllSorted(context: context)
        
        XCTAssertEqual(sortedMethods[0].wrappedName, "Natural")  // Highest usage
        XCTAssertEqual(sortedMethods[1].wrappedName, "Washed")   // Medium usage
        XCTAssertEqual(sortedMethods[2].wrappedName, "Honey")    // Lowest usage
    }
    
    // MARK: - Recipe Tests
    
    func testRecipeCreation() throws {
        let recipe = Recipe(context: context)
        recipe.id = UUID()
        recipe.name = "My V60 Recipe"
        recipe.brewingMethod = "V60-01"
        recipe.grinder = "Baratza Encore"
        recipe.grindSize = 20
        recipe.waterTemp = 93
        recipe.dose = 20.0
        recipe.brewTime = 240
        recipe.usageCount = 5
        recipe.dateCreated = Date()
        
        try context.save()
        
        XCTAssertEqual(recipe.wrappedName, "My V60 Recipe")
        XCTAssertEqual(recipe.wrappedBrewingMethod, "V60-01")
        XCTAssertEqual(recipe.wrappedGrinder, "Baratza Encore")
        XCTAssertEqual(recipe.grindSize, 20)
        XCTAssertEqual(recipe.waterTemp, 93)
        XCTAssertEqual(recipe.dose, 20.0)
        XCTAssertEqual(recipe.brewTime, 240)
        XCTAssertEqual(recipe.usageCount, 5)
    }
    
    func testRecipeMethodDetection() throws {
        let v60Recipe = Recipe(context: context)
        v60Recipe.brewingMethod = "V60-01"
        
        let espressoRecipe = Recipe(context: context)
        espressoRecipe.brewingMethod = "Espresso - Gaggia Classic Pro"
        
        let frenchPressRecipe = Recipe(context: context)
        frenchPressRecipe.brewingMethod = "French Press - 01"
        
        let aeropressRecipe = Recipe(context: context)
        aeropressRecipe.brewingMethod = "Aeropress"
        
        XCTAssertTrue(v60Recipe.isPourOver)
        XCTAssertFalse(v60Recipe.isEspresso)
        XCTAssertFalse(v60Recipe.isFrenchPress)
        XCTAssertFalse(v60Recipe.isAeropress)
        
        XCTAssertFalse(espressoRecipe.isPourOver)
        XCTAssertTrue(espressoRecipe.isEspresso)
        XCTAssertFalse(espressoRecipe.isFrenchPress)
        XCTAssertFalse(espressoRecipe.isAeropress)
        
        XCTAssertFalse(frenchPressRecipe.isPourOver)
        XCTAssertFalse(frenchPressRecipe.isEspresso)
        XCTAssertTrue(frenchPressRecipe.isFrenchPress)
        XCTAssertFalse(frenchPressRecipe.isAeropress)
        
        XCTAssertFalse(aeropressRecipe.isPourOver)
        XCTAssertFalse(aeropressRecipe.isEspresso)
        XCTAssertFalse(aeropressRecipe.isFrenchPress)
        XCTAssertTrue(aeropressRecipe.isAeropress)
    }
    
    func testRecipeFeatureSupport() throws {
        let v60Recipe = Recipe(context: context)
        v60Recipe.brewingMethod = "V60-01"
        
        let espressoRecipe = Recipe(context: context)
        espressoRecipe.brewingMethod = "Espresso - Gaggia Classic Pro"
        
        XCTAssertTrue(v60Recipe.supportsPours)
        XCTAssertTrue(v60Recipe.supportsBloom)
        
        XCTAssertFalse(espressoRecipe.supportsPours)
        XCTAssertFalse(espressoRecipe.supportsBloom)
    }
    
    func testRecipeUsageCountIncrement() throws {
        let recipe = Recipe(context: context)
        recipe.usageCount = 5
        
        recipe.incrementUsageCount()
        
        XCTAssertEqual(recipe.usageCount, 6)
    }
    
    // MARK: - BrewingNote Tests
    
    func testBrewingNoteCreation() throws {
        let coffee = Coffee(context: context)
        coffee.name = "Test Coffee"
        
        let recipe = Recipe(context: context)
        recipe.name = "Test Recipe"
        
        let brewingNote = BrewingNote(context: context)
        brewingNote.id = UUID()
        brewingNote.notes = "Great brew today!"
        brewingNote.rating = 4
        brewingNote.dateCreated = Date()
        brewingNote.coffee = coffee
        brewingNote.recipe = recipe
        
        try context.save()
        
        XCTAssertEqual(brewingNote.wrappedNotes, "Great brew today!")
        XCTAssertEqual(brewingNote.rating, 4)
        XCTAssertEqual(brewingNote.wrappedCoffeeName, "Test Coffee")
        XCTAssertEqual(brewingNote.wrappedRecipeName, "Test Recipe")
        XCTAssertTrue(brewingNote.hasRating)
    }
    
    func testBrewingNoteRatingStars() throws {
        let brewingNote = BrewingNote(context: context)
        brewingNote.rating = 3
        
        XCTAssertEqual(brewingNote.ratingStars, "★★★☆☆")
        
        brewingNote.rating = 5
        XCTAssertEqual(brewingNote.ratingStars, "★★★★★")
        
        brewingNote.rating = 0
        XCTAssertEqual(brewingNote.ratingStars, "☆☆☆☆☆")
        XCTAssertFalse(brewingNote.hasRating)
    }
    
    // MARK: - Persistence Tests
    
    func testPersistenceControllerCreateCoffee() throws {
        let coffee = persistenceController.createCoffee(
            name: "Blue Mountain",
            roaster: "Jamaican Blue",
            processing: "Washed",
            roastLevel: "Medium",
            origin: "Jamaica"
        )
        
        XCTAssertEqual(coffee.wrappedName, "Blue Mountain")
        XCTAssertEqual(coffee.wrappedRoaster, "Jamaican Blue")
        XCTAssertEqual(coffee.wrappedProcessing, "Washed")
        XCTAssertEqual(coffee.wrappedRoastLevel, "Medium")
        XCTAssertEqual(coffee.wrappedOrigin, "Jamaica")
        XCTAssertNotNil(coffee.id)
        XCTAssertNotNil(coffee.dateAdded)
    }
    
    func testPersistenceControllerCreateRecipe() throws {
        let recipe = persistenceController.createRecipe(
            name: "Test Recipe",
            brewingMethod: "V60-01",
            grinder: "Baratza Encore",
            grindSize: 20,
            waterTemp: 93,
            dose: 20.0,
            brewTime: 240
        )
        
        XCTAssertEqual(recipe.wrappedName, "Test Recipe")
        XCTAssertEqual(recipe.wrappedBrewingMethod, "V60-01")
        XCTAssertEqual(recipe.grindSize, 20)
        XCTAssertEqual(recipe.usageCount, 0)
        XCTAssertNotNil(recipe.id)
        XCTAssertNotNil(recipe.dateCreated)
    }
    
    func testPersistenceControllerCreateBrewingNote() throws {
        let coffee = persistenceController.createCoffee(
            name: "Test Coffee",
            roaster: "Test Roaster",
            processing: "Washed",
            roastLevel: "Medium",
            origin: "Test Origin"
        )
        
        let recipe = persistenceController.createRecipe(
            name: "Test Recipe",
            brewingMethod: "V60-01",
            grinder: "Baratza Encore",
            grindSize: 20,
            waterTemp: 93,
            dose: 20.0,
            brewTime: 240
        )
        
        let initialUsageCount = recipe.usageCount
        
        let brewingNote = persistenceController.createBrewingNote(
            coffee: coffee,
            recipe: recipe,
            notes: "Test notes",
            rating: 4
        )
        
        XCTAssertEqual(brewingNote.wrappedNotes, "Test notes")
        XCTAssertEqual(brewingNote.rating, 4)
        XCTAssertEqual(brewingNote.coffee, coffee)
        XCTAssertEqual(brewingNote.recipe, recipe)
        XCTAssertEqual(recipe.usageCount, initialUsageCount + 1)
        XCTAssertNotNil(brewingNote.id)
        XCTAssertNotNil(brewingNote.dateCreated)
    }
    
    // MARK: - Recipe Method-Specific Tests
    
    func testRecipeBrewingMethods() throws {
        let expectedMethods = [
            "V60-01", "V60-02", "Kalita Wave 155", 
            "Chemex 6-cup", "Espresso (Gaggia Classic Pro)", "French Press", "Aeropress"
        ]
        
        XCTAssertEqual(Recipe.brewingMethods, expectedMethods)
    }
    
    func testRecipeGrinders() throws {
        let expectedGrinders = [
            "Baratza Encore", "Turin DF64", "1Zpresso J-Ultra", "Other"
        ]
        
        XCTAssertEqual(Recipe.grinders, expectedGrinders)
    }
    
    func testRecipeAeropressTypes() throws {
        let expectedTypes = ["Normal", "Inverted"]
        
        XCTAssertEqual(Recipe.aeropressTypes, expectedTypes)
    }
    
    func testRecipeMethodSpecificParameters() throws {
        let recipe = Recipe(context: context)
        recipe.brewingMethod = "V60-01"
        recipe.bloomAmount = 40.0
        recipe.bloomTime = 30
        recipe.secondPour = 100.0
        recipe.thirdPour = 180.0
        recipe.fourthPour = 60.0
        
        XCTAssertTrue(recipe.isPourOver)
        XCTAssertTrue(recipe.supportsPours)
        XCTAssertTrue(recipe.supportsBloom)
        XCTAssertEqual(recipe.bloomAmount, 40.0)
        XCTAssertEqual(recipe.bloomTime, 30)
        XCTAssertEqual(recipe.secondPour, 100.0)
        XCTAssertEqual(recipe.thirdPour, 180.0)
        XCTAssertEqual(recipe.fourthPour, 60.0)
    }
    
    func testRecipeEspressoParameters() throws {
        let recipe = Recipe(context: context)
        recipe.brewingMethod = "Espresso"
        recipe.waterOut = 36.0
        
        XCTAssertTrue(recipe.isEspresso)
        XCTAssertFalse(recipe.supportsPours)
        XCTAssertFalse(recipe.supportsBloom)
        XCTAssertEqual(recipe.waterOut, 36.0)
    }
    
    func testRecipeAeropressParameters() throws {
        let recipe = Recipe(context: context)
        recipe.brewingMethod = "Aeropress"
        recipe.aeropressType = "Inverted"
        recipe.plungeTime = 30
        
        XCTAssertTrue(recipe.isAeropress)
        XCTAssertTrue(recipe.supportsPours)
        XCTAssertTrue(recipe.supportsBloom)
        XCTAssertEqual(recipe.wrappedAeropressType, "Inverted")
        XCTAssertEqual(recipe.plungeTime, 30)
    }
    
    // MARK: - BrewingNote Extension Tests
    
    func testBrewingNoteExtensions() throws {
        let coffee = Coffee(context: context)
        coffee.name = "Test Coffee"
        coffee.roaster = "Test Roaster"
        
        let recipe = Recipe(context: context)
        recipe.name = "Test Recipe"
        recipe.brewingMethod = "V60-01"
        
        let brewingNote = BrewingNote(context: context)
        brewingNote.notes = "Great brew with citrus notes"
        brewingNote.rating = 4
        brewingNote.dateCreated = Date()
        brewingNote.coffee = coffee
        brewingNote.recipe = recipe
        
        XCTAssertEqual(brewingNote.wrappedNotes, "Great brew with citrus notes")
        XCTAssertEqual(brewingNote.wrappedCoffeeName, "Test Coffee")
        XCTAssertEqual(brewingNote.wrappedRecipeName, "Test Recipe")
        XCTAssertEqual(brewingNote.wrappedRoaster, "Test Roaster")
        XCTAssertEqual(brewingNote.wrappedBrewingMethod, "V60-01")
        XCTAssertTrue(brewingNote.hasRating)
        XCTAssertTrue(brewingNote.hasNotes)
        XCTAssertEqual(brewingNote.ratingStars, "★★★★☆")
    }
    
    func testBrewingNoteSearchMatching() throws {
        let coffee = Coffee(context: context)
        coffee.name = "Ethiopian Yirgacheffe"
        coffee.roaster = "Blue Bottle"
        
        let recipe = Recipe(context: context)
        recipe.name = "V60 Recipe"
        recipe.brewingMethod = "V60-01"
        
        let brewingNote = BrewingNote(context: context)
        brewingNote.notes = "Bright citrus flavors"
        brewingNote.coffee = coffee
        brewingNote.recipe = recipe
        
        XCTAssertTrue(brewingNote.matchesSearchText("Ethiopian"))
        XCTAssertTrue(brewingNote.matchesSearchText("Blue"))
        XCTAssertTrue(brewingNote.matchesSearchText("V60"))
        XCTAssertTrue(brewingNote.matchesSearchText("citrus"))
        XCTAssertFalse(brewingNote.matchesSearchText("Jamaica"))
    }
    
    // MARK: - Relationship Tests
    
    func testCoffeeBrewingNotesRelationship() throws {
        let coffee = Coffee(context: context)
        coffee.name = "Test Coffee"
        
        let recipe = Recipe(context: context)
        recipe.name = "Test Recipe"
        
        let brewingNote1 = BrewingNote(context: context)
        brewingNote1.coffee = coffee
        brewingNote1.recipe = recipe
        brewingNote1.dateCreated = Date()
        
        let brewingNote2 = BrewingNote(context: context)
        brewingNote2.coffee = coffee
        brewingNote2.recipe = recipe
        brewingNote2.dateCreated = Date().addingTimeInterval(-3600) // 1 hour ago
        
        try context.save()
        
        let coffeeNotes = coffee.brewingNotesArray
        XCTAssertEqual(coffeeNotes.count, 2)
        XCTAssertEqual(coffeeNotes[0], brewingNote1) // Most recent first
        XCTAssertEqual(coffeeNotes[1], brewingNote2)
    }
    
    func testRecipeBrewingNotesRelationship() throws {
        let coffee = Coffee(context: context)
        coffee.name = "Test Coffee"
        
        let recipe = Recipe(context: context)
        recipe.name = "Test Recipe"
        
        let brewingNote = BrewingNote(context: context)
        brewingNote.coffee = coffee
        brewingNote.recipe = recipe
        
        try context.save()
        
        let recipeNotes = recipe.brewingNotesArray
        XCTAssertEqual(recipeNotes.count, 1)
        XCTAssertEqual(recipeNotes[0], brewingNote)
    }
    
    // MARK: - Coffee Analysis Tests
    
    func testCoffeeAverageRating() throws {
        let coffee = Coffee(context: context)
        coffee.name = "Test Coffee"
        
        let recipe = Recipe(context: context)
        recipe.name = "Test Recipe"
        
        // Add brewing notes with ratings
        let note1 = BrewingNote(context: context)
        note1.coffee = coffee
        note1.recipe = recipe
        note1.rating = 4
        
        let note2 = BrewingNote(context: context)
        note2.coffee = coffee
        note2.recipe = recipe
        note2.rating = 5
        
        let note3 = BrewingNote(context: context)
        note3.coffee = coffee
        note3.recipe = recipe
        note3.rating = 0 // No rating
        
        try context.save()
        
        XCTAssertEqual(coffee.averageRating, 4.5)
        XCTAssertTrue(coffee.hasRatings)
        XCTAssertEqual(coffee.brewingNotesCount, 3)
    }
    
    func testCoffeeDisplayHelpers() throws {
        let coffee = Coffee(context: context)
        coffee.name = "Ethiopian Yirgacheffe"
        coffee.roaster = "Blue Bottle"
        coffee.origin = "Ethiopia"
        coffee.processing = "Washed"
        coffee.roastLevel = "Light"
        
        XCTAssertEqual(coffee.displayName, "Ethiopian Yirgacheffe - Blue Bottle")
        XCTAssertEqual(coffee.detailText, "Ethiopia • Washed • Light")
    }
    
    // MARK: - PreferencesManager Tests
    
    func testPreferencesManagerInitialization() throws {
        // Clear existing defaults for clean test
        UserDefaults.standard.removeObject(forKey: "hasInitializedDefaults")
        UserDefaults.standard.removeObject(forKey: "enabledBrewingMethods")
        UserDefaults.standard.removeObject(forKey: "enabledGrinders")
        UserDefaults.standard.removeObject(forKey: "defaultWaterTemp")
        UserDefaults.standard.removeObject(forKey: "customBrewingMethods")
        UserDefaults.standard.removeObject(forKey: "customGrinders")
        
        let preferencesManager = PreferencesManager()
        
        // Test that defaults are properly initialized
        XCTAssertFalse(preferencesManager.enabledBrewingMethods.isEmpty)
        XCTAssertFalse(preferencesManager.enabledGrinders.isEmpty)
        XCTAssertEqual(preferencesManager.defaultWaterTemp, 93)
        XCTAssertTrue(preferencesManager.customBrewingMethods.isEmpty)
        XCTAssertTrue(preferencesManager.customGrinders.isEmpty)
    }
    
    func testBrewingMethodToggling() throws {
        let preferencesManager = PreferencesManager()
        
        // Ensure we have multiple methods enabled
        if preferencesManager.enabledBrewingMethods.count < 2 {
            preferencesManager.addCustomBrewingMethod("Test Method")
        }
        
        let initialCount = preferencesManager.enabledBrewingMethods.count
        let firstMethod = preferencesManager.enabledBrewingMethods.first!
        
        // Test disabling a method
        preferencesManager.toggleBrewingMethod(firstMethod)
        XCTAssertEqual(preferencesManager.enabledBrewingMethods.count, initialCount - 1)
        XCTAssertFalse(preferencesManager.isBrewingMethodEnabled(firstMethod))
        
        // Test re-enabling the method
        preferencesManager.toggleBrewingMethod(firstMethod)
        XCTAssertEqual(preferencesManager.enabledBrewingMethods.count, initialCount)
        XCTAssertTrue(preferencesManager.isBrewingMethodEnabled(firstMethod))
    }
    
    func testLastBrewingMethodCannotBeDisabled() throws {
        let preferencesManager = PreferencesManager()
        
        // Disable all but one brewing method
        let allMethods = preferencesManager.allAvailableBrewingMethods
        for method in allMethods.dropFirst() {
            if preferencesManager.isBrewingMethodEnabled(method) {
                preferencesManager.toggleBrewingMethod(method)
            }
        }
        
        // Try to disable the last method
        let lastMethod = preferencesManager.enabledBrewingMethods.first!
        preferencesManager.toggleBrewingMethod(lastMethod)
        
        // Should still have one method enabled
        XCTAssertEqual(preferencesManager.enabledBrewingMethods.count, 1)
        XCTAssertTrue(preferencesManager.isBrewingMethodEnabled(lastMethod))
    }
    
    func testGrinderToggling() throws {
        let preferencesManager = PreferencesManager()
        
        // Ensure we have multiple grinders enabled
        if preferencesManager.enabledGrinders.count < 2 {
            preferencesManager.addCustomGrinder("Test Grinder")
        }
        
        let initialCount = preferencesManager.enabledGrinders.count
        let firstGrinder = preferencesManager.enabledGrinders.first!
        
        // Test disabling a grinder
        preferencesManager.toggleGrinder(firstGrinder)
        XCTAssertEqual(preferencesManager.enabledGrinders.count, initialCount - 1)
        XCTAssertFalse(preferencesManager.isGrinderEnabled(firstGrinder))
        
        // Test re-enabling the grinder
        preferencesManager.toggleGrinder(firstGrinder)
        XCTAssertEqual(preferencesManager.enabledGrinders.count, initialCount)
        XCTAssertTrue(preferencesManager.isGrinderEnabled(firstGrinder))
    }
    
    func testLastGrinderCannotBeDisabled() throws {
        let preferencesManager = PreferencesManager()
        
        // Disable all but one grinder
        let allGrinders = preferencesManager.allAvailableGrinders
        for grinder in allGrinders.dropFirst() {
            if preferencesManager.isGrinderEnabled(grinder) {
                preferencesManager.toggleGrinder(grinder)
            }
        }
        
        // Try to disable the last grinder
        let lastGrinder = preferencesManager.enabledGrinders.first!
        preferencesManager.toggleGrinder(lastGrinder)
        
        // Should still have one grinder enabled
        XCTAssertEqual(preferencesManager.enabledGrinders.count, 1)
        XCTAssertTrue(preferencesManager.isGrinderEnabled(lastGrinder))
    }
    
    func testCustomBrewingMethodAddition() throws {
        let preferencesManager = PreferencesManager()
        let initialCount = preferencesManager.customBrewingMethods.count
        
        preferencesManager.addCustomBrewingMethod("Custom V60")
        
        XCTAssertEqual(preferencesManager.customBrewingMethods.count, initialCount + 1)
        XCTAssertTrue(preferencesManager.customBrewingMethods.contains("Custom V60"))
        XCTAssertTrue(preferencesManager.isBrewingMethodEnabled("Custom V60"))
        XCTAssertTrue(preferencesManager.allAvailableBrewingMethods.contains("Custom V60"))
    }
    
    func testCustomGrinderAddition() throws {
        let preferencesManager = PreferencesManager()
        let initialCount = preferencesManager.customGrinders.count
        
        preferencesManager.addCustomGrinder("Custom Grinder")
        
        XCTAssertEqual(preferencesManager.customGrinders.count, initialCount + 1)
        XCTAssertTrue(preferencesManager.customGrinders.contains("Custom Grinder"))
        XCTAssertTrue(preferencesManager.isGrinderEnabled("Custom Grinder"))
        XCTAssertTrue(preferencesManager.allAvailableGrinders.contains("Custom Grinder"))
    }
    
    func testCustomBrewingMethodRemoval() throws {
        let preferencesManager = PreferencesManager()
        
        // Add a custom method first
        preferencesManager.addCustomBrewingMethod("Test Method")
        XCTAssertTrue(preferencesManager.customBrewingMethods.contains("Test Method"))
        
        // Remove it
        preferencesManager.removeCustomBrewingMethod("Test Method")
        XCTAssertFalse(preferencesManager.customBrewingMethods.contains("Test Method"))
        XCTAssertFalse(preferencesManager.isBrewingMethodEnabled("Test Method"))
        XCTAssertFalse(preferencesManager.allAvailableBrewingMethods.contains("Test Method"))
    }
    
    func testCustomGrinderRemoval() throws {
        let preferencesManager = PreferencesManager()
        
        // Add a custom grinder first
        preferencesManager.addCustomGrinder("Test Grinder")
        XCTAssertTrue(preferencesManager.customGrinders.contains("Test Grinder"))
        
        // Remove it
        preferencesManager.removeCustomGrinder("Test Grinder")
        XCTAssertFalse(preferencesManager.customGrinders.contains("Test Grinder"))
        XCTAssertFalse(preferencesManager.isGrinderEnabled("Test Grinder"))
        XCTAssertFalse(preferencesManager.allAvailableGrinders.contains("Test Grinder"))
    }
    
    func testDuplicateCustomMethodsPrevention() throws {
        let preferencesManager = PreferencesManager()
        let initialCount = preferencesManager.customBrewingMethods.count
        
        preferencesManager.addCustomBrewingMethod("Unique Method")
        preferencesManager.addCustomBrewingMethod("Unique Method") // Try to add duplicate
        
        XCTAssertEqual(preferencesManager.customBrewingMethods.count, initialCount + 1)
    }
    
    func testDuplicateCustomGrindersPrevention() throws {
        let preferencesManager = PreferencesManager()
        let initialCount = preferencesManager.customGrinders.count
        
        preferencesManager.addCustomGrinder("Unique Grinder")
        preferencesManager.addCustomGrinder("Unique Grinder") // Try to add duplicate
        
        XCTAssertEqual(preferencesManager.customGrinders.count, initialCount + 1)
    }
    
    func testDefaultTemperatureSetting() throws {
        let preferencesManager = PreferencesManager()
        
        preferencesManager.defaultWaterTemp = 95
        preferencesManager.saveDefaultWaterTemp()
        
        // Create new instance to test persistence
        let newPreferencesManager = PreferencesManager()
        XCTAssertEqual(newPreferencesManager.defaultWaterTemp, 95)
    }
    
    func testPreventDefaultMethodDuplication() throws {
        let preferencesManager = PreferencesManager()
        let initialCount = preferencesManager.customBrewingMethods.count
        
        // Try to add a method that already exists in defaults
        preferencesManager.addCustomBrewingMethod("V60-01")
        
        // Should not be added to custom methods
        XCTAssertEqual(preferencesManager.customBrewingMethods.count, initialCount)
        XCTAssertFalse(preferencesManager.customBrewingMethods.contains("V60-01"))
    }
    
    func testPreventDefaultGrinderDuplication() throws {
        let preferencesManager = PreferencesManager()
        let initialCount = preferencesManager.customGrinders.count
        
        // Try to add a grinder that already exists in defaults
        preferencesManager.addCustomGrinder("Baratza Encore")
        
        // Should not be added to custom grinders
        XCTAssertEqual(preferencesManager.customGrinders.count, initialCount)
        XCTAssertFalse(preferencesManager.customGrinders.contains("Baratza Encore"))
    }
    
    func testEmptyStringHandling() throws {
        let preferencesManager = PreferencesManager()
        let initialMethodCount = preferencesManager.customBrewingMethods.count
        let initialGrinderCount = preferencesManager.customGrinders.count
        
        preferencesManager.addCustomBrewingMethod("")
        preferencesManager.addCustomBrewingMethod("   ")
        preferencesManager.addCustomGrinder("")
        preferencesManager.addCustomGrinder("   ")
        
        XCTAssertEqual(preferencesManager.customBrewingMethods.count, initialMethodCount)
        XCTAssertEqual(preferencesManager.customGrinders.count, initialGrinderCount)
    }
}
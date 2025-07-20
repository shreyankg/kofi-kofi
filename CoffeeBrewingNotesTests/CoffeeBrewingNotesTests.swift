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
            "V60-01", "V60-02", "V60-03", "Kalita Wave 155", "Kalita Wave 185", 
            "Chemex 6-cup", "Chemex 8-cup", "Espresso", "French Press", "Aeropress"
        ]
        
        XCTAssertEqual(Recipe.brewingMethods, expectedMethods)
    }
    
    func testRecipeGrinders() throws {
        let expectedGrinders = [
            "Baratza Encore", "Baratza Virtuoso+", "Baratza Vario", "Comandante C40", 
            "1Zpresso JX-Pro", "Hario Mini Mill", "Timemore C2", "Timemore C3", 
            "Fellow Ode", "Wilfa Uniform", "Hand grinder", "Other"
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
}
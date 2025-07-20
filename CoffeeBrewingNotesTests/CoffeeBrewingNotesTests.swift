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
    
    func testCoffeeProcessingOptions() throws {
        let expectedOptions = [
            "Washed", "Honey", "Natural", "Semi-Washed", "Pulped Natural", "Anaerobic", "Carbonic Maceration"
        ]
        
        XCTAssertEqual(Coffee.processingOptions, expectedOptions)
    }
    
    func testCoffeeRoastLevelOptions() throws {
        let expectedOptions = [
            "Light", "Medium Light", "Medium", "Medium Dark", "Dark", "Extra Dark"
        ]
        
        XCTAssertEqual(Coffee.roastLevelOptions, expectedOptions)
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
}
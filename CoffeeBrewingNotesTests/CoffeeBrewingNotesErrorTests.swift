import XCTest
import CoreData
@testable import CoffeeBrewingNotes

final class CoffeeBrewingNotesErrorTests: XCTestCase {
    
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
    
    // MARK: - Nil/Empty Data Handling Tests
    
    func testCoffeeNilPropertyHandling() throws {
        let coffee = Coffee(context: context)
        // Don't set any properties - test default values
        
        XCTAssertEqual(coffee.wrappedName, "Unknown Coffee")
        XCTAssertEqual(coffee.wrappedRoaster, "Unknown Roaster")
        XCTAssertEqual(coffee.wrappedProcessing, "Unknown")
        XCTAssertEqual(coffee.wrappedRoastLevel, "Medium")
        XCTAssertEqual(coffee.wrappedOrigin, "Unknown Origin")
        XCTAssertEqual(coffee.brewingNotesCount, 0)
        XCTAssertEqual(coffee.averageRating, 0.0)
        XCTAssertFalse(coffee.hasRatings)
    }
    
    func testRecipeNilPropertyHandling() throws {
        let recipe = Recipe(context: context)
        // Don't set any properties - test default values
        
        XCTAssertEqual(recipe.wrappedName, "Unknown Recipe")
        XCTAssertEqual(recipe.wrappedBrewingMethod, "Unknown Method")
        XCTAssertEqual(recipe.wrappedGrinder, "Unknown Grinder")
        XCTAssertEqual(recipe.wrappedAeropressType, "Normal")
        XCTAssertEqual(recipe.usageCount, 0)
        XCTAssertEqual(recipe.brewingNotesArray.count, 0)
    }
    
    func testBrewingNoteNilPropertyHandling() throws {
        let brewingNote = BrewingNote(context: context)
        // Don't set any properties - test default values
        
        XCTAssertEqual(brewingNote.wrappedNotes, "")
        XCTAssertEqual(brewingNote.wrappedCoffeeName, "Unknown Coffee")
        XCTAssertEqual(brewingNote.wrappedRecipeName, "Unknown Recipe")
        XCTAssertEqual(brewingNote.wrappedRoaster, "Unknown Roaster")
        XCTAssertEqual(brewingNote.wrappedBrewingMethod, "Unknown Method")
        XCTAssertFalse(brewingNote.hasRating)
        XCTAssertFalse(brewingNote.hasNotes)
        XCTAssertEqual(brewingNote.ratingStars, "☆☆☆☆☆")
    }
    
    // MARK: - Edge Case Data Tests
    
    func testBrewingNoteZeroRating() throws {
        let brewingNote = BrewingNote(context: context)
        brewingNote.rating = 0
        
        XCTAssertFalse(brewingNote.hasRating)
        XCTAssertEqual(brewingNote.ratingStars, "☆☆☆☆☆")
    }
    
    func testBrewingNoteMaxRating() throws {
        let brewingNote = BrewingNote(context: context)
        brewingNote.rating = 5
        
        XCTAssertTrue(brewingNote.hasRating)
        XCTAssertEqual(brewingNote.ratingStars, "★★★★★")
    }
    
    func testBrewingNoteInvalidRating() throws {
        let brewingNote = BrewingNote(context: context)
        brewingNote.rating = 10 // Invalid rating
        
        // Should still handle gracefully
        XCTAssertTrue(brewingNote.hasRating)
        XCTAssertEqual(brewingNote.ratingStars.count, 5) // Should still return 5 characters
    }
    
    func testRecipeUsageCountNegative() throws {
        let recipe = Recipe(context: context)
        recipe.usageCount = -5
        
        // Should handle negative usage count gracefully
        XCTAssertEqual(recipe.usageCount, -5)
        
        recipe.incrementUsageCount()
        XCTAssertEqual(recipe.usageCount, -4)
    }
    
    func testCoffeeAverageRatingWithNoRatings() throws {
        let coffee = Coffee(context: context)
        coffee.name = "Test Coffee"
        
        let recipe = Recipe(context: context)
        recipe.name = "Test Recipe"
        
        // Add brewing notes with no ratings
        let note1 = BrewingNote(context: context)
        note1.coffee = coffee
        note1.recipe = recipe
        note1.rating = 0
        
        let note2 = BrewingNote(context: context)
        note2.coffee = coffee
        note2.recipe = recipe
        note2.rating = 0
        
        try context.save()
        
        XCTAssertEqual(coffee.averageRating, 0.0)
        XCTAssertFalse(coffee.hasRatings)
        XCTAssertEqual(coffee.brewingNotesCount, 2)
    }
    
    func testCoffeeAverageRatingWithMixedRatings() throws {
        let coffee = Coffee(context: context)
        coffee.name = "Test Coffee"
        
        let recipe = Recipe(context: context)
        recipe.name = "Test Recipe"
        
        // Add brewing notes with mixed ratings (some 0, some with values)
        let note1 = BrewingNote(context: context)
        note1.coffee = coffee
        note1.recipe = recipe
        note1.rating = 0 // No rating
        
        let note2 = BrewingNote(context: context)
        note2.coffee = coffee
        note2.recipe = recipe
        note2.rating = 4
        
        let note3 = BrewingNote(context: context)
        note3.coffee = coffee
        note3.recipe = recipe
        note3.rating = 5
        
        try context.save()
        
        // Should only count rated notes (4 + 5) / 2 = 4.5
        XCTAssertEqual(coffee.averageRating, 4.5)
        XCTAssertTrue(coffee.hasRatings)
        XCTAssertEqual(coffee.brewingNotesCount, 3)
    }
    
    // MARK: - Search Edge Cases
    
    func testBrewingNoteSearchWithEmptyString() throws {
        let coffee = Coffee(context: context)
        coffee.name = "Test Coffee"
        
        let recipe = Recipe(context: context)
        recipe.name = "Test Recipe"
        
        let brewingNote = BrewingNote(context: context)
        brewingNote.notes = "Some notes"
        brewingNote.coffee = coffee
        brewingNote.recipe = recipe
        
        // Empty search should match everything
        XCTAssertTrue(brewingNote.matchesSearchText(""))
    }
    
    func testBrewingNoteSearchCaseInsensitive() throws {
        let coffee = Coffee(context: context)
        coffee.name = "Ethiopian Coffee"
        
        let recipe = Recipe(context: context)
        recipe.name = "V60 Recipe"
        
        let brewingNote = BrewingNote(context: context)
        brewingNote.notes = "Bright CITRUS notes"
        brewingNote.coffee = coffee
        brewingNote.recipe = recipe
        
        // Case insensitive search
        XCTAssertTrue(brewingNote.matchesSearchText("ethiopian"))
        XCTAssertTrue(brewingNote.matchesSearchText("ETHIOPIAN"))
        XCTAssertTrue(brewingNote.matchesSearchText("EtHiOpIaN"))
        XCTAssertTrue(brewingNote.matchesSearchText("citrus"))
        XCTAssertTrue(brewingNote.matchesSearchText("CITRUS"))
        XCTAssertTrue(brewingNote.matchesSearchText("v60"))
        XCTAssertTrue(brewingNote.matchesSearchText("V60"))
    }
    
    func testBrewingNoteSearchWithSpecialCharacters() throws {
        let coffee = Coffee(context: context)
        coffee.name = "Café de Origem"
        
        let recipe = Recipe(context: context)
        recipe.name = "V60-01"
        
        let brewingNote = BrewingNote(context: context)
        brewingNote.notes = "Notes with émojis 🌟 and spëcial chäracters!"
        brewingNote.coffee = coffee
        brewingNote.recipe = recipe
        
        XCTAssertTrue(brewingNote.matchesSearchText("Café"))
        XCTAssertTrue(brewingNote.matchesSearchText("émojis"))
        XCTAssertTrue(brewingNote.matchesSearchText("V60-01"))
        XCTAssertTrue(brewingNote.matchesSearchText("🌟"))
        XCTAssertTrue(brewingNote.matchesSearchText("spëcial"))
    }
    
    // MARK: - Method Detection Edge Cases
    
    func testRecipeMethodDetectionCaseInsensitive() throws {
        let recipe1 = Recipe(context: context)
        recipe1.brewingMethod = "v60-01" // lowercase
        
        let recipe2 = Recipe(context: context)
        recipe2.brewingMethod = "V60-01" // uppercase
        
        let recipe3 = Recipe(context: context)
        recipe3.brewingMethod = "espresso" // lowercase
        
        let recipe4 = Recipe(context: context)
        recipe4.brewingMethod = "ESPRESSO" // uppercase
        
        XCTAssertTrue(recipe1.isPourOver)
        XCTAssertTrue(recipe2.isPourOver)
        XCTAssertTrue(recipe3.isEspresso)
        XCTAssertTrue(recipe4.isEspresso)
    }
    
    func testRecipeMethodDetectionPartialMatch() throws {
        let recipe1 = Recipe(context: context)
        recipe1.brewingMethod = "Custom V60 Setup"
        
        let recipe2 = Recipe(context: context)
        recipe2.brewingMethod = "Gaggia Classic Espresso"
        
        let recipe3 = Recipe(context: context)
        recipe3.brewingMethod = "Large French Press"
        
        let recipe4 = Recipe(context: context)
        recipe4.brewingMethod = "Inverted Aeropress Method"
        
        XCTAssertTrue(recipe1.isPourOver)
        XCTAssertTrue(recipe2.isEspresso)
        XCTAssertTrue(recipe3.isFrenchPress)
        XCTAssertTrue(recipe4.isAeropress)
    }
    
    func testRecipeMethodDetectionUnknown() throws {
        let recipe = Recipe(context: context)
        recipe.brewingMethod = "Unknown Brewing Method"
        
        XCTAssertFalse(recipe.isPourOver)
        XCTAssertFalse(recipe.isEspresso)
        XCTAssertFalse(recipe.isFrenchPress)
        XCTAssertFalse(recipe.isAeropress)
        XCTAssertFalse(recipe.supportsPours)
        XCTAssertFalse(recipe.supportsBloom)
    }
    
    // MARK: - Data Consistency Tests
    
    func testRecipeUsageCountIntegrity() throws {
        let coffee = Coffee(context: context)
        coffee.name = "Test Coffee"
        
        let recipe = Recipe(context: context)
        recipe.name = "Test Recipe"
        recipe.usageCount = 5
        
        // Verify that creating brewing notes updates usage count correctly
        let initialCount = recipe.usageCount
        
        let brewingNote = persistenceController.createBrewingNote(
            coffee: coffee,
            recipe: recipe,
            notes: "Test notes",
            rating: 4
        )
        
        XCTAssertEqual(recipe.usageCount, initialCount + 1)
        XCTAssertNotNil(brewingNote.coffee)
        XCTAssertNotNil(brewingNote.recipe)
        XCTAssertEqual(brewingNote.coffee, coffee)
        XCTAssertEqual(brewingNote.recipe, recipe)
    }
    
    func testRelationshipIntegrity() throws {
        let coffee = Coffee(context: context)
        coffee.name = "Test Coffee"
        
        let recipe = Recipe(context: context)
        recipe.name = "Test Recipe"
        
        let brewingNote = BrewingNote(context: context)
        brewingNote.coffee = coffee
        brewingNote.recipe = recipe
        
        try context.save()
        
        // Verify bidirectional relationships
        XCTAssertTrue(coffee.brewingNotesArray.contains(brewingNote))
        XCTAssertTrue(recipe.brewingNotesArray.contains(brewingNote))
        XCTAssertEqual(brewingNote.coffee, coffee)
        XCTAssertEqual(brewingNote.recipe, recipe)
    }
    
    // MARK: - Persistence Error Handling Tests
    
    func testPersistenceControllerCreateCoffeeWithMinimalData() throws {
        // Test creating coffee with minimal required data
        let coffee = persistenceController.createCoffee(
            name: "",
            roaster: "",
            processing: "",
            roastLevel: "",
            origin: ""
        )
        
        // Should still create successfully with empty strings
        XCTAssertNotNil(coffee.id)
        XCTAssertNotNil(coffee.dateAdded)
        XCTAssertEqual(coffee.name, "")
        XCTAssertEqual(coffee.roaster, "")
    }
    
    func testPersistenceControllerCreateRecipeWithMinimalData() throws {
        // Test creating recipe with minimal required data
        let recipe = persistenceController.createRecipe(
            name: "",
            brewingMethod: "",
            grinder: "",
            grindSize: 0,
            waterTemp: 0,
            dose: 0.0,
            brewTime: 0
        )
        
        // Should still create successfully
        XCTAssertNotNil(recipe.id)
        XCTAssertNotNil(recipe.dateCreated)
        XCTAssertEqual(recipe.usageCount, 0)
        XCTAssertEqual(recipe.name, "")
    }
    
    func testPersistenceControllerCreateBrewingNoteWithNilRating() throws {
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
            grinder: "Test Grinder",
            grindSize: 20,
            waterTemp: 93,
            dose: 20.0,
            brewTime: 240
        )
        
        let brewingNote = persistenceController.createBrewingNote(
            coffee: coffee,
            recipe: recipe,
            notes: "",
            rating: 0
        )
        
        XCTAssertNotNil(brewingNote.id)
        XCTAssertNotNil(brewingNote.dateCreated)
        XCTAssertEqual(brewingNote.rating, 0)
        XCTAssertEqual(brewingNote.notes, "")
        XCTAssertEqual(brewingNote.coffee, coffee)
        XCTAssertEqual(brewingNote.recipe, recipe)
    }
    
    // MARK: - Date Handling Tests
    
    func testBrewingNoteFormattedDateWithNilDate() throws {
        let brewingNote = BrewingNote(context: context)
        // Don't set dateCreated - should use current date
        
        let formattedDate = brewingNote.formattedDate
        XCTAssertFalse(formattedDate.isEmpty)
        
        // Should use wrapped date (current date)
        let currentDateFormatted = DateFormatter().string(from: Date())
        XCTAssertTrue(formattedDate.contains(String(Calendar.current.component(.year, from: Date()))))
    }
    
    func testCoffeeAndRecipeArraySortingWithNilDates() throws {
        let coffee = Coffee(context: context)
        coffee.name = "Test Coffee"
        
        let recipe = Recipe(context: context)
        recipe.name = "Test Recipe"
        
        // Create brewing notes with nil dates
        let note1 = BrewingNote(context: context)
        note1.coffee = coffee
        note1.recipe = recipe
        note1.dateCreated = nil
        
        let note2 = BrewingNote(context: context)
        note2.coffee = coffee
        note2.recipe = recipe
        note2.dateCreated = Date()
        
        let note3 = BrewingNote(context: context)
        note3.coffee = coffee
        note3.recipe = recipe
        note3.dateCreated = nil
        
        try context.save()
        
        // Should handle nil dates gracefully in sorting
        let coffeeNotes = coffee.brewingNotesArray
        let recipeNotes = recipe.brewingNotesArray
        
        XCTAssertEqual(coffeeNotes.count, 3)
        XCTAssertEqual(recipeNotes.count, 3)
        
        // Should not crash on sorting with nil dates
        XCTAssertNotNil(coffeeNotes)
        XCTAssertNotNil(recipeNotes)
    }
}
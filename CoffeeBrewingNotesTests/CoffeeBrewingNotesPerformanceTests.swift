import XCTest
import CoreData
@testable import CoffeeBrewingNotes

final class CoffeeBrewingNotesPerformanceTests: XCTestCase {
    
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
    
    // MARK: - Data Creation Performance Tests
    
    func testCreateManyCofeesPerformance() throws {
        measure {
            for i in 1...1000 {
                let coffee = Coffee(context: context)
                coffee.id = UUID()
                coffee.name = "Coffee \(i)"
                coffee.roaster = "Roaster \(i % 10)"
                coffee.processing = Coffee.processingOptions[i % Coffee.processingOptions.count]
                coffee.roastLevel = Coffee.roastLevelOptions[i % Coffee.roastLevelOptions.count]
                coffee.origin = "Origin \(i % 20)"
                coffee.dateAdded = Date()
            }
            
            do {
                try context.save()
            } catch {
                XCTFail("Failed to save context: \(error)")
            }
        }
    }
    
    func testCreateManyRecipesPerformance() throws {
        measure {
            for i in 1...1000 {
                let recipe = Recipe(context: context)
                recipe.id = UUID()
                recipe.name = "Recipe \(i)"
                recipe.brewingMethod = Recipe.brewingMethods[i % Recipe.brewingMethods.count]
                recipe.grinder = Recipe.grinders[i % Recipe.grinders.count]
                recipe.grindSize = Int32(15 + (i % 20))
                recipe.waterTemp = Int32(85 + (i % 15))
                recipe.dose = Double(18 + (i % 10))
                recipe.brewTime = Int32(180 + (i % 120))
                recipe.usageCount = Int32(i % 50)
                recipe.dateCreated = Date()
            }
            
            do {
                try context.save()
            } catch {
                XCTFail("Failed to save context: \(error)")
            }
        }
    }
    
    func testCreateManyBrewingNotesPerformance() throws {
        // First create some coffees and recipes
        let coffee = Coffee(context: context)
        coffee.name = "Test Coffee"
        
        let recipe = Recipe(context: context)
        recipe.name = "Test Recipe"
        
        try context.save()
        
        measure {
            for i in 1...1000 {
                let brewingNote = BrewingNote(context: context)
                brewingNote.id = UUID()
                brewingNote.notes = "Brewing notes for session \(i). This is a detailed description of the brewing process and tasting notes."
                brewingNote.rating = Int16(1 + (i % 5))
                brewingNote.dateCreated = Date().addingTimeInterval(TimeInterval(-i * 3600))
                brewingNote.coffee = coffee
                brewingNote.recipe = recipe
            }
            
            do {
                try context.save()
            } catch {
                XCTFail("Failed to save context: \(error)")
            }
        }
    }
    
    // MARK: - Data Retrieval Performance Tests
    
    func testFetchCoffeesPerformance() throws {
        // Create test data
        for i in 1...1000 {
            let coffee = Coffee(context: context)
            coffee.name = "Coffee \(i)"
            coffee.roaster = "Roaster \(i % 10)"
            coffee.dateAdded = Date().addingTimeInterval(TimeInterval(-i * 3600))
        }
        try context.save()
        
        measure {
            let request: NSFetchRequest<Coffee> = Coffee.fetchRequest()
            request.sortDescriptors = [NSSortDescriptor(keyPath: \Coffee.dateAdded, ascending: false)]
            
            do {
                let coffees = try context.fetch(request)
                XCTAssertEqual(coffees.count, 1000)
            } catch {
                XCTFail("Failed to fetch coffees: \(error)")
            }
        }
    }
    
    func testFetchRecipesSortedByUsagePerformance() throws {
        // Create test data
        for i in 1...1000 {
            let recipe = Recipe(context: context)
            recipe.name = "Recipe \(i)"
            recipe.brewingMethod = Recipe.brewingMethods[i % Recipe.brewingMethods.count]
            recipe.usageCount = Int32(i % 100)
        }
        try context.save()
        
        measure {
            let request: NSFetchRequest<Recipe> = Recipe.fetchRequest()
            request.sortDescriptors = [NSSortDescriptor(keyPath: \Recipe.usageCount, ascending: false)]
            
            do {
                let recipes = try context.fetch(request)
                XCTAssertEqual(recipes.count, 1000)
                XCTAssertGreaterThanOrEqual(recipes[0].usageCount, recipes[999].usageCount)
            } catch {
                XCTFail("Failed to fetch recipes: \(error)")
            }
        }
    }
    
    func testFetchBrewingNotesByDatePerformance() throws {
        // Create test data
        let coffee = Coffee(context: context)
        coffee.name = "Test Coffee"
        
        let recipe = Recipe(context: context)
        recipe.name = "Test Recipe"
        
        for i in 1...1000 {
            let brewingNote = BrewingNote(context: context)
            brewingNote.notes = "Notes \(i)"
            brewingNote.dateCreated = Date().addingTimeInterval(TimeInterval(-i * 3600))
            brewingNote.coffee = coffee
            brewingNote.recipe = recipe
        }
        try context.save()
        
        measure {
            let request: NSFetchRequest<BrewingNote> = BrewingNote.fetchRequest()
            request.sortDescriptors = [NSSortDescriptor(keyPath: \BrewingNote.dateCreated, ascending: false)]
            
            do {
                let brewingNotes = try context.fetch(request)
                XCTAssertEqual(brewingNotes.count, 1000)
                if brewingNotes.count >= 2 {
                    XCTAssertGreaterThanOrEqual(brewingNotes[0].dateCreated ?? Date(), brewingNotes[1].dateCreated ?? Date())
                }
            } catch {
                XCTFail("Failed to fetch brewing notes: \(error)")
            }
        }
    }
    
    // MARK: - Search Performance Tests
    
    func testSearchCoffeesPerformance() throws {
        // Create test data with searchable content
        for i in 1...1000 {
            let coffee = Coffee(context: context)
            coffee.name = i % 10 == 0 ? "Ethiopian Coffee \(i)" : "Coffee \(i)"
            coffee.roaster = "Roaster \(i % 10)"
            coffee.origin = i % 20 == 0 ? "Ethiopia" : "Origin \(i % 20)"
        }
        try context.save()
        
        measure {
            let request: NSFetchRequest<Coffee> = Coffee.fetchRequest()
            request.predicate = NSPredicate(format: "name CONTAINS[cd] %@ OR origin CONTAINS[cd] %@", "Ethiopian", "Ethiopia")
            
            do {
                let results = try context.fetch(request)
                XCTAssertGreaterThan(results.count, 0)
            } catch {
                XCTFail("Failed to search coffees: \(error)")
            }
        }
    }
    
    func testSearchBrewingNotesPerformance() throws {
        // Create test data
        let coffee = Coffee(context: context)
        coffee.name = "Test Coffee"
        
        let recipe = Recipe(context: context)
        recipe.name = "Test Recipe"
        
        for i in 1...1000 {
            let brewingNote = BrewingNote(context: context)
            brewingNote.notes = i % 50 == 0 ? "Citrus notes with bright acidity \(i)" : "Standard notes \(i)"
            brewingNote.coffee = coffee
            brewingNote.recipe = recipe
        }
        try context.save()
        
        measure {
            let request: NSFetchRequest<BrewingNote> = BrewingNote.fetchRequest()
            request.predicate = NSPredicate(format: "notes CONTAINS[cd] %@", "citrus")
            
            do {
                let results = try context.fetch(request)
                XCTAssertGreaterThan(results.count, 0)
            } catch {
                XCTFail("Failed to search brewing notes: \(error)")
            }
        }
    }
    
    // MARK: - Relationship Performance Tests
    
    func testCoffeeRelationshipPerformance() throws {
        // Create coffee with many brewing notes
        let coffee = Coffee(context: context)
        coffee.name = "Popular Coffee"
        
        let recipe = Recipe(context: context)
        recipe.name = "Test Recipe"
        
        for i in 1...500 {
            let brewingNote = BrewingNote(context: context)
            brewingNote.notes = "Notes \(i)"
            brewingNote.rating = Int16(1 + (i % 5))
            brewingNote.coffee = coffee
            brewingNote.recipe = recipe
        }
        try context.save()
        
        measure {
            let brewingNotes = coffee.brewingNotesArray
            XCTAssertEqual(brewingNotes.count, 500)
            
            let averageRating = coffee.averageRating
            XCTAssertGreaterThan(averageRating, 0.0)
            
            let hasRatings = coffee.hasRatings
            XCTAssertTrue(hasRatings)
        }
    }
    
    func testRecipeUsageTrackingPerformance() throws {
        // Create recipe with high usage
        let recipe = Recipe(context: context)
        recipe.name = "Popular Recipe"
        recipe.usageCount = 0
        
        measure {
            for _ in 1...1000 {
                recipe.incrementUsageCount()
            }
        }
        
        XCTAssertEqual(recipe.usageCount, 1000)
    }
    
    // MARK: - Extension Performance Tests
    
    func testBrewingNoteExtensionPerformance() throws {
        // Create brewing notes with varied content
        let coffee = Coffee(context: context)
        coffee.name = "Test Coffee"
        coffee.roaster = "Test Roaster"
        
        let recipe = Recipe(context: context)
        recipe.name = "Test Recipe"
        recipe.brewingMethod = "V60-01"
        
        var brewingNotes: [BrewingNote] = []
        for i in 1...1000 {
            let brewingNote = BrewingNote(context: context)
            brewingNote.notes = "This is a longer brewing note with detailed tasting notes and observations about the brewing process for session \(i). It includes multiple keywords that might be searched for."
            brewingNote.rating = Int16(1 + (i % 5))
            brewingNote.dateCreated = Date()
            brewingNote.coffee = coffee
            brewingNote.recipe = recipe
            brewingNotes.append(brewingNote)
        }
        try context.save()
        
        measure {
            for brewingNote in brewingNotes {
                _ = brewingNote.wrappedNotes
                _ = brewingNote.wrappedCoffeeName
                _ = brewingNote.wrappedRecipeName
                _ = brewingNote.ratingStars
                _ = brewingNote.formattedDate
                _ = brewingNote.hasRating
                _ = brewingNote.hasNotes
                _ = brewingNote.matchesSearchText("citrus")
                _ = brewingNote.shortNotes
            }
        }
    }
    
    // MARK: - Batch Operations Performance Tests
    
    func testBatchDeletePerformance() throws {
        // Create test data
        for i in 1...1000 {
            let coffee = Coffee(context: context)
            coffee.name = "Coffee \(i)"
        }
        try context.save()
        
        measure {
            let request: NSFetchRequest<NSFetchRequestResult> = Coffee.fetchRequest()
            let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: request)
            
            do {
                try context.execute(batchDeleteRequest)
                try context.save()
            } catch {
                XCTFail("Failed to batch delete: \(error)")
            }
        }
    }
    
    func testComplexQueryPerformance() throws {
        // Create complex test data
        for i in 1...500 {
            let coffee = Coffee(context: context)
            coffee.name = "Coffee \(i)"
            coffee.roaster = "Roaster \(i % 10)"
            coffee.processing = Coffee.processingOptions[i % Coffee.processingOptions.count]
            
            let recipe = Recipe(context: context)
            recipe.name = "Recipe \(i)"
            recipe.brewingMethod = Recipe.brewingMethods[i % Recipe.brewingMethods.count]
            recipe.usageCount = Int32(i % 50)
            
            for j in 1...5 {
                let brewingNote = BrewingNote(context: context)
                brewingNote.notes = "Notes \(i)-\(j)"
                brewingNote.rating = Int16(1 + ((i + j) % 5))
                brewingNote.coffee = coffee
                brewingNote.recipe = recipe
            }
        }
        try context.save()
        
        measure {
            // Complex query: Find all brewing notes for V60 recipes with 4+ star ratings
            let request: NSFetchRequest<BrewingNote> = BrewingNote.fetchRequest()
            request.predicate = NSPredicate(format: "recipe.brewingMethod CONTAINS[cd] %@ AND rating >= %d", "V60", 4)
            request.sortDescriptors = [NSSortDescriptor(keyPath: \BrewingNote.dateCreated, ascending: false)]
            
            do {
                let results = try context.fetch(request)
                XCTAssertGreaterThan(results.count, 0)
            } catch {
                XCTFail("Failed to execute complex query: \(error)")
            }
        }
    }
}
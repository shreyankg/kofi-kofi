import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        
        // Sample coffee for preview
        let sampleCoffee = Coffee(context: viewContext)
        sampleCoffee.id = UUID()
        sampleCoffee.name = "Blue Mountain"
        sampleCoffee.roaster = "Blue Bottle Coffee"
        sampleCoffee.processing = "Washed"
        sampleCoffee.roastLevel = "Medium"
        sampleCoffee.origin = "Jamaica"
        sampleCoffee.dateAdded = Date()
        
        // Sample recipe for preview
        let sampleRecipe = Recipe(context: viewContext)
        sampleRecipe.id = UUID()
        sampleRecipe.name = "My V60 Recipe"
        sampleRecipe.brewingMethod = "V60-01"
        sampleRecipe.grinder = "Baratza Encore"
        sampleRecipe.grindSize = "20"
        sampleRecipe.waterTemp = 93
        sampleRecipe.dose = 20.0
        sampleRecipe.brewTime = 240
        sampleRecipe.usageCount = 5
        sampleRecipe.bloomAmount = 40.0
        sampleRecipe.bloomTime = 30
        sampleRecipe.secondPour = 100.0
        sampleRecipe.thirdPour = 180.0
        sampleRecipe.dateCreated = Date()
        
        // Sample brewing note for preview
        let sampleNote = BrewingNote(context: viewContext)
        sampleNote.id = UUID()
        sampleNote.notes = "Great brew today! Sweet and bright with notes of citrus. Perfect extraction."
        sampleNote.rating = 4
        sampleNote.dateCreated = Date()
        sampleNote.coffee = sampleCoffee
        sampleNote.recipe = sampleRecipe
        
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "CoffeeBrewingNotes")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
}

extension PersistenceController {
    func save() {
        let context = container.viewContext

        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
    
    func createCoffee(name: String, roaster: String, processing: String, roastLevel: String, origin: String) -> Coffee {
        let context = container.viewContext
        let coffee = Coffee(context: context)
        coffee.id = UUID()
        coffee.name = name
        coffee.roaster = roaster
        coffee.processing = processing
        coffee.roastLevel = roastLevel
        coffee.origin = origin
        coffee.dateAdded = Date()
        
        save()
        return coffee
    }
    
    func createRecipe(name: String, brewingMethod: String, grinder: String, grindSize: String, waterTemp: Int32, dose: Double, brewTime: Int32) -> Recipe {
        let context = container.viewContext
        let recipe = Recipe(context: context)
        recipe.id = UUID()
        recipe.name = name
        recipe.brewingMethod = brewingMethod
        recipe.grinder = grinder
        recipe.grindSize = grindSize
        recipe.waterTemp = waterTemp
        recipe.dose = dose
        recipe.brewTime = brewTime
        recipe.usageCount = 0
        recipe.dateCreated = Date()
        
        save()
        return recipe
    }
    
    func createRecipeWithMethodSpecificParams(
        name: String, 
        brewingMethod: String, 
        grinder: String, 
        grindSize: String, 
        waterTemp: Int32, 
        dose: Double, 
        brewTime: Int32,
        bloomAmount: Double? = nil,
        bloomTime: Int32? = nil,
        secondPour: Double? = nil,
        thirdPour: Double? = nil,
        fourthPour: Double? = nil,
        fifthPour: Double? = nil,
        sixthPour: Double? = nil,
        seventhPour: Double? = nil,
        eighthPour: Double? = nil,
        ninthPour: Double? = nil,
        tenthPour: Double? = nil,
        waterOut: Double? = nil,
        aeropressType: String? = nil,
        plungeTime: Int32? = nil
    ) -> Recipe {
        let context = container.viewContext
        let recipe = Recipe(context: context)
        recipe.id = UUID()
        recipe.name = name
        recipe.brewingMethod = brewingMethod
        recipe.grinder = grinder
        recipe.grindSize = grindSize
        recipe.waterTemp = waterTemp
        recipe.dose = dose
        recipe.brewTime = brewTime
        recipe.usageCount = 0
        recipe.dateCreated = Date()
        
        // Set method-specific parameters
        if let bloomAmount = bloomAmount {
            recipe.bloomAmount = bloomAmount
        }
        if let bloomTime = bloomTime {
            recipe.bloomTime = bloomTime
        }
        if let secondPour = secondPour {
            recipe.secondPour = secondPour
        }
        if let thirdPour = thirdPour {
            recipe.thirdPour = thirdPour
        }
        if let fourthPour = fourthPour {
            recipe.fourthPour = fourthPour
        }
        if let fifthPour = fifthPour {
            recipe.fifthPour = fifthPour
        }
        if let sixthPour = sixthPour {
            recipe.sixthPour = sixthPour
        }
        if let seventhPour = seventhPour {
            recipe.seventhPour = seventhPour
        }
        if let eighthPour = eighthPour {
            recipe.eighthPour = eighthPour
        }
        if let ninthPour = ninthPour {
            recipe.ninthPour = ninthPour
        }
        if let tenthPour = tenthPour {
            recipe.tenthPour = tenthPour
        }
        if let waterOut = waterOut {
            recipe.waterOut = waterOut
        }
        if let aeropressType = aeropressType {
            recipe.aeropressType = aeropressType
        }
        if let plungeTime = plungeTime {
            recipe.plungeTime = plungeTime
        }
        
        save()
        return recipe
    }
    
    func createBrewingNote(coffee: Coffee, recipe: Recipe, notes: String, rating: Int16) -> BrewingNote {
        let context = container.viewContext
        let brewingNote = BrewingNote(context: context)
        brewingNote.id = UUID()
        brewingNote.notes = notes
        brewingNote.rating = rating
        brewingNote.dateCreated = Date()
        brewingNote.coffee = coffee
        brewingNote.recipe = recipe
        
        recipe.usageCount += 1
        
        save()
        return brewingNote
    }
    
    func deleteCoffee(_ coffee: Coffee) {
        let context = container.viewContext
        context.delete(coffee)
        save()
    }
    
    func deleteRecipe(_ recipe: Recipe) {
        let context = container.viewContext
        context.delete(recipe)
        save()
    }
    
    func deleteBrewingNote(_ brewingNote: BrewingNote) {
        let context = container.viewContext
        context.delete(brewingNote)
        save()
    }
}
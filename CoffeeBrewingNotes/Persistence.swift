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
        sampleRecipe.grindSize = 20
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
    
    func createRecipe(name: String, brewingMethod: String, grinder: String, grindSize: Int32, waterTemp: Int32, dose: Double, brewTime: Int32) -> Recipe {
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
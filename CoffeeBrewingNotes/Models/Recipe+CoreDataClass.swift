import Foundation
import CoreData

@objc(Recipe)
public class Recipe: NSManagedObject {
    
}

extension Recipe {
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Recipe> {
        return NSFetchRequest<Recipe>(entityName: "Recipe")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var name: String?
    @NSManaged public var brewingMethod: String?
    @NSManaged public var grinder: String?
    @NSManaged public var grindSize: Int32
    @NSManaged public var waterTemp: Int32
    @NSManaged public var dose: Double
    @NSManaged public var brewTime: Int32
    @NSManaged public var usageCount: Int32
    @NSManaged public var dateCreated: Date?
    
    // Pour-over specific attributes
    @NSManaged public var bloomAmount: Double
    @NSManaged public var bloomTime: Int32
    @NSManaged public var secondPour: Double
    @NSManaged public var thirdPour: Double
    @NSManaged public var fourthPour: Double
    
    // Espresso specific
    @NSManaged public var waterOut: Double
    
    // Aeropress specific
    @NSManaged public var aeropressType: String?
    @NSManaged public var plungeTime: Int32
    
    @NSManaged public var brewingNotes: NSSet?

}

// MARK: Generated accessors for brewingNotes
extension Recipe {

    @objc(addBrewingNotesObject:)
    @NSManaged public func addToBrewingNotes(_ value: BrewingNote)

    @objc(removeBrewingNotesObject:)
    @NSManaged public func removeFromBrewingNotes(_ value: BrewingNote)

    @objc(addBrewingNotes:)
    @NSManaged public func addToBrewingNotes(_ values: NSSet)

    @objc(removeBrewingNotes:)
    @NSManaged public func removeFromBrewingNotes(_ values: NSSet)

}

extension Recipe: Identifiable {

}

// MARK: - Convenience Properties and Methods
extension Recipe {
    
    var wrappedName: String {
        name ?? "Untitled Recipe"
    }
    
    var wrappedBrewingMethod: String {
        brewingMethod ?? "V60-01"
    }
    
    var wrappedGrinder: String {
        grinder ?? "Baratza Encore"
    }
    
    var wrappedAeropressType: String {
        aeropressType ?? "Normal"
    }
    
    var wrappedDateCreated: Date {
        dateCreated ?? Date()
    }
    
    var brewingNotesArray: [BrewingNote] {
        let set = brewingNotes as? Set<BrewingNote> ?? []
        return set.sorted { $0.wrappedDateCreated > $1.wrappedDateCreated }
    }
    
    static let brewingMethods = [
        "V60-01", "V60-02", "Kalita Wave-01", "Espresso - Gaggia Classic Pro", 
        "French Press - 01", "French Press - 02", "Aeropress"
    ]
    
    static let grinders = [
        "Baratza Encore", "1Zpresso J Ultra", "DF64"
    ]
    
    static let aeropressTypes = [
        "Normal", "Inverted"
    ]
    
    var isPourOver: Bool {
        wrappedBrewingMethod.contains("V60") || wrappedBrewingMethod.contains("Kalita")
    }
    
    var isEspresso: Bool {
        wrappedBrewingMethod.contains("Espresso")
    }
    
    var isFrenchPress: Bool {
        wrappedBrewingMethod.contains("French Press")
    }
    
    var isAeropress: Bool {
        wrappedBrewingMethod.contains("Aeropress")
    }
    
    var supportsPours: Bool {
        isPourOver || isFrenchPress || isAeropress
    }
    
    var supportsBloom: Bool {
        isPourOver || isFrenchPress || isAeropress
    }
    
    func incrementUsageCount() {
        usageCount += 1
    }
}
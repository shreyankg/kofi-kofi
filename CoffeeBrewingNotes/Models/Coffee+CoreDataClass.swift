import Foundation
import CoreData

@objc(Coffee)
public class Coffee: NSManagedObject {
    
}

extension Coffee {
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Coffee> {
        return NSFetchRequest<Coffee>(entityName: "Coffee")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var name: String?
    @NSManaged public var roaster: String?
    @NSManaged public var processing: String?
    @NSManaged public var roastLevel: String?
    @NSManaged public var origin: String?
    @NSManaged public var dateAdded: Date?
    @NSManaged public var brewingNotes: NSSet?

}

// MARK: Generated accessors for brewingNotes
extension Coffee {

    @objc(addBrewingNotesObject:)
    @NSManaged public func addToBrewingNotes(_ value: BrewingNote)

    @objc(removeBrewingNotesObject:)
    @NSManaged public func removeFromBrewingNotes(_ value: BrewingNote)

    @objc(addBrewingNotes:)
    @NSManaged public func addToBrewingNotes(_ values: NSSet)

    @objc(removeBrewingNotes:)
    @NSManaged public func removeFromBrewingNotes(_ values: NSSet)

}

extension Coffee: Identifiable {

}

// MARK: - Convenience Properties and Methods
extension Coffee {
    
    var wrappedName: String {
        name ?? "Unknown Coffee"
    }
    
    var wrappedRoaster: String {
        roaster ?? "Unknown Roaster"
    }
    
    var wrappedProcessing: String {
        processing ?? "Unknown"
    }
    
    var wrappedRoastLevel: String {
        roastLevel ?? "Medium"
    }
    
    var wrappedOrigin: String {
        origin ?? "Unknown Origin"
    }
    
    var wrappedDateAdded: Date {
        dateAdded ?? Date()
    }
    
    var brewingNotesArray: [BrewingNote] {
        let set = brewingNotes as? Set<BrewingNote> ?? []
        return set.sorted { $0.wrappedDateCreated > $1.wrappedDateCreated }
    }
    
    static let processingOptions = [
        "Washed", "Honey", "Natural", "Semi-Washed", "Pulped Natural", "Anaerobic", "Carbonic Maceration"
    ]
    
    static let roastLevelOptions = [
        "Light", "Medium Light", "Medium", "Medium Dark", "Dark", "Extra Dark"
    ]
}
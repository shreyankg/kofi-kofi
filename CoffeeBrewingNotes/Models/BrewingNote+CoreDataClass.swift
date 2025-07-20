import Foundation
import CoreData

@objc(BrewingNote)
public class BrewingNote: NSManagedObject {
    
}

extension BrewingNote {
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<BrewingNote> {
        return NSFetchRequest<BrewingNote>(entityName: "BrewingNote")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var notes: String?
    @NSManaged public var rating: Int16
    @NSManaged public var dateCreated: Date?
    @NSManaged public var coffee: Coffee?
    @NSManaged public var recipe: Recipe?

}

extension BrewingNote: Identifiable {

}

// MARK: - Convenience Properties and Methods
extension BrewingNote {
    
    var wrappedNotes: String {
        notes ?? ""
    }
    
    var wrappedDateCreated: Date {
        dateCreated ?? Date()
    }
    
    var wrappedCoffeeName: String {
        coffee?.wrappedName ?? "Unknown Coffee"
    }
    
    var wrappedRecipeName: String {
        recipe?.wrappedName ?? "Unknown Recipe"
    }
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: wrappedDateCreated)
    }
    
    var hasRating: Bool {
        rating > 0
    }
    
    var ratingStars: String {
        String(repeating: "★", count: Int(rating)) + String(repeating: "☆", count: 5 - Int(rating))
    }
    
    static let ratingOptions = Array(1...5)
}
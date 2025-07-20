import Foundation
import CoreData

extension BrewingNote {
    
    // MARK: - Safe Property Accessors
    
    var wrappedNotes: String {
        notes ?? ""
    }
    
    var wrappedCoffeeName: String {
        coffee?.name ?? "Unknown Coffee"
    }
    
    var wrappedRecipeName: String {
        recipe?.name ?? "Unknown Recipe"
    }
    
    var wrappedRoaster: String {
        coffee?.roaster ?? "Unknown Roaster"
    }
    
    var wrappedBrewingMethod: String {
        recipe?.brewingMethod ?? "Unknown Method"
    }
    
    var wrappedDateCreated: Date {
        dateCreated ?? Date()
    }
    
    // MARK: - Rating Helpers
    
    var hasRating: Bool {
        rating > 0
    }
    
    var ratingStars: String {
        guard rating > 0 else { return "☆☆☆☆☆" }
        let filledStars = String(repeating: "★", count: Int(rating))
        let emptyStars = String(repeating: "☆", count: 5 - Int(rating))
        return filledStars + emptyStars
    }
    
    // MARK: - Display Helpers
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: wrappedDateCreated)
    }
    
    var hasNotes: Bool {
        !wrappedNotes.isEmpty
    }
    
    var shortNotes: String {
        let maxLength = 100
        if wrappedNotes.count <= maxLength {
            return wrappedNotes
        }
        return String(wrappedNotes.prefix(maxLength)) + "..."
    }
    
    // MARK: - Search Helpers
    
    func matchesSearchText(_ searchText: String) -> Bool {
        let lowercasedSearch = searchText.lowercased()
        return wrappedCoffeeName.lowercased().contains(lowercasedSearch) ||
               wrappedRoaster.lowercased().contains(lowercasedSearch) ||
               wrappedRecipeName.lowercased().contains(lowercasedSearch) ||
               wrappedBrewingMethod.lowercased().contains(lowercasedSearch) ||
               wrappedNotes.lowercased().contains(lowercasedSearch)
    }
}
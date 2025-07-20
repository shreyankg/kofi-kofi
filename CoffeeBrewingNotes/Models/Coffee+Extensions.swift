import Foundation
import CoreData

extension Coffee {
    
    // MARK: - Safe Property Accessors
    
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
    
    // MARK: - Relationship Helpers
    
    var brewingNotesArray: [BrewingNote] {
        let set = brewingNotes as? Set<BrewingNote> ?? []
        return set.sorted { $0.dateCreated ?? Date() > $1.dateCreated ?? Date() }
    }
    
    var brewingNotesCount: Int {
        brewingNotesArray.count
    }
    
    var averageRating: Double {
        let ratedNotes = brewingNotesArray.filter { $0.rating > 0 }
        guard !ratedNotes.isEmpty else { return 0.0 }
        
        let totalRating = ratedNotes.reduce(0) { $0 + Int($1.rating) }
        return Double(totalRating) / Double(ratedNotes.count)
    }
    
    var hasRatings: Bool {
        brewingNotesArray.contains { $0.rating > 0 }
    }
    
    // MARK: - Display Helpers
    
    var displayName: String {
        "\(wrappedName) - \(wrappedRoaster)"
    }
    
    var detailText: String {
        "\(wrappedOrigin) • \(wrappedProcessing) • \(wrappedRoastLevel)"
    }
    
    // MARK: - Static Options
    
    static let roastLevelOptions = [
        "Light",
        "Medium Light", 
        "Medium",
        "Medium Dark",
        "Dark",
        "Extra Dark"
    ]
    
    // MARK: - Roast Level Slider Support
    
    var roastLevelIndex: Int {
        get {
            Coffee.roastLevelOptions.firstIndex(of: wrappedRoastLevel) ?? 2
        }
        set {
            roastLevel = Coffee.roastLevelOptions[max(0, min(newValue, Coffee.roastLevelOptions.count - 1))]
        }
    }
    
    static func roastLevelFromIndex(_ index: Int) -> String {
        roastLevelOptions[max(0, min(index, roastLevelOptions.count - 1))]
    }
}
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
        processing ?? "Unknown Processing"
    }
    
    var wrappedRoastLevel: String {
        roastLevel ?? "Unknown Roast"
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
    
    static let processingOptions = [
        "Washed",
        "Natural",
        "Honey",
        "Semi-washed",
        "Pulped Natural",
        "Anaerobic",
        "Other"
    ]
    
    static let roastLevelOptions = [
        "Light",
        "Medium-Light", 
        "Medium",
        "Medium-Dark",
        "Dark",
        "Extra Dark"
    ]
}
import Foundation
import CoreData

extension Recipe {
    
    // MARK: - Safe Property Accessors
    
    var wrappedName: String {
        name ?? "Unknown Recipe"
    }
    
    var wrappedBrewingMethod: String {
        brewingMethod ?? "Unknown Method"
    }
    
    var wrappedGrinder: String {
        grinder ?? "Unknown Grinder"
    }
    
    var wrappedAeropressType: String {
        aeropressType ?? "Normal"
    }
    
    // MARK: - Method Detection
    
    var isPourOver: Bool {
        let method = wrappedBrewingMethod.lowercased()
        return method.contains("v60") || method.contains("kalita") || method.contains("chemex")
    }
    
    var isEspresso: Bool {
        wrappedBrewingMethod.lowercased().contains("espresso")
    }
    
    var isFrenchPress: Bool {
        wrappedBrewingMethod.lowercased().contains("french press")
    }
    
    var isAeropress: Bool {
        wrappedBrewingMethod.lowercased().contains("aeropress")
    }
    
    var supportsPours: Bool {
        isPourOver || isFrenchPress || isAeropress
    }
    
    var supportsBloom: Bool {
        supportsPours
    }
    
    // MARK: - Usage Tracking
    
    func incrementUsageCount() {
        usageCount += 1
    }
    
    // MARK: - Relationship Helpers
    
    var brewingNotesArray: [BrewingNote] {
        let set = brewingNotes as? Set<BrewingNote> ?? []
        return set.sorted { $0.dateCreated ?? Date() > $1.dateCreated ?? Date() }
    }
    
    // MARK: - Static Options (Legacy - Use PreferencesManager for current lists)
    
    static let brewingMethods = [
        "V60-01",
        "V60-02",
        "Kalita Wave 155",
        "Chemex 6-cup",
        "Espresso (Gaggia Classic Pro)",
        "French Press",
        "Aeropress"
    ]
    
    static let grinders = [
        "Baratza Encore",
        "Turin DF64",
        "1Zpresso J-Ultra",
        "Other"
    ]
    
    static let aeropressTypes = [
        "Normal",
        "Inverted"
    ]
}
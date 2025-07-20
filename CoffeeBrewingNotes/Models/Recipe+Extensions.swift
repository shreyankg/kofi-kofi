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
    
    // MARK: - Static Options
    
    static let brewingMethods = [
        "V60-01",
        "V60-02",
        "V60-03",
        "Kalita Wave 155",
        "Kalita Wave 185",
        "Chemex 6-cup",
        "Chemex 8-cup",
        "Espresso",
        "French Press",
        "Aeropress"
    ]
    
    static let grinders = [
        "Baratza Encore",
        "Baratza Virtuoso+",
        "Baratza Vario",
        "Comandante C40",
        "1Zpresso JX-Pro",
        "Hario Mini Mill",
        "Timemore C2",
        "Timemore C3",
        "Fellow Ode",
        "Wilfa Uniform",
        "Hand grinder",
        "Other"
    ]
    
    static let aeropressTypes = [
        "Normal",
        "Inverted"
    ]
}
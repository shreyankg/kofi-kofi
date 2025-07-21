import Foundation
import CoreData

extension Recipe {
    
    // MARK: - Safe Property Accessors
    
    var wrappedName: String {
        // Generate automatic name based on brewing method and grinder
        let method = wrappedBrewingMethod
        let grinder = wrappedGrinder
        return "\(method) - \(grinder)"
    }
    
    var wrappedBrewingMethod: String {
        brewingMethod ?? "Unknown Method"
    }
    
    var wrappedGrinder: String {
        grinder ?? "Unknown Grinder"
    }
    
    var wrappedGrindSize: String {
        grindSize ?? "—"
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
    
    // MARK: - Calculated Properties
    
    var finalWeight: Double {
        if isEspresso {
            return waterOut
        } else if supportsPours {
            // Find the maximum (final) pour weight
            var maxWeight: Double = bloomAmount
            if secondPour > 0 { maxWeight = max(maxWeight, secondPour) }
            if thirdPour > 0 { maxWeight = max(maxWeight, thirdPour) }
            if fourthPour > 0 { maxWeight = max(maxWeight, fourthPour) }
            return maxWeight
        } else {
            // For other methods, use dose * ratio assumption
            return dose * 15.0 // 1:15 ratio assumption
        }
    }
    
    var finalWeightString: String {
        if finalWeight > 0 {
            return String(format: "%.0fg", finalWeight)
        } else {
            return "—"
        }
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
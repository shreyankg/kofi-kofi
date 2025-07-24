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
        Recipe.isPourOverMethod(wrappedBrewingMethod)
    }
    
    var isEspresso: Bool {
        Recipe.isEspressoMethod(wrappedBrewingMethod)
    }
    
    var isFrenchPress: Bool {
        Recipe.isFrenchPressMethod(wrappedBrewingMethod)
    }
    
    var isAeropress: Bool {
        Recipe.isAeropressMethod(wrappedBrewingMethod)
    }
    
    // MARK: - Static Method Detection (for use with strings)
    
    static func isPourOverMethod(_ method: String) -> Bool {
        let lowercased = method.lowercased()
        return lowercased.contains("v60") || lowercased.contains("kalita") || lowercased.contains("chemex")
    }
    
    static func isEspressoMethod(_ method: String) -> Bool {
        method.lowercased().contains("espresso")
    }
    
    static func isFrenchPressMethod(_ method: String) -> Bool {
        method.lowercased().contains("french press")
    }
    
    static func isAeropressMethod(_ method: String) -> Bool {
        method.lowercased().contains("aeropress")
    }
    
    static func supportsPours(_ method: String) -> Bool {
        isPourOverMethod(method) || isFrenchPressMethod(method) || isAeropressMethod(method)
    }
    
    static func supportsBloom(_ method: String) -> Bool {
        supportsPours(method)
    }
    
    var supportsPours: Bool {
        isPourOver || isFrenchPress || isAeropress
    }
    
    var supportsBloom: Bool {
        supportsPours
    }
    
    // MARK: - Pour Count Calculation
    
    var pourCount: Int {
        guard isPourOver else { return 0 }
        
        var count = 0
        
        // Count bloom as first pour if it exists
        if bloomAmount > 0 { count += 1 }
        
        // Count all additional pours (Core Data model supports up to 10 total pours)
        if secondPour > 0 { count += 1 }
        if thirdPour > 0 { count += 1 }
        if fourthPour > 0 { count += 1 }
        if fifthPour > 0 { count += 1 }
        if sixthPour > 0 { count += 1 }
        if seventhPour > 0 { count += 1 }
        if eighthPour > 0 { count += 1 }
        if ninthPour > 0 { count += 1 }
        if tenthPour > 0 { count += 1 }
        
        return count
    }
    
    // MARK: - Calculated Properties
    
    var finalWeight: Double {
        if isEspresso {
            return waterOut
        } else if supportsPours {
            // Find the maximum (final) pour weight across all 10 possible pours
            var maxWeight: Double = bloomAmount
            if secondPour > 0 { maxWeight = max(maxWeight, secondPour) }
            if thirdPour > 0 { maxWeight = max(maxWeight, thirdPour) }
            if fourthPour > 0 { maxWeight = max(maxWeight, fourthPour) }
            if fifthPour > 0 { maxWeight = max(maxWeight, fifthPour) }
            if sixthPour > 0 { maxWeight = max(maxWeight, sixthPour) }
            if seventhPour > 0 { maxWeight = max(maxWeight, seventhPour) }
            if eighthPour > 0 { maxWeight = max(maxWeight, eighthPour) }
            if ninthPour > 0 { maxWeight = max(maxWeight, ninthPour) }
            if tenthPour > 0 { maxWeight = max(maxWeight, tenthPour) }
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
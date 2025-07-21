import Foundation
import SwiftUI

class PreferencesManager: ObservableObject {
    
    // MARK: - UserDefaults Keys
    private struct Keys {
        static let enabledBrewingMethods = "enabledBrewingMethods"
        static let enabledGrinders = "enabledGrinders"
        static let defaultWaterTemp = "defaultWaterTemp"
        static let customBrewingMethods = "customBrewingMethods"
        static let customGrinders = "customGrinders"
        static let hasInitializedDefaults = "hasInitializedDefaults"
    }
    
    // MARK: - Default Equipment Lists
    static let defaultBrewingMethods = [
        "V60-01",
        "V60-02", 
        "Kalita Wave 155",
        "Chemex 6-cup",
        "Espresso (Gaggia Classic Pro)",
        "French Press",
        "Aeropress"
    ]
    
    static let defaultGrinders = [
        "Baratza Encore",
        "Turin DF64",
        "1Zpresso J-Ultra",
        "Other"
    ]
    
    // MARK: - Published Properties
    @Published var enabledBrewingMethods: [String] = []
    @Published var enabledGrinders: [String] = []
    @Published var defaultWaterTemp: Int = 93
    @Published var customBrewingMethods: [String] = []
    @Published var customGrinders: [String] = []
    
    // MARK: - Singleton
    static let shared = PreferencesManager()
    
    private init() {
        initializeDefaultsIfNeeded()
        loadPreferences()
    }
    
    // MARK: - Initialization
    private func initializeDefaultsIfNeeded() {
        if !UserDefaults.standard.bool(forKey: Keys.hasInitializedDefaults) {
            // Set default enabled equipment to user's actual equipment
            UserDefaults.standard.set(["V60-01", "V60-02", "Kalita Wave 155", "Espresso (Gaggia Classic Pro)", "French Press", "Aeropress"], forKey: Keys.enabledBrewingMethods)
            UserDefaults.standard.set(["Baratza Encore", "Turin DF64", "1Zpresso J-Ultra", "Other"], forKey: Keys.enabledGrinders)
            UserDefaults.standard.set(93, forKey: Keys.defaultWaterTemp)
            UserDefaults.standard.set([], forKey: Keys.customBrewingMethods)
            UserDefaults.standard.set([], forKey: Keys.customGrinders)
            UserDefaults.standard.set(true, forKey: Keys.hasInitializedDefaults)
        }
    }
    
    // MARK: - Load Preferences
    private func loadPreferences() {
        enabledBrewingMethods = UserDefaults.standard.stringArray(forKey: Keys.enabledBrewingMethods) ?? []
        enabledGrinders = UserDefaults.standard.stringArray(forKey: Keys.enabledGrinders) ?? []
        defaultWaterTemp = UserDefaults.standard.integer(forKey: Keys.defaultWaterTemp)
        customBrewingMethods = UserDefaults.standard.stringArray(forKey: Keys.customBrewingMethods) ?? []
        customGrinders = UserDefaults.standard.stringArray(forKey: Keys.customGrinders) ?? []
        
        // Ensure at least one option is enabled
        if enabledBrewingMethods.isEmpty {
            enabledBrewingMethods = ["V60-01"]
            saveEnabledBrewingMethods()
        }
        
        if enabledGrinders.isEmpty {
            enabledGrinders = ["Other"]
            saveEnabledGrinders()
        }
        
        if defaultWaterTemp == 0 {
            defaultWaterTemp = 93
            saveDefaultWaterTemp()
        }
    }
    
    // MARK: - Save Methods
    func saveEnabledBrewingMethods() {
        // Ensure at least one method remains enabled
        if enabledBrewingMethods.isEmpty {
            enabledBrewingMethods = ["V60-01"]
        }
        UserDefaults.standard.set(enabledBrewingMethods, forKey: Keys.enabledBrewingMethods)
    }
    
    func saveEnabledGrinders() {
        // Ensure at least one grinder remains enabled
        if enabledGrinders.isEmpty {
            enabledGrinders = ["Other"]
        }
        UserDefaults.standard.set(enabledGrinders, forKey: Keys.enabledGrinders)
    }
    
    func saveDefaultWaterTemp() {
        UserDefaults.standard.set(defaultWaterTemp, forKey: Keys.defaultWaterTemp)
    }
    
    func saveCustomBrewingMethods() {
        UserDefaults.standard.set(customBrewingMethods, forKey: Keys.customBrewingMethods)
    }
    
    func saveCustomGrinders() {
        UserDefaults.standard.set(customGrinders, forKey: Keys.customGrinders)
    }
    
    // MARK: - Computed Properties for UI
    var allAvailableBrewingMethods: [String] {
        return Self.defaultBrewingMethods + customBrewingMethods
    }
    
    var allAvailableGrinders: [String] {
        return Self.defaultGrinders + customGrinders
    }
    
    // MARK: - Custom Equipment Methods
    func addCustomBrewingMethod(_ method: String) {
        let trimmedMethod = method.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmedMethod.isEmpty && !customBrewingMethods.contains(trimmedMethod) && !Self.defaultBrewingMethods.contains(trimmedMethod) {
            customBrewingMethods.append(trimmedMethod)
            enabledBrewingMethods.append(trimmedMethod)
            saveCustomBrewingMethods()
            saveEnabledBrewingMethods()
        }
    }
    
    func addCustomGrinder(_ grinder: String) {
        let trimmedGrinder = grinder.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmedGrinder.isEmpty && !customGrinders.contains(trimmedGrinder) && !Self.defaultGrinders.contains(trimmedGrinder) {
            customGrinders.append(trimmedGrinder)
            enabledGrinders.append(trimmedGrinder)
            saveCustomGrinders()
            saveEnabledGrinders()
        }
    }
    
    func removeCustomBrewingMethod(_ method: String) {
        customBrewingMethods.removeAll { $0 == method }
        enabledBrewingMethods.removeAll { $0 == method }
        saveCustomBrewingMethods()
        saveEnabledBrewingMethods()
    }
    
    func removeCustomGrinder(_ grinder: String) {
        customGrinders.removeAll { $0 == grinder }
        enabledGrinders.removeAll { $0 == grinder }
        saveCustomGrinders()
        saveEnabledGrinders()
    }
    
    // MARK: - Validation Methods
    func isBrewingMethodEnabled(_ method: String) -> Bool {
        return enabledBrewingMethods.contains(method)
    }
    
    func isGrinderEnabled(_ grinder: String) -> Bool {
        return enabledGrinders.contains(grinder)
    }
    
    func toggleBrewingMethod(_ method: String) {
        if enabledBrewingMethods.contains(method) {
            // Don't allow disabling if it's the last enabled method
            if enabledBrewingMethods.count > 1 {
                enabledBrewingMethods.removeAll { $0 == method }
            }
        } else {
            enabledBrewingMethods.append(method)
        }
        saveEnabledBrewingMethods()
    }
    
    func toggleGrinder(_ grinder: String) {
        if enabledGrinders.contains(grinder) {
            // Don't allow disabling if it's the last enabled grinder
            if enabledGrinders.count > 1 {
                enabledGrinders.removeAll { $0 == grinder }
            }
        } else {
            enabledGrinders.append(grinder)
        }
        saveEnabledGrinders()
    }
}
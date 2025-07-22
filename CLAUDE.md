# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Kofi Kofi is a SwiftUI iOS app for tracking coffee brewing experiments. The app manages coffee inventory, brewing recipes, and detailed brewing session notes with a 5-star rating system.

## Build and Development Commands

### Building
- **Build in Xcode**: `⌘+B` or Product → Build
- **Run in Simulator**: `⌘+R` or Product → Run
- **Clean Build**: `⌘+Shift+K` or Product → Clean Build Folder

### Testing
- **Run All Tests**: `⌘+U` in Xcode or run "xcodebuild test -scheme CoffeeBrewingNotes -destination 'platform=iOS Simulator,name=iPhone 16,OS=latest'" on the terminal
- **Unit Tests**: CoffeeBrewingNotesTests target (25 tests)
- **UI Tests**: CoffeeBrewingNotesUITests target (13 tests)
- **Performance Tests**: CoffeeBrewingNotesPerformanceTests (13 benchmarks)
- **Error Tests**: CoffeeBrewingNotesErrorTests (22 edge case tests)

### Requirements
- iOS 17.0+ deployment target
- Xcode 15.0+
- Swift 5.0

## Architecture Overview

### Technology Stack
- **UI**: SwiftUI with MVVM pattern
- **Data**: Core Data with in-memory preview support
- **Structure**: Single-target iOS app with consolidated ContentView.swift

### Core Data Models
1. **Coffee**: Bean inventory (name, roaster, origin, processing method, roast level)
2. **Recipe**: Brewing parameters with method-specific attributes (dose, grind, timing, pours)
3. **BrewingNote**: Session records linking coffee + recipe with notes and ratings

### Project Structure
```
CoffeeBrewingNotes/
├── CoffeeBrewingNotesApp.swift    # App entry point
├── ContentView.swift              # All UI consolidated here (includes PreferencesView)
├── Persistence.swift              # Core Data stack
├── PreferencesManager.swift       # User preferences and equipment management
├── Models/
│   ├── CoffeeBrewingNotes.xcdatamodeld
│   ├── Coffee+Extensions.swift
│   ├── Recipe+Extensions.swift
│   └── BrewingNote+Extensions.swift
└── Views/
    └── SimpleCoffeeListView.swift # Only active view file
```

## Key Implementation Details

### View Architecture
**Important**: Due to Xcode build target issues, all main UI is consolidated in `ContentView.swift`. Individual view files in `Views/` folder exist but are not in build target except `SimpleCoffeeListView.swift`.

### Core Data Integration
- `PersistenceController` singleton manages Core Data stack
- CRUD operations: `createCoffee()`, `createRecipe()`, `createBrewingNote()`
- Usage tracking: Recipes sorted by usage count via `incrementUsageCount()`
- In-memory store for previews and testing

### Method-Specific Recipe Forms
The app supports user-configurable brewing methods with dynamic forms:
- **Pour-over** (V60-01, V60-02, Kalita Wave 155, Chemex 6-cup): Multi-stage pour scheduling
- **Espresso (Gaggia Classic Pro)**: Water output ratios with specific machine support
- **French Press**: Simplified bloom + pour schedule  
- **Aeropress**: Normal/Inverted with plunge timing

### Equipment Customization
- **Preferences System**: UserDefaults-based preferences management via PreferencesManager
- **Configurable Equipment**: Users can enable/disable brewing methods and grinders
- **Custom Equipment**: Users can add custom brewing methods and grinders
- **Default Temperature**: Configurable default water temperature instead of hardcoded values

### Search and Filtering
- **Coffee**: Search by name, roaster, origin
- **Recipe**: Search by name, method, grinder
- **Notes**: Cross-field search (coffee name, recipe name, method, notes content)
- **Rating filters**: 1-5 stars or show all

## Development Guidelines

### Data Safety
- All Core Data properties use safe accessors (e.g., `wrappedName`)
- Extensions provide default values for nil properties
- Relationship integrity maintained through bidirectional associations

### Testing Strategy
- **Unit tests**: Model validation, extensions, CRUD operations
- **UI tests**: End-to-end workflows across all tabs
- **Performance tests**: Large dataset operations (1000+ entities)
- **Error tests**: Nil handling, edge cases, validation

### Code Patterns
- Property wrappers: `@State`, `@FetchRequest`, `@Environment`
- SwiftUI declarative patterns throughout
- Method-specific logic in Recipe extensions (`isPourOver`, `supportsPours`)
- Search functionality via BrewingNote extensions (`matchesSearchText`)

## Common Development Tasks

### Managing Equipment Preferences
1. Use `PreferencesManager.shared` to access enabled brewing methods and grinders
2. Users can enable/disable equipment in Preferences tab
3. Users can add custom brewing methods and grinders through the UI
4. Default water temperature is configurable per user preference
5. At least one brewing method and grinder must remain enabled for app functionality

### Adding New Brewing Methods (Programmatically)
1. Add method to `PreferencesManager.defaultBrewingMethods` for built-in methods
2. Create method-specific section in `AddRecipeTabView` 
3. Update `Recipe` extensions for method detection (isPourOver, isEspresso, etc.)
4. Add method-specific attributes to Core Data model if needed

### User-Added Custom Equipment
- Custom brewing methods and grinders are stored in UserDefaults
- Custom equipment can be removed by users through the Preferences interface
- Custom equipment is automatically enabled when added

### Modifying Core Data Schema
1. Open `CoffeeBrewingNotes.xcdatamodeld`
2. Create new model version for migration
3. Update entity extensions with new properties
4. Test migration with existing data

### Working with Forms
- Recipe forms are dynamic based on `selectedBrewingMethod`
- Use conditional sections that show/hide based on method type
- Validate required fields before enabling save buttons
- Reset forms after successful saves

Kofi Kofi prioritizes data integrity, comprehensive testing, and user experience through method-specific brewing guidance.

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
- **Run All Tests**: `⌘+U` in Xcode
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
├── ContentView.swift              # All UI consolidated here
├── Persistence.swift              # Core Data stack
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
The app supports 6 brewing methods with dynamic forms:
- **Pour-over** (V60, Kalita, Chemex): Multi-stage pour scheduling
- **Espresso**: Water output ratios
- **French Press**: Simplified bloom + pour schedule  
- **Aeropress**: Normal/Inverted with plunge timing

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

### Adding New Brewing Methods
1. Add method to `Recipe.brewingMethodOptions`
2. Create method-specific section in `AddRecipeTabView`
3. Update `Recipe` extensions for method detection
4. Add method-specific attributes to Core Data model if needed

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
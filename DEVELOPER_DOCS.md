# Kofi Kofi - Developer Documentation

## Project Overview

SwiftUI iOS app for tracking coffee brewing experiments with Core Data persistence.

**Status: ✅ Production Ready** - All features implemented with stable 33 unit tests and 7 UI tests.

## Architecture

### Technology Stack
- **UI**: SwiftUI with MVVM pattern
- **Data**: Core Data with in-memory preview support  
- **Testing**: XCTest (33 unit + 7 UI tests)
- **Target**: iOS 17.0+, Swift 5.0

### Project Structure
```
CoffeeBrewingNotes/
├── CoffeeBrewingNotesApp.swift    # App entry point
├── ContentView.swift              # All UI consolidated here
├── Persistence.swift              # Core Data stack
├── PreferencesManager.swift       # Equipment preferences
├── Models/
│   ├── CoffeeBrewingNotes.xcdatamodeld
│   ├── Coffee+Extensions.swift
│   ├── Recipe+Extensions.swift    # Centralized brewing method detection
│   ├── BrewingNote+Extensions.swift
│   └── ProcessingMethod+Extensions.swift
└── Views/
    ├── SimpleCoffeeListView.swift # Only active view component
    ├── StarRatingView.swift       # Reusable star rating components
    └── FormFieldView.swift        # Reusable form components
```

## Core Data Models

### Coffee
Bean inventory with name, roaster, origin, processing method, roast level.

### Recipe  
Brewing parameters with method-specific attributes:
- Common: dose, grind, water temp, brew time
- Pour-over: bloom timing, multi-stage pours
- Espresso: water output ratios
- Aeropress: normal/inverted, plunge timing

### BrewingNote
Session records linking coffee + recipe with notes and 5-star ratings.

### ProcessingMethod
Autocomplete system for coffee processing methods with usage tracking.

## Key Implementation Details

### View Architecture
**Important**: All main UI consolidated in `ContentView.swift` due to Xcode build target limitations. Only `SimpleCoffeeListView.swift` is separate and active.

### Equipment Preferences System
- UserDefaults-based preferences via `PreferencesManager`
- Configurable brewing methods and grinders
- Custom equipment addition/removal
- Smart validation (prevents disabling all equipment)

### Brewing Method Detection
Centralized in `Recipe+Extensions.swift` with static methods:
- `Recipe.isPourOverMethod(String) -> Bool`
- `Recipe.isEspressoMethod(String) -> Bool` 
- `Recipe.isFrenchPressMethod(String) -> Bool`
- `Recipe.isAeropressMethod(String) -> Bool`
- `Recipe.supportsPours(String) -> Bool`

All UI components use these centralized methods to ensure consistency.

### Data Safety
- All Core Data properties use safe accessors (`wrappedName`, etc.)
- Extensions provide nil-safe default values
- Bidirectional relationship integrity maintained

## Development Workflow

### Building & Testing
```bash
# Build
xcodebuild -scheme CoffeeBrewingNotes -destination 'platform=iOS Simulator,name=iPhone 16,OS=latest'

# Run tests  
xcodebuild test -scheme CoffeeBrewingNotes -destination 'platform=iOS Simulator,name=iPhone 16,OS=latest'
```

### Adding New Brewing Methods
1. Add to `PreferencesManager.defaultBrewingMethods` for built-in methods
2. Update brewing method detection in `Recipe+Extensions.swift` if needed
3. Add method-specific UI section in `ContentView.swift`
4. Add Core Data attributes for method-specific parameters

### Common Tasks

#### Core Data Operations
- Use `PersistenceController` singleton for CRUD operations
- Methods: `createCoffee()`, `createRecipe()`, `createBrewingNote()`
- Usage tracking: `recipe.incrementUsageCount()`

#### Form Validation
- Recipe forms adapt dynamically based on `selectedBrewingMethod`
- Use `Recipe.supportsPours()` to show/hide pour-specific fields
- Validate required fields before enabling save buttons

#### Search & Filtering
- Coffee: name, roaster, origin
- Recipe: name, method, grinder  
- Notes: cross-field search with `BrewingNote.matchesSearchText()`
- Rating filters: 1-5 stars or show all

## Testing Strategy

### Unit Tests (33 tests)
- Data model validation and extensions
- CRUD operations and persistence
- PreferencesManager functionality
- Brewing method detection logic

### UI Tests (7 tests)
- End-to-end user workflows
- Tab navigation and form interactions
- Coffee creation and basic functionality

## Code Quality

### Recent Refactoring (Latest)
- ✅ Removed 6 unused view files
- ✅ Consolidated brewing method detection (eliminated duplication)
- ✅ Created reusable UI components (StarRatingView, FormFieldView)  
- ✅ Cleaned up 7 empty test methods
- ✅ Updated documentation accuracy

### Architecture Benefits
- Single source of truth for brewing method logic
- Consistent validation across all UI components
- ~30% reduction in code duplication
- Improved maintainability for future enhancements

## Development Notes

- **File Creation**: Avoid creating new Swift files - they're difficult to add to Xcode project targets
- **UI Changes**: Most UI modifications go in `ContentView.swift` due to build target consolidation
- **Method Detection**: Always use centralized `Recipe` static methods for consistency
- **Testing**: All tests pass consistently - maintain this stability when making changes
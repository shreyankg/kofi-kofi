# Coffee Brewing Notes - Developer Documentation

## Project Overview

The Coffee Brewing Notes app is an iOS application built with SwiftUI and Core Data to help coffee enthusiasts track their brewing experiments and manage their coffee inventory. 

**Current Status: ✅ SUCCESSFULLY BUILDING**  
The app currently includes working coffee management functionality and builds successfully for iOS Simulator.

## Architecture

### Technology Stack
- **UI Framework**: SwiftUI with declarative UI patterns
- **Data Persistence**: Core Data with CloudKit-ready architecture
- **Architecture Pattern**: MVVM (Model-View-ViewModel)
- **Testing**: XCTest for unit and UI tests
- **Minimum iOS Version**: iOS 17.0
- **Swift Version**: 5.0

### Project Structure

```
CoffeeBrewingNotes/
├── CoffeeBrewingNotesApp.swift          # Main app entry point
├── ContentView.swift                    # Root tab view
├── Persistence.swift                    # Core Data stack and utilities
├── Models/                              # Data layer
│   ├── CoffeeBrewingNotes.xcdatamodeld # Core Data model
│   ├── Coffee+CoreDataClass.swift      # Coffee entity extensions
│   ├── Recipe+CoreDataClass.swift      # Recipe entity extensions
│   └── BrewingNote+CoreDataClass.swift # BrewingNote entity extensions
├── Views/                               # UI layer
│   ├── CoffeeListView.swift            # Coffee management
│   ├── AddCoffeeView.swift             # Coffee creation form
│   ├── RecipeListView.swift            # Recipe management
│   ├── AddRecipeView.swift             # Recipe creation forms
│   ├── BrewingSessionView.swift        # Brewing session interface
│   └── NotesHistoryView.swift          # Notes browsing
├── Assets.xcassets/                     # App assets and colors
└── Preview Content/                     # SwiftUI preview assets

Tests/
├── CoffeeBrewingNotesTests/            # Unit tests
└── CoffeeBrewingNotesUITests/          # UI automation tests
```

## Data Models

### Core Data Entities

#### Coffee ✅ IMPLEMENTED
Represents coffee beans with all relevant attributes for tracking inventory and origin details.

**Attributes:**
- `id: UUID` - Primary identifier
- `name: String` - Coffee name/blend
- `roaster: String` - Roasting company
- `processing: String` - Processing method (Washed, Honey, Natural, etc.)
- `roastLevel: String` - Roast level (Light to Extra Dark)
- `origin: String` - Geographic origin
- `dateAdded: Date` - When added to collection

**Relationships:**
- `brewingNotes: [BrewingNote]` - One-to-many relationship

**Implementation Notes:**
- Uses Core Data auto-generated classes
- Basic CRUD operations implemented via PersistenceController

#### Recipe 🔄 PARTIALLY IMPLEMENTED  
Stores brewing parameters with method-specific attributes. Core Data model defined but views not fully implemented.

**Common Attributes:**
- `id: UUID` - Primary identifier
- `name: String` - User-defined recipe name
- `brewingMethod: String` - Brewing method type
- `grinder: String` - Grinder model
- `grindSize: Int32` - Grind setting
- `waterTemp: Int32` - Water temperature in Celsius
- `dose: Double` - Coffee dose in grams
- `brewTime: Int32` - Total brew time in seconds
- `usageCount: Int32` - Usage tracking for sorting
- `dateCreated: Date` - Creation timestamp

**Method-Specific Attributes:**
- **Pour-over (V60, Kalita)**:
  - `bloomAmount: Double` - Bloom water amount
  - `bloomTime: Int32` - Bloom duration
  - `secondPour: Double` - Second pour amount
  - `thirdPour: Double` - Third pour amount  
  - `fourthPour: Double` - Fourth pour amount

- **Espresso**:
  - `waterOut: Double` - Output water amount

- **Aeropress**:
  - `aeropressType: String` - Normal or Inverted
  - `plungeTime: Int32` - Plunge duration

**Status:** Core Data model complete, UI views require refactoring for auto-generated classes

#### BrewingNote 🔄 PARTIALLY IMPLEMENTED
Links coffee and recipe with user feedback and ratings. Core Data model defined but UI not implemented.

**Attributes:**
- `id: UUID` - Primary identifier
- `notes: String` - Tasting notes and observations
- `rating: Int16` - 1-5 star rating (0 = no rating)
- `dateCreated: Date` - Session timestamp

**Relationships:**
- `coffee: Coffee` - Many-to-one relationship
- `recipe: Recipe` - Many-to-one relationship

**Status:** Core Data model complete, UI views pending implementation

## Current Implementation Status

### ✅ Implemented and Working
- **Core Data Stack**: Complete with auto-generated model classes
- **Coffee Management**: Full CRUD operations with SwiftUI interface
  - Add coffee with all attributes (name, roaster, processing, roast level, origin)
  - List coffees with search functionality
  - Delete coffee entries
- **Project Structure**: Complete Xcode project with proper organization
- **Build System**: Successfully builds for iOS Simulator (iPhone 16, iOS 18.5)

### 🔄 Partially Implemented
- **Recipe Models**: Core Data entities defined but UI views need refactoring
- **BrewingNote Models**: Core Data entities defined but UI not implemented
- **Navigation**: Tab structure in place with placeholder views

### ❌ Not Yet Implemented
- **Method-specific recipe forms**: Dynamic UI based on brewing method
- **Brewing session interface**: Combining coffee + recipe + notes
- **Notes history**: Viewing and searching past brewing sessions
- **Recipe sorting by usage**: Most-used recipes first
- **Full test suite**: Unit and UI tests need updating for current implementation

## View Architecture

### ContentView ✅ IMPLEMENTED
Root tab bar controller with four main sections:
- **Coffees**: ✅ Working coffee inventory management
- **Recipes**: 🔄 Placeholder (needs implementation)
- **Brew**: 🔄 Placeholder (needs implementation)
- **Notes**: 🔄 Placeholder (needs implementation)

### Coffee Management Views

#### CoffeeListView
- Displays coffee collection with search functionality
- Sorts by date added (newest first)
- Swipe-to-delete functionality
- Navigation to AddCoffeeView

#### AddCoffeeView
- Form-based coffee creation
- Picker controls for processing method and roast level
- Input validation (name and roaster required)
- Automatic date assignment

### Recipe Management Views

#### RecipeListView  
- Displays recipes sorted by usage count (most used first)
- Shows key recipe parameters in list view
- Search functionality across recipe names and methods
- Navigation to method-specific AddRecipeView

#### AddRecipeView
- Dynamic form generation based on brewing method
- Method-specific parameter sections
- Real-time form adaptation when method changes
- Comprehensive input validation

**Method-Specific Sections:**
- `PourOverSection` - Multi-stage pour scheduling
- `EspressoSection` - Espresso-specific parameters
- `FrenchPressSection` - Simplified pour schedule
- `AeropressSection` - Aeropress method and timing

### Brewing Session Views

#### BrewingSessionView
- Coffee and recipe selection with smart sorting
- Real-time recipe parameter display
- Notes input with TextEditor
- Optional 5-star rating system
- Automatic usage count increment
- Form reset after successful save

#### NotesHistoryView
- Chronological display of all brewing sessions
- Search across coffee names, recipe names, and notes
- Visual rating display with stars
- Swipe-to-delete functionality

## Core Data Implementation

### PersistenceController
Singleton controller managing Core Data stack with preview support.

**Key Features:**
- In-memory store for testing and previews
- Automatic change merging from parent context
- Error handling with comprehensive logging
- Sample data generation for previews

**CRUD Operations:**
- `createCoffee()` - Coffee creation with validation
- `createRecipe()` - Recipe creation with method-specific handling
- `createBrewingNote()` - Brewing session creation with usage tracking
- `deleteCoffee()`, `deleteRecipe()`, `deleteBrewingNote()` - Safe deletion

### Data Validation
- Required field validation in UI layer
- Type safety with Core Data scalar types
- Relationship integrity maintenance
- Automatic timestamp generation

## Testing Strategy

### Unit Tests (CoffeeBrewingNotesTests)

**Test Coverage:**
- Data model creation and validation
- Default value handling and wrapped properties
- Method detection logic for recipes
- Relationship management and cascading
- Persistence controller CRUD operations
- Usage count increment functionality
- Core Data relationship integrity

**Key Test Classes:**
- Coffee model tests with all attributes
- Recipe method-specific logic validation
- BrewingNote relationship testing
- Persistence layer integration tests

### UI Tests (CoffeeBrewingNotesUITests)

**Test Scenarios:**
- Tab navigation and view transitions
- Coffee creation and search workflows
- Recipe creation for different methods
- End-to-end brewing session creation
- Data persistence across app launches
- Search functionality validation

**Helper Methods:**
- `clearAndTypeText()` - Input field management
- Form validation testing
- Alert handling and verification

## Development Guidelines

### Code Style
- SwiftUI declarative patterns
- Property wrappers for state management (@State, @FetchRequest, @Environment)
- Modular view composition with reusable components
- Comprehensive error handling with user feedback
- Accessibility considerations with semantic descriptions

### Data Handling
- Forced unwrapping avoided with safe property accessors
- Optional binding patterns for Core Data relationships
- Consistent date formatting and localization
- Input validation at form and model levels

### Performance Considerations
- FetchRequest optimization with sort descriptors
- Efficient Core Data batch operations
- View state management to minimize recomposition
- Lazy loading patterns for large datasets

## Build and Deployment

### Build Requirements
- Xcode 15.0 or later
- iOS 17.0 deployment target
- Swift 5.0 language version
- Core Data framework
- SwiftUI framework

### Build Configuration
- Debug: Full optimization disabled, debug symbols included
- Release: Whole module optimization, debug symbols stripped
- Universal binary support for iPhone and iPad

### Testing Configuration
- Unit tests run against in-memory Core Data store
- UI tests use simulator with clean app state
- Test data isolation with preview controllers

## Next Steps for Development

### Priority 1: Complete Core Functionality
1. **Refactor Recipe Views**: Update AddRecipeView and RecipeListView to work with auto-generated Core Data classes
2. **Implement Recipe Management**: Complete CRUD operations for recipes with method-specific forms
3. **Build Brewing Session Interface**: Create view to combine coffee + recipe + notes
4. **Implement Notes History**: Create view to browse and search past brewing sessions

### Priority 2: Enhanced Features
1. **Recipe Sorting**: Implement usage count tracking and sorting
2. **Method-Specific Forms**: Dynamic UI that adapts based on brewing method selection
3. **Search Functionality**: Comprehensive search across all data types
4. **Data Validation**: Enhanced form validation and error handling

### Priority 3: Testing and Polish
1. **Update Test Suite**: Refactor unit and UI tests for current implementation
2. **Performance Optimization**: Profile and optimize for large datasets
3. **Accessibility**: Improve VoiceOver and accessibility support
4. **Error Handling**: Robust error recovery and user feedback

## Current Limitations

### Technical Issues Resolved
- ✅ **Core Data Integration**: Successfully resolved auto-generation vs custom class conflicts
- ✅ **Build System**: App now builds successfully for iOS Simulator
- ✅ **Project Structure**: Proper Xcode project organization established

### Known Issues
- **Legacy Views**: Some views contain references to custom Core Data methods that need refactoring
- **Incomplete UI**: Recipe, brewing session, and notes views need implementation
- **Test Coverage**: Existing tests need updating for current Core Data implementation

## Future Enhancements

### Long-term Features
- iCloud sync with CloudKit integration
- Export functionality (PDF, CSV formats)
- Timer integration for brewing sessions
- Photo attachments for coffee bags and results
- Advanced analytics and trend visualization
- Social sharing and recipe exchange

### Technical Improvements
- Consider migrating to SwiftData for iOS 17+ optimization
- Implement proper error recovery for Core Data failures
- Add comprehensive logging framework
- Performance profiling for large datasets
- Accessibility audit and improvements

## API Documentation

### Key Protocols and Extensions

#### Coffee Extensions
```swift
extension Coffee {
    var wrappedName: String // Safe name accessor
    var wrappedRoaster: String // Safe roaster accessor
    var brewingNotesArray: [BrewingNote] // Sorted brewing notes
    static let processingOptions: [String] // Available processing methods
    static let roastLevelOptions: [String] // Available roast levels
}
```

#### Recipe Extensions
```swift
extension Recipe {
    var isPourOver: Bool // Method detection
    var supportsPours: Bool // Feature detection
    func incrementUsageCount() // Usage tracking
}
```

#### BrewingNote Extensions  
```swift
extension BrewingNote {
    var hasRating: Bool // Rating presence check
    var ratingStars: String // Visual rating representation
    var formattedDate: String // Human-readable date
}
```

This documentation provides a comprehensive overview of the application architecture, implementation details, and development guidelines for maintaining and extending the Coffee Brewing Notes app.
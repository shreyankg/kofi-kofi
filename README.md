# Coffee Brewing Notes iOS App

A comprehensive iOS app for coffee enthusiasts to track their brewing experiments, manage coffee inventory, and maintain detailed brewing notes.

## Features

### Coffee Management
- Add and manage coffee beans with detailed attributes:
  - Name and Roaster
  - Origin (country/region)
  - Processing method (Washed, Honey, Natural, etc.)
  - Roast level (Light to Extra Dark)
- Search and filter coffee collection
- Automatic date tracking for when coffees were added

### Recipe Management
- Create brewing recipes with method-specific parameters
- Supported brewing methods:
  - **V60 (01 & 02)**: Multi-stage pour schedule with bloom timing
  - **Kalita Wave**: Pour-over with controlled flow rate
  - **Espresso**: Water out ratio and extraction timing
  - **French Press**: Simplified pour schedule with steeping time
  - **Aeropress**: Normal/Inverted methods with plunge timing
- Recipe sorting by usage count (most used recipes appear first)
- Comprehensive parameter tracking:
  - Grinder type and grind size
  - Water temperature
  - Coffee dose and brew time
  - Method-specific attributes

### Brewing Sessions
- Combine any coffee with any recipe
- Add detailed tasting notes
- Optional 5-star rating system
- Automatic tracking of recipe usage for intelligent sorting
- Date and time stamping of each session

### Notes History
- View all past brewing sessions
- Search through notes, coffee names, and recipe names
- Chronological organization with most recent first
- Rating visualization with star display

## Technical Details

### Architecture
- **SwiftUI** for modern, declarative UI
- **Core Data** for local data persistence
- **MVVM** pattern with ViewModels for business logic
- **Relationship management** between Coffee, Recipe, and BrewingNote entities

### Data Models
- **Coffee**: Stores coffee bean information and relationships to brewing notes
- **Recipe**: Stores brewing parameters with method-specific attributes
- **BrewingNote**: Links coffee and recipe with user notes and ratings

### Method-Specific Features
The app intelligently adapts the recipe form based on the selected brewing method:
- Pour-over methods show bloom timing and multiple pour stages
- Espresso shows water output ratios
- Aeropress includes inversion type and plunge timing
- All methods track core parameters like grind size and water temperature

### Testing
- **Unit Tests**: Comprehensive coverage of data models and persistence
- **UI Tests**: End-to-end testing of key user flows
- **Mock Data**: Preview and testing environments with sample data

## Usage

1. **Add Coffees**: Start by adding coffee beans to your collection
2. **Create Recipes**: Build brewing recipes for your preferred methods
3. **Brew Sessions**: Select a coffee and recipe, then add your tasting notes
4. **Track History**: Review past sessions and refine your brewing technique

## Development

### Requirements
- iOS 17.0+
- Xcode 15.0+
- Swift 5.0+

### Project Structure
```
CoffeeBrewingNotes/
├── Models/
│   ├── CoffeeBrewingNotes.xcdatamodeld
│   ├── Coffee+CoreDataClass.swift
│   ├── Recipe+CoreDataClass.swift
│   └── BrewingNote+CoreDataClass.swift
├── Views/
│   ├── CoffeeListView.swift
│   ├── AddCoffeeView.swift
│   ├── RecipeListView.swift
│   ├── AddRecipeView.swift
│   ├── BrewingSessionView.swift
│   └── NotesHistoryView.swift
├── CoffeeBrewingNotesApp.swift
├── ContentView.swift
└── Persistence.swift
```

### Testing
- Run unit tests: `⌘+U` in Xcode
- Run UI tests: Select CoffeeBrewingNotesUITests scheme and test

## Future Enhancements

- iCloud sync for cross-device access
- Export brewing notes to PDF or CSV
- Timer integration for brew sessions
- Photo attachments for coffee bags and brew results
- Advanced analytics and brewing trends
- Recipe sharing with other users

## License

This project is created for educational and personal use.
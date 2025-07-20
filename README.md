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
  - **V60 (01, 02, 03)**: Multi-stage pour schedule with bloom timing
  - **Kalita Wave (155, 185)**: Pour-over with controlled flow rate
  - **Chemex (6-cup, 8-cup)**: Large batch pour-over brewing
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
- View all past brewing sessions in chronological order
- Comprehensive search across notes, coffee names, recipe names, and brewing methods
- Filter by star ratings (1-5 stars or show all)
- Visual rating display with stars
- Swipe-to-delete functionality

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
- **Unit Tests**: 25 tests covering data models, extensions, and persistence
- **UI Tests**: 13 end-to-end tests for complete user workflows
- **Performance Tests**: 13 benchmarks for large dataset operations
- **Error Handling Tests**: 22 tests for edge cases and validation
- **Total Coverage**: 73 test methods ensuring comprehensive validation

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
│   ├── Coffee+Extensions.swift
│   ├── Recipe+Extensions.swift
│   └── BrewingNote+Extensions.swift
├── Views/
│   └── SimpleCoffeeListView.swift
├── CoffeeBrewingNotesApp.swift
├── ContentView.swift (consolidated UI)
└── Persistence.swift
```

**Note**: All main UI functionality is consolidated in `ContentView.swift` to ensure reliable builds. Individual view files in the Views folder are legacy and not actively used except for `SimpleCoffeeListView.swift`.

### Testing
- Run all tests: `⌘+U` in Xcode
- Tests include unit, UI, performance, and error handling scenarios

## Future Enhancements

- iCloud sync for cross-device access
- Export brewing notes to PDF or CSV
- Timer integration for brew sessions
- Photo attachments for coffee bags and brew results
- Advanced analytics and brewing trends
- Recipe sharing with other users

## License

This project is licensed under the MIT License - see below for details.

```
MIT License

Copyright (c) 2025 Coffee Brewing Notes

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

**Note**: This project includes code generated with AI assistance (Claude).
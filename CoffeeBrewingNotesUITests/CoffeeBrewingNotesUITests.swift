import XCTest

final class CoffeeBrewingNotesUITests: XCTestCase {
    
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }
    
    override func tearDownWithError() throws {
        app = nil
    }
    
    // MARK: - Tab Navigation Tests
    
    func testTabNavigation() throws {
        // Test all tabs are accessible
        XCTAssertTrue(app.tabBars.buttons["Coffees"].exists)
        XCTAssertTrue(app.tabBars.buttons["Recipes"].exists)
        XCTAssertTrue(app.tabBars.buttons["Brew"].exists)
        XCTAssertTrue(app.tabBars.buttons["Notes"].exists)
        
        // Test navigation between tabs
        app.tabBars.buttons["Recipes"].tap()
        XCTAssertTrue(app.navigationBars["Recipes"].exists)
        
        app.tabBars.buttons["Brew"].tap()
        XCTAssertTrue(app.navigationBars["New Brew Session"].exists)
        
        app.tabBars.buttons["Notes"].tap()
        XCTAssertTrue(app.navigationBars["Brewing History"].exists)
        
        app.tabBars.buttons["Coffees"].tap()
        XCTAssertTrue(app.navigationBars["Coffees"].exists)
    }
    
    // MARK: - Coffee Management Tests
    
    func testAddCoffee() throws {
        // Navigate to Coffees tab
        app.tabBars.buttons["Coffees"].tap()
        
        // Tap add button
        app.navigationBars["Coffees"].buttons.matching(identifier: "Add").firstMatch.tap()
        
        // Wait for Add Coffee sheet to appear
        let addCoffeeTitle = app.navigationBars["Add Coffee"]
        XCTAssertTrue(addCoffeeTitle.waitForExistence(timeout: 2))
        
        // Fill in coffee details
        let nameField = app.textFields["Coffee Name"]
        XCTAssertTrue(nameField.exists)
        nameField.tap()
        nameField.typeText("Ethiopian Yirgacheffe")
        
        let roasterField = app.textFields["Roaster"]
        XCTAssertTrue(roasterField.exists)
        roasterField.tap()
        roasterField.typeText("Blue Bottle Coffee")
        
        let originField = app.textFields["Origin"]
        XCTAssertTrue(originField.exists)
        originField.tap()
        originField.typeText("Ethiopia")
        
        // Select processing method using the picker (should default to Washed)
        let processingPicker = app.buttons["Processing Method"]
        if processingPicker.exists {
            processingPicker.tap()
            // Look for Washed option in the picker
            let washedOption = app.buttons.containing(.staticText, identifier: "Washed").firstMatch
            if washedOption.exists {
                washedOption.tap()
            }
        }
        
        // Adjust roast level slider to Light (index 0)
        let slider = app.sliders.firstMatch
        if slider.exists {
            slider.adjust(toNormalizedSliderPosition: 0.0) // Light roast
        }
        
        // Save coffee
        app.navigationBars["Add Coffee"].buttons["Save"].tap()
        
        // Wait for sheet to dismiss and verify coffee appears in list
        XCTAssertTrue(app.navigationBars["Coffees"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.staticTexts["Ethiopian Yirgacheffe"].exists)
        XCTAssertTrue(app.staticTexts["Blue Bottle Coffee"].exists)
    }
    
    func testSearchCoffees() throws {
        // First add a coffee to search for
        try testAddCoffee()
        
        // Navigate to Coffees tab
        app.tabBars.buttons["Coffees"].tap()
        
        // Use search
        let searchField = app.searchFields["Search coffees..."]
        XCTAssertTrue(searchField.exists)
        searchField.tap()
        searchField.typeText("Ethiopian")
        
        // Verify search results
        XCTAssertTrue(app.staticTexts["Ethiopian Yirgacheffe"].exists)
    }
    
    func testEditCoffee() throws {
        // First add a coffee
        try testAddCoffee()
        
        // Navigate to Coffees tab
        app.tabBars.buttons["Coffees"].tap()
        
        // Tap on the coffee to edit it (it's in a NavigationLink)
        app.staticTexts["Ethiopian Yirgacheffe"].tap()
        
        // Wait for Edit Coffee view to appear
        let editCoffeeTitle = app.navigationBars["Edit Coffee"]
        XCTAssertTrue(editCoffeeTitle.waitForExistence(timeout: 2))
        
        // Edit the coffee name
        let nameField = app.textFields["Coffee Name"]
        XCTAssertTrue(nameField.exists)
        nameField.clearAndTypeText("Updated Ethiopian Coffee")
        
        // Edit the roaster
        let roasterField = app.textFields["Roaster"]
        roasterField.clearAndTypeText("Counter Culture Coffee")
        
        // Change processing method using the picker
        let processingPicker = app.buttons["Processing Method"]
        if processingPicker.exists {
            processingPicker.tap()
            // Look for Natural option in the picker
            let naturalOption = app.buttons.containing(.staticText, identifier: "Natural").firstMatch
            if naturalOption.exists {
                naturalOption.tap()
            }
        }
        
        // Save the changes
        app.navigationBars["Edit Coffee"].buttons["Save"].tap()
        
        // Wait to return to coffee list
        XCTAssertTrue(app.navigationBars["Coffees"].waitForExistence(timeout: 2))
        
        // Verify the updated information appears
        XCTAssertTrue(app.staticTexts["Updated Ethiopian Coffee"].exists)
        XCTAssertTrue(app.staticTexts["Counter Culture Coffee"].exists)
    }
    
    func testAddCustomProcessingMethod() throws {
        // Navigate to Coffees tab
        app.tabBars.buttons["Coffees"].tap()
        
        // Tap add button
        app.navigationBars["Coffees"].buttons.matching(identifier: "Add").firstMatch.tap()
        
        // Wait for Add Coffee sheet to appear
        let addCoffeeTitle = app.navigationBars["Add Coffee"]
        XCTAssertTrue(addCoffeeTitle.waitForExistence(timeout: 2))
        
        // Fill basic coffee details
        let nameField = app.textFields["Coffee Name"]
        nameField.tap()
        nameField.typeText("Test Coffee")
        
        let roasterField = app.textFields["Roaster"]
        roasterField.tap()
        roasterField.typeText("Test Roaster")
        
        // Tap "Add Custom Method" button
        app.buttons["Add Custom Method"].tap()
        
        // Wait for custom method sheet to appear
        let addMethodTitle = app.navigationBars["Add Method"]
        XCTAssertTrue(addMethodTitle.waitForExistence(timeout: 2))
        
        // Enter custom method name
        let methodField = app.textFields["Method Name"]
        XCTAssertTrue(methodField.exists)
        methodField.tap()
        methodField.typeText("Experimental Fermentation")
        
        // Save the custom method
        app.navigationBars["Add Method"].buttons["Save"].tap()
        
        // Wait to return to add coffee screen
        XCTAssertTrue(app.navigationBars["Add Coffee"].waitForExistence(timeout: 2))
        
        // Complete the coffee creation
        app.navigationBars["Add Coffee"].buttons["Save"].tap()
        
        // Wait for sheet to dismiss and verify coffee was created
        XCTAssertTrue(app.navigationBars["Coffees"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.staticTexts["Test Coffee"].exists)
    }
    
    func testRoastLevelSlider() throws {
        // Navigate to Coffees tab
        app.tabBars.buttons["Coffees"].tap()
        
        // Tap add button
        app.navigationBars["Coffees"].buttons["Add"].tap()
        
        // Fill basic details
        app.textFields["Coffee Name"].tap()
        app.textFields["Coffee Name"].typeText("Slider Test Coffee")
        
        app.textFields["Roaster"].tap()
        app.textFields["Roaster"].typeText("Test Roaster")
        
        // Find and interact with roast level slider
        let slider = app.sliders.firstMatch
        XCTAssertTrue(slider.exists)
        
        // Adjust slider to different position
        slider.adjust(toNormalizedSliderPosition: 0.8) // Should be "Dark"
        
        // Verify the displayed roast level changed
        XCTAssertTrue(app.staticTexts["Dark"].exists)
        
        // Save the coffee
        app.navigationBars.buttons["Save"].tap()
        
        // Verify coffee was created
        XCTAssertTrue(app.staticTexts["Slider Test Coffee"].exists)
    }
    
    // MARK: - Recipe Management Tests
    
    func testAddV60Recipe() throws {
        // Navigate to Recipes tab
        app.tabBars.buttons["Recipes"].tap()
        
        // Tap add button
        app.navigationBars["Recipes"].buttons.matching(identifier: "Add").firstMatch.tap()
        
        // Wait for Add Recipe sheet to appear
        let addRecipeTitle = app.navigationBars["Add Recipe"]
        XCTAssertTrue(addRecipeTitle.waitForExistence(timeout: 2))
        
        // Select V60 brewing method using picker
        let brewingMethodPicker = app.buttons["Brewing Method"]
        XCTAssertTrue(brewingMethodPicker.exists)
        brewingMethodPicker.tap()
        
        // Look for V60-01 in the picker options
        let v60Option = app.buttons.containing(.staticText, identifier: "V60-01").firstMatch
        if v60Option.exists {
            v60Option.tap()
        } else {
            // Fallback - just use first available option
            let firstMethodOption = app.buttons.firstMatch
            firstMethodOption.tap()
        }
        
        // Fill in grind size field
        let grindSizeField = app.textFields["e.g. 20, 3.2, coarse"]
        XCTAssertTrue(grindSizeField.exists)
        grindSizeField.tap()
        grindSizeField.typeText("20")
        
        // Fill in water temperature
        let waterTempField = app.textFields["°C"]
        XCTAssertTrue(waterTempField.exists)
        waterTempField.tap()
        waterTempField.clearAndTypeText("93")
        
        // Fill in dose
        let doseField = app.textFields["Grams"]
        XCTAssertTrue(doseField.exists)
        doseField.tap()
        doseField.typeText("20")
        
        // Fill in brew time
        let brewTimeField = app.textFields["Seconds"]
        XCTAssertTrue(brewTimeField.exists)
        brewTimeField.tap()
        brewTimeField.typeText("240")
        
        // Fill in pour schedule (V60 specific - bloom amount)
        // Look for Pour Over section fields
        let bloomAmountFields = app.textFields.matching(identifier: "Grams").allElementsBoundByIndex
        if bloomAmountFields.count > 1 {
            bloomAmountFields[1].tap()
            bloomAmountFields[1].typeText("40")
        }
        
        // Save recipe
        app.navigationBars["Add Recipe"].buttons["Save"].tap()
        
        // Wait for sheet to dismiss and verify recipe appears in list
        XCTAssertTrue(app.navigationBars["Recipes"].waitForExistence(timeout: 2))
        
        // Verify recipe appears in list (look for any recipe entry)
        XCTAssertTrue(app.staticTexts.containing(.staticText, identifier:"V60").firstMatch.exists)
    }
    
    func testAddEspressoRecipe() throws {
        // Navigate to Recipes tab
        app.tabBars.buttons["Recipes"].tap()
        
        // Tap add button
        app.navigationBars["Recipes"].buttons.matching(identifier: "Add").firstMatch.tap()
        
        // Wait for Add Recipe sheet to appear
        let addRecipeTitle = app.navigationBars["Add Recipe"]
        XCTAssertTrue(addRecipeTitle.waitForExistence(timeout: 2))
        
        // Select Espresso brewing method from picker
        let brewingMethodPicker = app.buttons["Brewing Method"]
        XCTAssertTrue(brewingMethodPicker.exists)
        brewingMethodPicker.tap()
        
        // Look for Espresso in the picker options
        let espressoOption = app.buttons.containing(.staticText, identifier: "Espresso").firstMatch
        if espressoOption.exists {
            espressoOption.tap()
        } else {
            // If not found, dismiss picker and continue with default
            app.tap()
        }
        
        // Fill in grind size field
        let grindSizeField = app.textFields["e.g. 20, 3.2, coarse"]
        XCTAssertTrue(grindSizeField.exists)
        grindSizeField.tap()
        grindSizeField.typeText("10")
        
        // Fill in water temperature
        let waterTempField = app.textFields["°C"]
        XCTAssertTrue(waterTempField.exists)
        waterTempField.tap()
        waterTempField.clearAndTypeText("93")
        
        // Fill in dose
        let doseField = app.textFields["Grams"]
        XCTAssertTrue(doseField.exists)
        doseField.tap()
        doseField.typeText("18")
        
        // Fill in brew time
        let brewTimeField = app.textFields["Seconds"]
        XCTAssertTrue(brewTimeField.exists)
        brewTimeField.tap()
        brewTimeField.typeText("28")
        
        // Fill in espresso-specific parameter (water out) if section exists
        let waterOutFields = app.textFields.matching(identifier: "Grams").allElementsBoundByIndex
        if waterOutFields.count > 1 {
            waterOutFields[1].tap()
            waterOutFields[1].typeText("36")
        }
        
        // Save recipe
        app.navigationBars["Add Recipe"].buttons["Save"].tap()
        
        // Wait for sheet to dismiss and verify recipe appears in list
        XCTAssertTrue(app.navigationBars["Recipes"].waitForExistence(timeout: 2))
        
        // Verify recipe appears in list
        XCTAssertTrue(app.staticTexts.containing(.staticText, identifier:"Espresso").firstMatch.exists)
    }
    
    // MARK: - Brewing Session Tests
    
    func testBrewingSession() throws {
        // First add a coffee and recipe
        try testAddCoffee()
        try testAddV60Recipe()
        
        // Navigate to Brew tab
        app.tabBars.buttons["Brew"].tap()
        
        // Wait for Brew session view to appear
        XCTAssertTrue(app.navigationBars["New Brew Session"].waitForExistence(timeout: 2))
        
        // Select coffee using picker
        let coffeePicker = app.buttons["Coffee"]
        XCTAssertTrue(coffeePicker.exists)
        coffeePicker.tap()
        
        // Look for the coffee we added
        let coffeeOption = app.buttons.containing(.staticText, identifier: "Ethiopian Yirgacheffe - Blue Bottle Coffee").firstMatch
        if coffeeOption.exists {
            coffeeOption.tap()
        } else {
            // Fallback - use any available coffee
            let availableCoffee = app.buttons.containing(.staticText, identifier: "Ethiopian").firstMatch
            if availableCoffee.exists {
                availableCoffee.tap()
            }
        }
        
        // Select recipe using picker
        let recipePicker = app.buttons["Recipe"]
        XCTAssertTrue(recipePicker.exists)
        recipePicker.tap()
        
        // Look for V60 recipe
        let recipeOption = app.buttons.containing(.staticText, identifier: "V60").firstMatch
        if recipeOption.exists {
            recipeOption.tap()
        } else {
            // Use first available recipe
            let firstRecipe = app.buttons.firstMatch
            if firstRecipe.exists {
                firstRecipe.tap()
            }
        }
        
        // Add notes in the TextEditor
        let notesEditor = app.textViews.firstMatch
        XCTAssertTrue(notesEditor.exists)
        notesEditor.tap()
        notesEditor.typeText("Great brew today! Sweet and bright with citrus notes.")
        
        // Add rating by tapping the 4th star
        let starButtons = app.buttons.matching(NSPredicate(format: "identifier CONTAINS 'star'"))
        if starButtons.count >= 4 {
            starButtons.allElementsBoundByIndex[3].tap() // 4th star (0-indexed)
        }
        
        // Save brewing session
        app.buttons["Save Brewing Session"].tap()
        
        // Wait for and verify alert appears
        let sessionSavedAlert = app.alerts["Session Saved"]
        XCTAssertTrue(sessionSavedAlert.waitForExistence(timeout: 2))
        sessionSavedAlert.buttons["OK"].tap()
        
        // Verify form fields show default state after reset
        XCTAssertTrue(app.buttons["Select a coffee"].exists)
        XCTAssertTrue(app.buttons["Select a recipe"].exists)
    }
    
    // MARK: - Notes History Tests
    
    func testNotesHistory() throws {
        // First create a brewing session
        try testBrewingSession()
        
        // Navigate to Notes tab
        app.tabBars.buttons["Notes"].tap()
        
        // Verify brewing note appears
        XCTAssertTrue(app.staticTexts["Ethiopian Yirgacheffe"].exists)
        // Auto-generated recipe name will contain V60-01 - GrinderName
        XCTAssertTrue(app.staticTexts.containing(.staticText, identifier:"V60-01").firstMatch.exists)
        XCTAssertTrue(app.staticTexts["Great brew today! Sweet and bright with citrus notes."].exists)
        XCTAssertTrue(app.staticTexts["★★★★☆"].exists)
    }
    
    func testSearchNotes() throws {
        // First create a brewing session
        try testBrewingSession()
        
        // Navigate to Notes tab
        app.tabBars.buttons["Notes"].tap()
        
        // Use search
        let searchField = app.searchFields["Search notes, coffee, or recipes..."]
        XCTAssertTrue(searchField.exists)
        searchField.tap()
        searchField.typeText("citrus")
        
        // Verify search results
        XCTAssertTrue(app.staticTexts["Ethiopian Yirgacheffe"].exists)
    }
    
    func testNotesFiltering() throws {
        // First create a brewing session
        try testBrewingSession()
        
        // Navigate to Notes tab
        app.tabBars.buttons["Notes"].tap()
        
        // Wait for Notes History view to appear
        XCTAssertTrue(app.navigationBars["Brewing History"].waitForExistence(timeout: 2))
        
        // Tap filter button (look for the toolbar filter button)
        let filterButton = app.navigationBars["Brewing History"].buttons.matching(identifier: "line.3.horizontal.decrease.circle").firstMatch
        if filterButton.exists {
            filterButton.tap()
            
            // Look for 4 star filter option in the sheet
            let fourStarFilter = app.buttons["4 Stars"]
            if fourStarFilter.exists {
                fourStarFilter.tap()
            }
            
            // Look for Done button to dismiss sheet
            let doneButton = app.buttons["Done"]
            if doneButton.exists {
                doneButton.tap()
            }
        }
        
        // Verify filtered results show the coffee we added
        XCTAssertTrue(app.staticTexts["Ethiopian Yirgacheffe"].exists)
    }
    
    // MARK: - Data Persistence Tests
    
    func testDataPersistence() throws {
        // Add coffee and recipe
        try testAddCoffee()
        try testAddV60Recipe()
        
        // Terminate and relaunch app
        app.terminate()
        app.launch()
        
        // Verify data persists
        app.tabBars.buttons["Coffees"].tap()
        XCTAssertTrue(app.staticTexts["Ethiopian Yirgacheffe"].exists)
        
        app.tabBars.buttons["Recipes"].tap()
        XCTAssertTrue(app.staticTexts.containing(.staticText, identifier:"V60-01").firstMatch.exists)
    }
    
    // MARK: - End-to-End Workflow Tests
    
    func testCompleteBrewingWorkflow() throws {
        // Complete workflow: Add coffee -> Add recipe -> Brew session -> View history
        
        // Step 1: Add coffee
        try testAddCoffee()
        
        // Step 2: Add recipe
        try testAddV60Recipe()
        
        // Step 3: Create brewing session
        app.tabBars.buttons["Brew"].tap()
        
        // Select coffee
        app.buttons["Select a coffee"].tap()
        app.buttons.containing(.staticText, identifier: "Ethiopian Yirgacheffe").firstMatch.tap()
        
        // Select recipe
        app.buttons["Select a recipe"].tap()
        app.buttons.containing(.staticText, identifier: "V60-01").firstMatch.tap()
        
        // Add notes and rating
        let notesEditor = app.textViews.firstMatch
        notesEditor.tap()
        notesEditor.typeText("Excellent brew with bright acidity and floral notes.")
        
        // Rate 5 stars
        app.buttons.matching(identifier: "star").allElementsBoundByIndex[4].tap() // 5th star
        
        // Save session
        app.buttons["Save Brewing Session"].tap()
        app.alerts["Session Saved"].buttons["OK"].tap()
        
        // Step 4: Verify in history
        app.tabBars.buttons["Notes"].tap()
        XCTAssertTrue(app.staticTexts["Ethiopian Yirgacheffe"].exists)
        XCTAssertTrue(app.staticTexts.containing(.staticText, identifier:"V60-01").firstMatch.exists)
        XCTAssertTrue(app.staticTexts.containing(.staticText, identifier: "★★★★★").firstMatch.exists)
    }
    
    func testRecipeUsageTracking() throws {
        // Add coffee and recipe
        try testAddCoffee()
        try testAddV60Recipe()
        
        // Create multiple brewing sessions with same recipe
        for i in 1...3 {
            app.tabBars.buttons["Brew"].tap()
            
            app.buttons["Select a coffee"].tap()
            app.buttons.containing(.staticText, identifier: "Ethiopian Yirgacheffe").firstMatch.tap()
            
            app.buttons["Select a recipe"].tap()
            app.buttons.containing(.staticText, identifier: "V60-01").firstMatch.tap()
            
            let notesEditor = app.textViews.firstMatch
            notesEditor.tap()
            notesEditor.typeText("Brew session \(i)")
            
            app.buttons["Save Brewing Session"].tap()
            app.alerts["Session Saved"].buttons["OK"].tap()
        }
        
        // Check usage count in recipes
        app.tabBars.buttons["Recipes"].tap()
        XCTAssertTrue(app.staticTexts["3 uses"].exists)
    }
    
    func testSearchAcrossAllTabs() throws {
        // Create complete data set
        try testCompleteBrewingWorkflow()
        
        // Test search in Coffees
        app.tabBars.buttons["Coffees"].tap()
        let coffeeSearch = app.searchFields["Search coffees..."]
        coffeeSearch.tap()
        coffeeSearch.typeText("Ethiopian")
        XCTAssertTrue(app.staticTexts["Ethiopian Yirgacheffe"].exists)
        
        // Test search in Recipes
        app.tabBars.buttons["Recipes"].tap()
        let recipeSearch = app.searchFields["Search recipes..."]
        recipeSearch.tap()
        recipeSearch.typeText("V60")
        XCTAssertTrue(app.staticTexts.containing(.staticText, identifier:"V60-01").firstMatch.exists)
        
        // Test search in Notes
        app.tabBars.buttons["Notes"].tap()
        let notesSearch = app.searchFields["Search notes, coffee, or recipes..."]
        notesSearch.tap()
        notesSearch.typeText("floral")
        XCTAssertTrue(app.staticTexts["Ethiopian Yirgacheffe"].exists)
    }
}

// MARK: - Helper Extensions

extension XCUIElement {
    func clearAndTypeText(_ text: String) {
        guard let stringValue = self.value as? String else {
            XCTFail("Tried to clear and enter text into a non-string value")
            return
        }
        
        self.tap()
        
        let deleteString = String(repeating: XCUIKeyboardKey.delete.rawValue, count: stringValue.count)
        self.typeText(deleteString)
        self.typeText(text)
    }
}
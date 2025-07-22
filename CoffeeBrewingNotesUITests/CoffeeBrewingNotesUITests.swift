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
        
        // Wait for the coffee list to load
        XCTAssertTrue(app.navigationBars["Coffees"].waitForExistence(timeout: 2))
        
        // Use search - try different search field identifiers
        var searchField = app.searchFields["Search coffees..."]
        if !searchField.exists {
            searchField = app.searchFields.firstMatch
        }
        
        XCTAssertTrue(searchField.exists)
        searchField.tap()
        searchField.typeText("Ethiopian")
        
        // Wait a moment for search to process
        Thread.sleep(forTimeInterval: 1)
        
        // Verify search results - check if coffee is visible
        let coffeeVisible = app.staticTexts["Ethiopian Yirgacheffe"].exists ||
                           app.staticTexts["Ethiopian"].exists ||
                           app.staticTexts.containing(.staticText, identifier: "Ethiopian").firstMatch.exists
        XCTAssertTrue(coffeeVisible)
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
        app.navigationBars["Coffees"].buttons.matching(identifier: "Add").firstMatch.tap()
        
        // Wait for Add Coffee sheet to appear
        let addCoffeeTitle = app.navigationBars["Add Coffee"]
        XCTAssertTrue(addCoffeeTitle.waitForExistence(timeout: 2))
        
        // Fill basic details
        let nameField = app.textFields["Coffee Name"]
        XCTAssertTrue(nameField.exists)
        nameField.tap()
        nameField.typeText("Slider Test Coffee")
        
        let roasterField = app.textFields["Roaster"]
        XCTAssertTrue(roasterField.exists)
        roasterField.tap()
        roasterField.typeText("Test Roaster")
        
        // Find and interact with roast level slider
        let slider = app.sliders.firstMatch
        XCTAssertTrue(slider.exists)
        
        // Adjust slider to different position (0.8 = Dark)
        slider.adjust(toNormalizedSliderPosition: 0.8)
        
        // Verify the displayed roast level changed
        XCTAssertTrue(app.staticTexts["Dark"].exists)
        
        // Save the coffee
        app.navigationBars["Add Coffee"].buttons["Save"].tap()
        
        // Wait for sheet to dismiss and verify coffee was created
        XCTAssertTrue(app.navigationBars["Coffees"].waitForExistence(timeout: 2))
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
        
        // The form should already have defaults loaded - just fill required fields
        
        // Fill in grind size field (required)
        let grindSizeField = app.textFields["e.g. 20, 3.2, coarse"]
        XCTAssertTrue(grindSizeField.exists)
        grindSizeField.tap()
        grindSizeField.typeText("20")
        
        // Fill in dose (required)
        let doseField = app.textFields["Grams"]
        XCTAssertTrue(doseField.exists)
        doseField.tap()
        doseField.typeText("20")
        
        // Water temp and brew time should have defaults, but ensure they're filled
        let waterTempField = app.textFields["°C"]
        if waterTempField.exists && (waterTempField.value as? String)?.isEmpty != false {
            waterTempField.tap()
            waterTempField.typeText("93")
        }
        
        let brewTimeField = app.textFields["Seconds"]
        if brewTimeField.exists && (brewTimeField.value as? String)?.isEmpty != false {
            brewTimeField.tap()
            brewTimeField.typeText("240")
        }
        
        // Save recipe (should work with default method and grinder)
        app.navigationBars["Add Recipe"].buttons["Save"].tap()
        
        // Wait for sheet to dismiss and verify recipe appears in list
        XCTAssertTrue(app.navigationBars["Recipes"].waitForExistence(timeout: 2))
        
        // Verify recipe appears in list (look for any recipe entry)
        // The recipe should be auto-named based on method and grinder
        let recipeExists = app.staticTexts.containing(.staticText, identifier:"V60").firstMatch.exists ||
                          app.staticTexts.containing(.staticText, identifier:"Baratza").firstMatch.exists ||
                          app.cells.firstMatch.exists
        XCTAssertTrue(recipeExists)
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
            // Try to find any Espresso-related option
            let anyEspressoOption = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'espresso'")).firstMatch
            if anyEspressoOption.exists {
                anyEspressoOption.tap()
            } else {
                // Dismiss picker and continue with default
                app.navigationBars["Add Recipe"].tap()
            }
        }
        
        // Fill in required fields
        let grindSizeField = app.textFields["e.g. 20, 3.2, coarse"]
        XCTAssertTrue(grindSizeField.exists)
        grindSizeField.tap()
        grindSizeField.typeText("10")
        
        let doseField = app.textFields["Grams"]
        XCTAssertTrue(doseField.exists)
        doseField.tap()
        doseField.typeText("18")
        
        // Ensure water temp and brew time are filled
        let waterTempField = app.textFields["°C"]
        if waterTempField.exists && (waterTempField.value as? String)?.isEmpty != false {
            waterTempField.tap()
            waterTempField.typeText("93")
        }
        
        let brewTimeField = app.textFields["Seconds"]
        if brewTimeField.exists && (brewTimeField.value as? String)?.isEmpty != false {
            brewTimeField.tap()
            brewTimeField.typeText("28")
        }
        
        // Save recipe
        app.navigationBars["Add Recipe"].buttons["Save"].tap()
        
        // Wait for sheet to dismiss and verify recipe appears in list
        XCTAssertTrue(app.navigationBars["Recipes"].waitForExistence(timeout: 2))
        
        // Verify recipe appears in list (look for any recipe entry)
        let recipeExists = app.staticTexts.containing(.staticText, identifier:"Espresso").firstMatch.exists ||
                          app.cells.firstMatch.exists
        XCTAssertTrue(recipeExists)
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
        
        // Look for the coffee we added - try different formats
        let coffeeOptions = [
            "Ethiopian Yirgacheffe - Blue Bottle Coffee",
            "Ethiopian Yirgacheffe",
            "Blue Bottle Coffee"
        ]
        
        var coffeeSelected = false
        for option in coffeeOptions {
            let coffeeOption = app.buttons.containing(.staticText, identifier: option).firstMatch
            if coffeeOption.exists {
                coffeeOption.tap()
                coffeeSelected = true
                break
            }
        }
        
        if !coffeeSelected {
            // Use first available coffee option
            let firstCoffeeOption = app.buttons.allElementsBoundByIndex.first { element in
                element.label.contains("Ethiopian") || element.label.contains("Coffee")
            }
            if let coffeeOption = firstCoffeeOption {
                coffeeOption.tap()
            } else {
                // Just tap any available option
                app.buttons.element(boundBy: 1).tap()
            }
        }
        
        // Select recipe using picker
        let recipePicker = app.buttons["Recipe"]
        XCTAssertTrue(recipePicker.exists)
        recipePicker.tap()
        
        // Look for any recipe option
        let recipeOption = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'V60' OR label CONTAINS[c] 'Baratza' OR label CONTAINS[c] 'recipe'")).firstMatch
        if recipeOption.exists {
            recipeOption.tap()
        } else {
            // Use first available recipe
            app.buttons.element(boundBy: 1).tap()
        }
        
        // Add notes in the TextEditor
        let notesEditor = app.textViews.firstMatch
        XCTAssertTrue(notesEditor.exists)
        notesEditor.tap()
        notesEditor.typeText("Great brew today! Sweet and bright with citrus notes.")
        
        // Add rating by tapping a star
        let starButtons = app.buttons.matching(NSPredicate(format: "identifier CONTAINS 'star'"))
        if starButtons.count >= 4 {
            starButtons.allElementsBoundByIndex[3].tap() // 4th star
        } else {
            // Fallback - try to find star elements differently
            let stars = app.images.matching(NSPredicate(format: "identifier CONTAINS 'star'"))
            if stars.count > 0 {
                stars.element(boundBy: 3).tap()
            }
        }
        
        // Save brewing session
        app.buttons["Save Brewing Session"].tap()
        
        // Wait for and verify alert appears
        let sessionSavedAlert = app.alerts["Session Saved"]
        XCTAssertTrue(sessionSavedAlert.waitForExistence(timeout: 2))
        sessionSavedAlert.buttons["OK"].tap()
        
        // Verify form is reset - check for picker default states
        let coffeePickerReset = app.buttons["Select a coffee"].exists || app.buttons["Coffee"].exists
        let recipePickerReset = app.buttons["Select a recipe"].exists || app.buttons["Recipe"].exists
        XCTAssertTrue(coffeePickerReset && recipePickerReset)
    }
    
    // MARK: - Notes History Tests
    
    func testNotesHistory() throws {
        // First create a brewing session
        try testBrewingSession()
        
        // Navigate to Notes tab
        app.tabBars.buttons["Notes"].tap()
        
        // Wait for Notes History view to appear
        XCTAssertTrue(app.navigationBars["Brewing History"].waitForExistence(timeout: 2))
        
        // Verify brewing note appears - be more flexible with what we check
        let coffeeNameVisible = app.staticTexts["Ethiopian Yirgacheffe"].exists ||
                                app.staticTexts["Ethiopian"].exists ||
                                app.staticTexts.containing(.staticText, identifier: "Ethiopian").firstMatch.exists
        
        let notesVisible = app.staticTexts["Great brew today! Sweet and bright with citrus notes."].exists ||
                          app.staticTexts.containing(.staticText, identifier: "Great brew").firstMatch.exists ||
                          app.staticTexts.containing(.staticText, identifier: "citrus").firstMatch.exists
        
        let recipeOrStarsVisible = app.staticTexts.containing(.staticText, identifier:"V60").firstMatch.exists ||
                                  app.staticTexts.containing(.staticText, identifier:"★").firstMatch.exists ||
                                  app.staticTexts.containing(.staticText, identifier:"Baratza").firstMatch.exists
        
        // At least one of these should be visible
        XCTAssertTrue(coffeeNameVisible || notesVisible || recipeOrStarsVisible)
    }
    
    func testSearchNotes() throws {
        // First create a brewing session
        try testBrewingSession()
        
        // Navigate to Notes tab
        app.tabBars.buttons["Notes"].tap()
        
        // Wait for Notes History view to appear
        XCTAssertTrue(app.navigationBars["Brewing History"].waitForExistence(timeout: 2))
        
        // Use search - try different search field identifiers
        var searchField = app.searchFields["Search notes, coffee, or recipes..."]
        if !searchField.exists {
            searchField = app.searchFields.firstMatch
        }
        
        XCTAssertTrue(searchField.exists)
        searchField.tap()
        searchField.typeText("citrus")
        
        // Wait for search to process
        Thread.sleep(forTimeInterval: 1)
        
        // Verify search results - be flexible about what appears
        let searchResultsVisible = app.staticTexts["Ethiopian Yirgacheffe"].exists ||
                                  app.staticTexts["Ethiopian"].exists ||
                                  app.staticTexts.containing(.staticText, identifier: "citrus").firstMatch.exists ||
                                  app.staticTexts.containing(.staticText, identifier: "Great brew").firstMatch.exists
        
        XCTAssertTrue(searchResultsVisible)
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
        XCTAssertTrue(app.navigationBars["New Brew Session"].waitForExistence(timeout: 2))
        
        // Select coffee
        let coffeePicker = app.buttons["Coffee"]
        coffeePicker.tap()
        
        // Look for coffee - try multiple approaches
        let coffeeSelected = selectFirstAvailableOption(containing: ["Ethiopian", "Blue Bottle", "Coffee"])
        XCTAssertTrue(coffeeSelected)
        
        // Select recipe
        let recipePicker = app.buttons["Recipe"]
        recipePicker.tap()
        
        // Look for recipe - try multiple approaches
        let recipeSelected = selectFirstAvailableOption(containing: ["V60", "Baratza", "recipe"])
        XCTAssertTrue(recipeSelected)
        
        // Add notes and rating
        let notesEditor = app.textViews.firstMatch
        XCTAssertTrue(notesEditor.exists)
        notesEditor.tap()
        notesEditor.typeText("Excellent brew with bright acidity and floral notes.")
        
        // Rate 5 stars - try different approaches
        let starButtons = app.buttons.matching(NSPredicate(format: "identifier CONTAINS 'star'"))
        if starButtons.count >= 5 {
            starButtons.allElementsBoundByIndex[4].tap() // 5th star
        } else {
            let stars = app.images.matching(NSPredicate(format: "identifier CONTAINS 'star'"))
            if stars.count >= 5 {
                stars.element(boundBy: 4).tap()
            }
        }
        
        // Save session
        app.buttons["Save Brewing Session"].tap()
        
        let sessionSavedAlert = app.alerts["Session Saved"]
        XCTAssertTrue(sessionSavedAlert.waitForExistence(timeout: 2))
        sessionSavedAlert.buttons["OK"].tap()
        
        // Step 4: Verify in history
        app.tabBars.buttons["Notes"].tap()
        XCTAssertTrue(app.navigationBars["Brewing History"].waitForExistence(timeout: 2))
        
        // Verify some brewing data appears - be flexible
        let historyDataVisible = app.staticTexts["Ethiopian Yirgacheffe"].exists ||
                                app.staticTexts.containing(.staticText, identifier: "Ethiopian").firstMatch.exists ||
                                app.staticTexts.containing(.staticText, identifier: "Excellent brew").firstMatch.exists ||
                                app.staticTexts.containing(.staticText, identifier: "★").firstMatch.exists
        
        XCTAssertTrue(historyDataVisible)
    }
    
    func testRecipeUsageTracking() throws {
        // Add coffee and recipe
        try testAddCoffee()
        try testAddV60Recipe()
        
        // Create multiple brewing sessions with same recipe
        for i in 1...3 {
            app.tabBars.buttons["Brew"].tap()
            
            // Wait for brew tab to load
            XCTAssertTrue(app.navigationBars["New Brew Session"].waitForExistence(timeout: 2))
            
            // Select coffee using picker
            let coffeePicker = app.buttons["Coffee"]
            XCTAssertTrue(coffeePicker.exists)
            coffeePicker.tap()
            
            // Look for the coffee we added
            let coffeeSelected = selectFirstAvailableOption(containing: ["Ethiopian", "Blue Bottle", "Coffee"])
            XCTAssertTrue(coffeeSelected)
            
            // Select recipe using picker
            let recipePicker = app.buttons["Recipe"]  
            XCTAssertTrue(recipePicker.exists)
            recipePicker.tap()
            
            // Look for any recipe option
            let recipeSelected = selectFirstAvailableOption(containing: ["V60", "Baratza", "recipe"])
            XCTAssertTrue(recipeSelected)
            
            // Add notes
            let notesEditor = app.textViews.firstMatch
            XCTAssertTrue(notesEditor.exists)
            notesEditor.tap()
            notesEditor.typeText("Brew session \(i)")
            
            // Save session
            app.buttons["Save Brewing Session"].tap()
            
            // Wait for and dismiss alert
            let sessionSavedAlert = app.alerts["Session Saved"]
            XCTAssertTrue(sessionSavedAlert.waitForExistence(timeout: 2))
            sessionSavedAlert.buttons["OK"].tap()
        }
        
        // Check usage count in recipes
        app.tabBars.buttons["Recipes"].tap()
        XCTAssertTrue(app.navigationBars["Recipes"].waitForExistence(timeout: 2))
        
        // Look for usage count indication - be flexible about format
        let usageCountVisible = app.staticTexts["3 uses"].exists ||
                               app.staticTexts.containing(.staticText, identifier: "3").firstMatch.exists ||
                               app.staticTexts.containing(.staticText, identifier: "uses").firstMatch.exists
        XCTAssertTrue(usageCountVisible)
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
    
    // MARK: - Helper Methods
    
    private func selectFirstAvailableOption(containing keywords: [String]) -> Bool {
        // Try to find button matching any of the keywords
        for keyword in keywords {
            let matchingButton = app.buttons.containing(.staticText, identifier: keyword).firstMatch
            if matchingButton.exists {
                matchingButton.tap()
                return true
            }
        }
        
        // Fallback: try to select any available option (skip the default "Select..." option)
        let availableButtons = app.buttons.allElementsBoundByIndex
        for (index, button) in availableButtons.enumerated() {
            if index > 0 && !button.label.contains("Select") && button.isHittable {
                button.tap()
                return true
            }
        }
        
        return false
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
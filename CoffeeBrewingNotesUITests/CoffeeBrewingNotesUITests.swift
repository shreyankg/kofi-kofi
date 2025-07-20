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
        app.navigationBars["Coffees"].buttons["Add"].tap()
        
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
        
        // Select processing method
        app.buttons["Washed"].tap() // Default should be Washed
        
        // Select roast level
        app.buttons["Light"].tap()
        
        // Save coffee
        app.navigationBars.buttons["Save"].tap()
        
        // Verify coffee appears in list
        XCTAssertTrue(app.staticTexts["Ethiopian Yirgacheffe"].exists)
        XCTAssertTrue(app.staticTexts["Blue Bottle Coffee"].exists)
    }
    
    func testSearchCoffees() throws {
        // First add a coffee to search for
        testAddCoffee()
        
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
    
    // MARK: - Recipe Management Tests
    
    func testAddV60Recipe() throws {
        // Navigate to Recipes tab
        app.tabBars.buttons["Recipes"].tap()
        
        // Tap add button
        app.navigationBars["Recipes"].buttons.matching(identifier: "Add").firstMatch.tap()
        
        // Fill in recipe details
        let nameField = app.textFields["Recipe Name"]
        XCTAssertTrue(nameField.exists)
        nameField.tap()
        nameField.typeText("My V60 Recipe")
        
        // Brewing method should default to V60-01
        XCTAssertTrue(app.buttons["V60-01"].exists)
        
        // Fill in basic parameters using more specific field identification
        let grindSizeField = app.textFields.matching(identifier: "Grind Size").firstMatch
        XCTAssertTrue(grindSizeField.exists)
        grindSizeField.tap()
        grindSizeField.clearAndTypeText("20")
        
        let waterTempField = app.textFields.matching(identifier: "°C").firstMatch
        XCTAssertTrue(waterTempField.exists)
        waterTempField.tap()
        waterTempField.clearAndTypeText("93")
        
        let doseField = app.textFields.matching(identifier: "Grams").firstMatch
        XCTAssertTrue(doseField.exists)
        doseField.tap()
        doseField.clearAndTypeText("20")
        
        let brewTimeField = app.textFields.matching(identifier: "Seconds").firstMatch
        XCTAssertTrue(brewTimeField.exists)
        brewTimeField.tap()
        brewTimeField.clearAndTypeText("240")
        
        // Fill in pour schedule (V60 specific) - should appear after selecting V60 method
        let bloomAmountField = app.textFields.matching(identifier: "Grams").element(boundBy: 1)
        if bloomAmountField.exists {
            bloomAmountField.tap()
            bloomAmountField.clearAndTypeText("40")
        }
        
        // Save recipe
        app.navigationBars.buttons["Save"].tap()
        
        // Verify recipe appears in list
        XCTAssertTrue(app.staticTexts["My V60 Recipe"].exists)
        XCTAssertTrue(app.staticTexts["V60-01"].exists)
    }
    
    func testAddEspressoRecipe() throws {
        // Navigate to Recipes tab
        app.tabBars.buttons["Recipes"].tap()
        
        // Tap add button
        app.navigationBars["Recipes"].buttons.matching(identifier: "Add").firstMatch.tap()
        
        // Fill in recipe name
        let nameField = app.textFields["Recipe Name"]
        nameField.tap()
        nameField.typeText("My Espresso Recipe")
        
        // Select Espresso brewing method from picker
        app.buttons["Brewing Method"].tap()
        app.buttons["Espresso"].tap()
        
        // Fill in basic parameters
        let grindSizeField = app.textFields.matching(identifier: "Grind Size").firstMatch
        grindSizeField.tap()
        grindSizeField.clearAndTypeText("10")
        
        let waterTempField = app.textFields.matching(identifier: "°C").firstMatch
        waterTempField.tap()
        waterTempField.clearAndTypeText("93")
        
        let doseField = app.textFields.matching(identifier: "Grams").firstMatch
        doseField.tap()
        doseField.clearAndTypeText("18")
        
        let brewTimeField = app.textFields.matching(identifier: "Seconds").firstMatch
        brewTimeField.tap()
        brewTimeField.clearAndTypeText("28")
        
        // Fill in espresso-specific parameter (water out)
        let waterOutField = app.textFields.matching(identifier: "Grams").element(boundBy: 1)
        if waterOutField.exists {
            waterOutField.tap()
            waterOutField.clearAndTypeText("36")
        }
        
        // Save recipe
        app.navigationBars.buttons["Save"].tap()
        
        // Verify recipe appears in list
        XCTAssertTrue(app.staticTexts["My Espresso Recipe"].exists)
        XCTAssertTrue(app.staticTexts["Espresso"].exists)
    }
    
    // MARK: - Brewing Session Tests
    
    func testBrewingSession() throws {
        // First add a coffee and recipe
        testAddCoffee()
        testAddV60Recipe()
        
        // Navigate to Brew tab
        app.tabBars.buttons["Brew"].tap()
        
        // Select coffee
        app.buttons["Select a coffee"].tap()
        app.buttons["Ethiopian Yirgacheffe - Blue Bottle Coffee"].tap()
        
        // Select recipe
        app.buttons["Select a recipe"].tap()
        app.buttons["My V60 Recipe"].tap()
        
        // Add notes
        let notesEditor = app.textViews.firstMatch
        XCTAssertTrue(notesEditor.exists)
        notesEditor.tap()
        notesEditor.typeText("Great brew today! Sweet and bright with citrus notes.")
        
        // Add rating
        app.buttons["star"].element(boundBy: 3).tap() // 4 stars
        
        // Save brewing session
        app.buttons["Save Brewing Session"].tap()
        
        // Verify alert appears
        XCTAssertTrue(app.alerts["Session Saved"].exists)
        app.alerts["Session Saved"].buttons["OK"].tap()
        
        // Verify form is reset
        XCTAssertTrue(app.buttons["Select a coffee"].exists)
        XCTAssertTrue(app.buttons["Select a recipe"].exists)
    }
    
    // MARK: - Notes History Tests
    
    func testNotesHistory() throws {
        // First create a brewing session
        testBrewingSession()
        
        // Navigate to Notes tab
        app.tabBars.buttons["Notes"].tap()
        
        // Verify brewing note appears
        XCTAssertTrue(app.staticTexts["Ethiopian Yirgacheffe"].exists)
        XCTAssertTrue(app.staticTexts["My V60 Recipe"].exists)
        XCTAssertTrue(app.staticTexts["Great brew today! Sweet and bright with citrus notes."].exists)
        XCTAssertTrue(app.staticTexts["★★★★☆"].exists)
    }
    
    func testSearchNotes() throws {
        // First create a brewing session
        testBrewingSession()
        
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
        testBrewingSession()
        
        // Navigate to Notes tab
        app.tabBars.buttons["Notes"].tap()
        
        // Tap filter button
        app.navigationBars.buttons.matching(identifier: "line.3.horizontal.decrease.circle").firstMatch.tap()
        
        // Select 4 star filter
        app.buttons["4 Stars"].tap()
        app.buttons["Done"].tap()
        
        // Verify filtered results
        XCTAssertTrue(app.staticTexts["Ethiopian Yirgacheffe"].exists)
    }
    
    // MARK: - Data Persistence Tests
    
    func testDataPersistence() throws {
        // Add coffee and recipe
        testAddCoffee()
        testAddV60Recipe()
        
        // Terminate and relaunch app
        app.terminate()
        app.launch()
        
        // Verify data persists
        app.tabBars.buttons["Coffees"].tap()
        XCTAssertTrue(app.staticTexts["Ethiopian Yirgacheffe"].exists)
        
        app.tabBars.buttons["Recipes"].tap()
        XCTAssertTrue(app.staticTexts["My V60 Recipe"].exists)
    }
    
    // MARK: - End-to-End Workflow Tests
    
    func testCompleteBrewingWorkflow() throws {
        // Complete workflow: Add coffee -> Add recipe -> Brew session -> View history
        
        // Step 1: Add coffee
        testAddCoffee()
        
        // Step 2: Add recipe
        testAddV60Recipe()
        
        // Step 3: Create brewing session
        app.tabBars.buttons["Brew"].tap()
        
        // Select coffee
        app.buttons["Select a coffee"].tap()
        app.buttons.containing(.staticText, identifier: "Ethiopian Yirgacheffe").firstMatch.tap()
        
        // Select recipe
        app.buttons["Select a recipe"].tap()
        app.buttons.containing(.staticText, identifier: "My V60 Recipe").firstMatch.tap()
        
        // Add notes and rating
        let notesEditor = app.textViews.firstMatch
        notesEditor.tap()
        notesEditor.typeText("Excellent brew with bright acidity and floral notes.")
        
        // Rate 5 stars
        app.buttons["star"].element(boundBy: 4).tap() // 5th star
        
        // Save session
        app.buttons["Save Brewing Session"].tap()
        app.alerts["Session Saved"].buttons["OK"].tap()
        
        // Step 4: Verify in history
        app.tabBars.buttons["Notes"].tap()
        XCTAssertTrue(app.staticTexts["Ethiopian Yirgacheffe"].exists)
        XCTAssertTrue(app.staticTexts["My V60 Recipe"].exists)
        XCTAssertTrue(app.staticTexts.containing(.staticText, identifier: "★★★★★").firstMatch.exists)
    }
    
    func testRecipeUsageTracking() throws {
        // Add coffee and recipe
        testAddCoffee()
        testAddV60Recipe()
        
        // Create multiple brewing sessions with same recipe
        for i in 1...3 {
            app.tabBars.buttons["Brew"].tap()
            
            app.buttons["Select a coffee"].tap()
            app.buttons.containing(.staticText, identifier: "Ethiopian Yirgacheffe").firstMatch.tap()
            
            app.buttons["Select a recipe"].tap()
            app.buttons.containing(.staticText, identifier: "My V60 Recipe").firstMatch.tap()
            
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
        testCompleteBrewingWorkflow()
        
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
        XCTAssertTrue(app.staticTexts["My V60 Recipe"].exists)
        
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
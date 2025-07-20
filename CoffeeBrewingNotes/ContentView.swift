import SwiftUI
import CoreData

struct ContentView: View {
    var body: some View {
        TabView {
            CoffeeListView()
                .tabItem {
                    Image(systemName: "cup.and.saucer")
                    Text("Coffees")
                }
            
            RecipeListView()
                .tabItem {
                    Image(systemName: "list.bullet.rectangle")
                    Text("Recipes")
                }
            
            BrewingSessionView()
                .tabItem {
                    Image(systemName: "plus.circle")
                    Text("Brew")
                }
            
            NotesHistoryView()
                .tabItem {
                    Image(systemName: "book")
                    Text("Notes")
                }
        }
    }
}

#Preview {
    ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
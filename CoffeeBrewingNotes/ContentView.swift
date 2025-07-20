import SwiftUI
import CoreData

struct ContentView: View {
    var body: some View {
        TabView {
            SimpleCoffeeListView()
                .tabItem {
                    Image(systemName: "cup.and.saucer")
                    Text("Coffees")
                }
            
            Text("Recipes - Coming Soon")
                .tabItem {
                    Image(systemName: "list.bullet.rectangle")
                    Text("Recipes")
                }
            
            Text("Brew - Coming Soon")
                .tabItem {
                    Image(systemName: "plus.circle")
                    Text("Brew")
                }
            
            Text("Notes - Coming Soon")
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
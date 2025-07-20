import SwiftUI
import CoreData

struct CoffeeListView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Coffee.dateAdded, ascending: false)],
        animation: .default)
    private var coffees: FetchedResults<Coffee>
    
    @State private var showingAddCoffee = false
    @State private var searchText = ""
    
    var filteredCoffees: [Coffee] {
        if searchText.isEmpty {
            return Array(coffees)
        } else {
            return coffees.filter { coffee in
                coffee.wrappedName.localizedCaseInsensitiveContains(searchText) ||
                coffee.wrappedRoaster.localizedCaseInsensitiveContains(searchText) ||
                coffee.wrappedOrigin.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var body: some View {
        NavigationView {
            List {
                ForEach(filteredCoffees, id: \.self) { coffee in
                    CoffeeRowView(coffee: coffee)
                }
                .onDelete(perform: deleteCoffees)
            }
            .navigationTitle("Coffees")
            .searchable(text: $searchText, prompt: "Search coffees...")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddCoffee = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddCoffee) {
                AddCoffeeView()
            }
        }
    }
    
    private func deleteCoffees(offsets: IndexSet) {
        withAnimation {
            offsets.map { filteredCoffees[$0] }.forEach(viewContext.delete)
            
            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

struct CoffeeRowView: View {
    let coffee: Coffee
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(coffee.wrappedName)
                    .font(.headline)
                Spacer()
                Text(coffee.wrappedRoastLevel)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(Color.secondary.opacity(0.2))
                    .cornerRadius(4)
            }
            
            Text(coffee.wrappedRoaster)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            HStack {
                Text(coffee.wrappedOrigin)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text(coffee.wrappedProcessing)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 2)
    }
}

#Preview {
    CoffeeListView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
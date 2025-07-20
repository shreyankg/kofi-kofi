import SwiftUI
import CoreData

struct RecipeListView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Recipe.usageCount, ascending: false)],
        animation: .default)
    private var recipes: FetchedResults<Recipe>
    
    @State private var showingAddRecipe = false
    @State private var searchText = ""
    
    var filteredRecipes: [Recipe] {
        if searchText.isEmpty {
            return Array(recipes)
        } else {
            return recipes.filter { recipe in
                recipe.wrappedName.localizedCaseInsensitiveContains(searchText) ||
                recipe.wrappedBrewingMethod.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var body: some View {
        NavigationView {
            List {
                ForEach(filteredRecipes, id: \.self) { recipe in
                    RecipeRowView(recipe: recipe)
                }
                .onDelete(perform: deleteRecipes)
            }
            .navigationTitle("Recipes")
            .searchable(text: $searchText, prompt: "Search recipes...")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddRecipe = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddRecipe) {
                AddRecipeView()
            }
        }
    }
    
    private func deleteRecipes(offsets: IndexSet) {
        withAnimation {
            offsets.map { filteredRecipes[$0] }.forEach(viewContext.delete)
            
            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

struct RecipeRowView: View {
    let recipe: Recipe
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(recipe.wrappedName)
                    .font(.headline)
                Spacer()
                Text("\(recipe.usageCount) uses")
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(Color.blue.opacity(0.2))
                    .cornerRadius(4)
            }
            
            Text(recipe.wrappedBrewingMethod)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            HStack {
                Text("\(recipe.grindSize) grind")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text("•")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text("\(recipe.waterTemp)°C")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text("•")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text("\(recipe.dose, specifier: "%.1f")g")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text("\(recipe.brewTime)s")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 2)
    }
}

#Preview {
    RecipeListView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
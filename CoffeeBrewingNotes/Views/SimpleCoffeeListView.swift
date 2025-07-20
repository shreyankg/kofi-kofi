import SwiftUI
import CoreData

struct SimpleCoffeeListView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Coffee.dateAdded, ascending: false)],
        animation: .default)
    private var coffees: FetchedResults<Coffee>
    
    @State private var showingAddCoffee = false
    
    var body: some View {
        NavigationView {
            List {
                ForEach(coffees, id: \.self) { coffee in
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text(coffee.name ?? "Unknown Coffee")
                                .font(.headline)
                            Spacer()
                            Text(coffee.roastLevel ?? "Medium")
                                .font(.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 2)
                                .background(Color.secondary.opacity(0.2))
                                .cornerRadius(4)
                        }
                        
                        Text(coffee.roaster ?? "Unknown Roaster")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        HStack {
                            Text(coffee.origin ?? "Unknown Origin")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Spacer()
                            
                            Text(coffee.processing ?? "Unknown")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical, 2)
                }
                .onDelete(perform: deleteCoffees)
            }
            .navigationTitle("Coffees")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddCoffee = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddCoffee) {
                SimpleAddCoffeeView()
            }
        }
    }
    
    private func deleteCoffees(offsets: IndexSet) {
        withAnimation {
            offsets.map { coffees[$0] }.forEach(viewContext.delete)
            
            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

struct SimpleAddCoffeeView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var name = ""
    @State private var roaster = ""
    @State private var processing = "Washed"
    @State private var roastLevel = "Medium"
    @State private var origin = ""
    
    private let processingOptions = ["Washed", "Honey", "Natural", "Semi-Washed", "Pulped Natural"]
    private let roastLevelOptions = ["Light", "Medium Light", "Medium", "Medium Dark", "Dark", "Extra Dark"]
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Coffee Details")) {
                    TextField("Coffee Name", text: $name)
                    TextField("Roaster", text: $roaster)
                    TextField("Origin", text: $origin)
                }
                
                Section(header: Text("Processing")) {
                    Picker("Processing Method", selection: $processing) {
                        ForEach(processingOptions, id: \.self) { option in
                            Text(option).tag(option)
                        }
                    }
                }
                
                Section(header: Text("Roast Level")) {
                    Picker("Roast Level", selection: $roastLevel) {
                        ForEach(roastLevelOptions, id: \.self) { option in
                            Text(option).tag(option)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
            }
            .navigationTitle("Add Coffee")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveCoffee()
                    }
                    .disabled(name.isEmpty || roaster.isEmpty)
                }
            }
        }
    }
    
    private func saveCoffee() {
        let coffee = Coffee(context: viewContext)
        coffee.id = UUID()
        coffee.name = name
        coffee.roaster = roaster
        coffee.processing = processing
        coffee.roastLevel = roastLevel
        coffee.origin = origin
        coffee.dateAdded = Date()
        
        do {
            try viewContext.save()
            dismiss()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
}

#Preview {
    SimpleCoffeeListView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
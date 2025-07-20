import SwiftUI

struct AddCoffeeView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var name = ""
    @State private var roaster = ""
    @State private var processing = "Washed"
    @State private var roastLevel = "Medium"
    @State private var origin = ""
    
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
                        ForEach(Coffee.processingOptions, id: \.self) { option in
                            Text(option).tag(option)
                        }
                    }
                }
                
                Section(header: Text("Roast Level")) {
                    Picker("Roast Level", selection: $roastLevel) {
                        ForEach(Coffee.roastLevelOptions, id: \.self) { option in
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
    AddCoffeeView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
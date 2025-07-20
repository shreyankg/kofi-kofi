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
                    NavigationLink(destination: EditCoffeeView(coffee: coffee)) {
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
    @State private var selectedProcessingMethod: ProcessingMethod?
    @State private var customProcessingName = ""
    @State private var showingCustomProcessing = false
    @State private var roastLevelIndex = 2.0
    @State private var origin = ""
    
    private let roastLevelOptions = ["Light", "Medium Light", "Medium", "Medium Dark", "Dark", "Extra Dark"]
    
    @FetchRequest(
        sortDescriptors: [
            NSSortDescriptor(keyPath: \ProcessingMethod.usageCount, ascending: false),
            NSSortDescriptor(keyPath: \ProcessingMethod.name, ascending: true)
        ],
        animation: .default
    ) private var processingMethods: FetchedResults<ProcessingMethod>
    
    private var processingMethodPicker: some View {
        Group {
            if processingMethods.isEmpty {
                Text("Loading processing methods...")
                    .foregroundColor(.secondary)
            } else {
                Picker("Processing Method", selection: $selectedProcessingMethod) {
                    ForEach(processingMethods, id: \.self) { method in
                        Text("\(method.name ?? "Unknown") \(method.usageCount > 0 ? "(\(method.usageCount))" : "")")
                            .tag(method as ProcessingMethod?)
                    }
                }
                .pickerStyle(MenuPickerStyle())
            }
        }
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Coffee Details")) {
                    TextField("Coffee Name", text: $name)
                    TextField("Roaster", text: $roaster)
                    TextField("Origin", text: $origin)
                }
                
                Section(header: Text("Processing Method")) {
                    processingMethodPicker
                    
                    Button("Add Custom Method") {
                        showingCustomProcessing = true
                    }
                    .foregroundColor(.blue)
                }
                
                Section(header: Text("Roast Level")) {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Light")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Spacer()
                            Text(roastLevelOptions[Int(roastLevelIndex)])
                                .font(.headline)
                            Spacer()
                            Text("Extra Dark")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Slider(value: $roastLevelIndex, in: 0...5, step: 1)
                            .accentColor(.brown)
                    }
                    .padding(.vertical, 4)
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
                    .disabled(name.isEmpty || roaster.isEmpty || selectedProcessingMethod == nil)
                }
            }
            .sheet(isPresented: $showingCustomProcessing) {
                CustomProcessingMethodView(onSave: { methodName in
                    if !methodName.isEmpty {
                        let newMethod = createProcessingMethod(name: methodName)
                        selectedProcessingMethod = newMethod
                    }
                    showingCustomProcessing = false
                })
            }
            .onAppear {
                seedProcessingMethodsIfNeeded()
                if selectedProcessingMethod == nil && !processingMethods.isEmpty {
                    selectedProcessingMethod = processingMethods.first { $0.name == "Washed" } ?? processingMethods.first
                }
            }
        }
    }
    
    private func seedProcessingMethodsIfNeeded() {
        if processingMethods.isEmpty {
            let defaultMethods = ["Washed", "Honey", "Natural"]
            for method in defaultMethods {
                let _ = createProcessingMethod(name: method)
            }
        }
    }
    
    private func createProcessingMethod(name: String) -> ProcessingMethod {
        let request: NSFetchRequest<ProcessingMethod> = ProcessingMethod.fetchRequest()
        request.predicate = NSPredicate(format: "name == %@", name)
        
        if let existing = try? viewContext.fetch(request).first {
            return existing
        }
        
        let new = ProcessingMethod(context: viewContext)
        new.id = UUID()
        new.name = name
        new.usageCount = 0
        new.dateCreated = Date()
        
        try? viewContext.save()
        return new
    }
    
    private func saveCoffee() {
        guard let processingMethod = selectedProcessingMethod else { return }
        
        let coffee = Coffee(context: viewContext)
        coffee.id = UUID()
        coffee.name = name
        coffee.roaster = roaster
        coffee.processing = processingMethod.name
        coffee.roastLevel = roastLevelOptions[Int(roastLevelIndex)]
        coffee.origin = origin
        coffee.dateAdded = Date()
        
        processingMethod.usageCount += 1
        
        do {
            try viewContext.save()
            dismiss()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
}

struct CustomProcessingMethodView: View {
    @State private var methodName = ""
    let onSave: (String) -> Void
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Custom Processing Method")) {
                    TextField("Method Name", text: $methodName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                
                Section(footer: Text("Add a custom processing method that will be saved for future use.")) {
                    EmptyView()
                }
            }
            .navigationTitle("Add Method")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        onSave("")
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        onSave(methodName)
                    }
                    .disabled(methodName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
}

struct EditCoffeeView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    
    let coffee: Coffee
    
    @State private var name = ""
    @State private var roaster = ""
    @State private var selectedProcessingMethod: ProcessingMethod?
    @State private var customProcessingName = ""
    @State private var showingCustomProcessing = false
    @State private var roastLevelIndex = 2.0
    @State private var origin = ""
    
    private let roastLevelOptions = ["Light", "Medium Light", "Medium", "Medium Dark", "Dark", "Extra Dark"]
    
    @FetchRequest(
        sortDescriptors: [
            NSSortDescriptor(keyPath: \ProcessingMethod.usageCount, ascending: false),
            NSSortDescriptor(keyPath: \ProcessingMethod.name, ascending: true)
        ],
        animation: .default
    ) private var processingMethods: FetchedResults<ProcessingMethod>
    
    private var processingMethodPicker: some View {
        Group {
            if processingMethods.isEmpty {
                Text("Loading processing methods...")
                    .foregroundColor(.secondary)
            } else {
                Picker("Processing Method", selection: $selectedProcessingMethod) {
                    ForEach(processingMethods, id: \.self) { method in
                        Text("\(method.name ?? "Unknown") \(method.usageCount > 0 ? "(\(method.usageCount))" : "")")
                            .tag(method as ProcessingMethod?)
                    }
                }
                .pickerStyle(MenuPickerStyle())
            }
        }
    }
    
    var body: some View {
        Form {
            Section(header: Text("Coffee Details")) {
                TextField("Coffee Name", text: $name)
                TextField("Roaster", text: $roaster)
                TextField("Origin", text: $origin)
            }
            
            Section(header: Text("Processing Method")) {
                processingMethodPicker
                
                Button("Add Custom Method") {
                    showingCustomProcessing = true
                }
                .foregroundColor(.blue)
            }
            
            Section(header: Text("Roast Level")) {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Light")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Spacer()
                        Text(roastLevelOptions[Int(roastLevelIndex)])
                            .font(.headline)
                        Spacer()
                        Text("Extra Dark")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Slider(value: $roastLevelIndex, in: 0...5, step: 1)
                        .accentColor(.brown)
                }
                .padding(.vertical, 4)
            }
        }
        .navigationTitle("Edit Coffee")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Save") {
                    saveCoffee()
                }
                .disabled(name.isEmpty || roaster.isEmpty || selectedProcessingMethod == nil)
            }
        }
        .sheet(isPresented: $showingCustomProcessing) {
            CustomProcessingMethodView(onSave: { methodName in
                if !methodName.isEmpty {
                    let newMethod = createProcessingMethod(name: methodName)
                    selectedProcessingMethod = newMethod
                }
                showingCustomProcessing = false
            })
        }
        .onAppear {
            loadCoffeeData()
            seedProcessingMethodsIfNeeded()
        }
    }
    
    private func loadCoffeeData() {
        name = coffee.name ?? ""
        roaster = coffee.roaster ?? ""
        origin = coffee.origin ?? ""
        
        // Set roast level index
        if let currentRoastLevel = coffee.roastLevel,
           let index = roastLevelOptions.firstIndex(of: currentRoastLevel) {
            roastLevelIndex = Double(index)
        }
        
        // Set selected processing method
        if let currentProcessing = coffee.processing {
            selectedProcessingMethod = processingMethods.first { $0.name == currentProcessing }
        }
    }
    
    private func seedProcessingMethodsIfNeeded() {
        if processingMethods.isEmpty {
            let defaultMethods = ["Washed", "Honey", "Natural"]
            for method in defaultMethods {
                let _ = createProcessingMethod(name: method)
            }
        }
    }
    
    private func createProcessingMethod(name: String) -> ProcessingMethod {
        let request: NSFetchRequest<ProcessingMethod> = ProcessingMethod.fetchRequest()
        request.predicate = NSPredicate(format: "name == %@", name)
        
        if let existing = try? viewContext.fetch(request).first {
            return existing
        }
        
        let new = ProcessingMethod(context: viewContext)
        new.id = UUID()
        new.name = name
        new.usageCount = 0
        new.dateCreated = Date()
        
        try? viewContext.save()
        return new
    }
    
    private func saveCoffee() {
        guard let processingMethod = selectedProcessingMethod else { return }
        
        let originalProcessing = coffee.processing
        
        coffee.name = name
        coffee.roaster = roaster
        coffee.processing = processingMethod.name
        coffee.roastLevel = roastLevelOptions[Int(roastLevelIndex)]
        coffee.origin = origin
        
        // Only increment usage count if processing method changed
        if originalProcessing != processingMethod.name {
            processingMethod.usageCount += 1
        }
        
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

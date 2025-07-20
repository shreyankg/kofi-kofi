import Foundation
import CoreData

extension ProcessingMethod {
    
    // MARK: - Safe Property Accessors
    
    var wrappedName: String {
        name ?? "Unknown"
    }
    
    var wrappedUsageCount: Int32 {
        usageCount
    }
    
    var wrappedDateCreated: Date {
        dateCreated ?? Date()
    }
    
    // MARK: - Usage Management
    
    func incrementUsageCount() {
        usageCount += 1
    }
    
    // MARK: - Static Methods
    
    static func fetchOrCreate(name: String, context: NSManagedObjectContext) -> ProcessingMethod {
        let request: NSFetchRequest<ProcessingMethod> = ProcessingMethod.fetchRequest()
        request.predicate = NSPredicate(format: "name == %@", name)
        
        if let existing = try? context.fetch(request).first {
            return existing
        }
        
        let new = ProcessingMethod(context: context)
        new.id = UUID()
        new.name = name
        new.usageCount = 0
        new.dateCreated = Date()
        return new
    }
    
    static func getAllSorted(context: NSManagedObjectContext) -> [ProcessingMethod] {
        let request: NSFetchRequest<ProcessingMethod> = ProcessingMethod.fetchRequest()
        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \ProcessingMethod.usageCount, ascending: false),
            NSSortDescriptor(keyPath: \ProcessingMethod.name, ascending: true)
        ]
        
        return (try? context.fetch(request)) ?? []
    }
    
    // MARK: - Default Processing Methods
    
    static let defaultMethods = [
        "Washed",
        "Honey", 
        "Natural",
        "Semi-Washed",
        "Pulped Natural",
        "Anaerobic",
        "Carbonic Maceration"
    ]
    
    static func seedDefaultMethods(context: NSManagedObjectContext) {
        for method in defaultMethods {
            _ = fetchOrCreate(name: method, context: context)
        }
        
        try? context.save()
    }
}
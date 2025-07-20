import SwiftUI
import CoreData

struct NotesHistoryView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \BrewingNote.dateCreated, ascending: false)],
        animation: .default)
    private var brewingNotes: FetchedResults<BrewingNote>
    
    @State private var searchText = ""
    
    var filteredNotes: [BrewingNote] {
        if searchText.isEmpty {
            return Array(brewingNotes)
        } else {
            return brewingNotes.filter { note in
                note.wrappedCoffeeName.localizedCaseInsensitiveContains(searchText) ||
                note.wrappedRecipeName.localizedCaseInsensitiveContains(searchText) ||
                note.wrappedNotes.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var body: some View {
        NavigationView {
            List {
                ForEach(filteredNotes, id: \.self) { note in
                    BrewingNoteRowView(note: note)
                }
                .onDelete(perform: deleteNotes)
            }
            .navigationTitle("Brewing Notes")
            .searchable(text: $searchText, prompt: "Search notes...")
        }
    }
    
    private func deleteNotes(offsets: IndexSet) {
        withAnimation {
            offsets.map { filteredNotes[$0] }.forEach(viewContext.delete)
            
            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

struct BrewingNoteRowView: View {
    let note: BrewingNote
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(note.wrappedCoffeeName)
                        .font(.headline)
                    Text(note.wrappedRecipeName)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 2) {
                    if note.hasRating {
                        Text(note.ratingStars)
                            .font(.caption)
                    }
                    Text(note.formattedDate)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            if !note.wrappedNotes.isEmpty {
                Text(note.wrappedNotes)
                    .font(.body)
                    .lineLimit(3)
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    NotesHistoryView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
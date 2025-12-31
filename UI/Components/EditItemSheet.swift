import SwiftUI

struct EditItemSheet: View {
    let item: Item
    let onSave: (String, Int, String?) -> Void
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var name: String
    @State private var quantity: Int
    @State private var note: String
    
    init(item: Item, onSave: @escaping (String, Int, String?) -> Void) {
        self.item = item
        self.onSave = onSave
        _name = State(initialValue: item.name)
        _quantity = State(initialValue: item.quantity)
        _note = State(initialValue: item.note ?? "")
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Details") {
                    TextField("Name", text: $name)
                    
                    Stepper(value: $quantity, in: 1...999) {
                        HStack {
                            Text("Quantity")
                            Spacer()
                            Text("\(quantity)")
                                .foregroundStyle(.secondary)
                        }
                    }
                    
                    TextField("Note (optional)", text: $note, axis: .vertical)
                        .lineLimit(3...6)
                }
            }
            .navigationTitle("Edit Item")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
                        guard !trimmedName.isEmpty else { return }
                        let trimmedNote = note.trimmingCharacters(in: .whitespacesAndNewlines)
                        onSave(trimmedName, quantity, trimmedNote.isEmpty ? nil : trimmedNote)
                        dismiss()
                    }
                    .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
}


import SwiftUI

struct EditLocationSheet: View {
    @Environment(\.dismiss) private var dismiss
    
    var location: Location
    var onSave: (Location, String, LocationType) -> Void

    // State
    @State private var name: String
    @State private var type: LocationType

    // Custom Init (CRITICAL FIX)
    init(location: Location, onSave: @escaping (Location, String, LocationType) -> Void) {
        self.location = location
        self.onSave = onSave
        // Initialize State directly from the passed location
        _name = State(initialValue: location.name)
        _type = State(initialValue: location.type)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Details") {
                    TextField("Name", text: $name)

                    Picker("Type", selection: $type) {
                        ForEach(LocationType.allCases, id: \.self) { t in
                            Text(t.rawValue).tag(t)
                        }
                    }
                }
            }
            .navigationTitle("Edit Location")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
                        guard !trimmed.isEmpty else { return }
                        onSave(location, trimmed, type)
                        dismiss()
                    }
                    .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
}


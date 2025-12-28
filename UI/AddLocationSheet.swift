import SwiftUI

struct AddLocationSheet: View {
    let vm: LocationsViewModel
    let parent: Location?              // nil means "add a root"

    @Environment(\.dismiss) private var dismiss

    @State private var name: String = ""
    @State private var type: LocationType = .room

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

                if let parent {
                    Section("Parent") {
                        Text(parent.name)
                    }
                }
            }
            .navigationTitle("Add Location")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
                        guard !trimmed.isEmpty else { return }
                        vm.addLocation(
                            name: trimmed,
                            type: type,
                            parentId: parent?.id
                        )
                        dismiss()
                    }
                    .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
}

#Preview {
    AddLocationSheet(vm: LocationsViewModel(), parent: Location(name: "Kitchen", type: .room))
}

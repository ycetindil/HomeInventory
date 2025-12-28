import SwiftUI

struct LocationDetailView: View {
    let location: Location

    var body: some View {
        Form {
            Section("Basics") {
                LabeledContent("Name", value: location.name)
                LabeledContent("Type", value: location.type.rawValue)
            }

            if let notes = location.notes, !notes.isEmpty {
                Section("Notes") {
                    Text(notes)
                }
            }

            Section("Metadata") {
                LabeledContent("ID", value: location.id.uuidString)
            }
        }
        .navigationTitle(location.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        LocationDetailView(location: Location.previewLocations.first!)
    }
}

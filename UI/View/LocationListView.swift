import SwiftUI

struct LocationListView: View {
    let locations: [Location]

    var body: some View {
        List(locations) { loc in
            NavigationLink {
                LocationDetailView(location: loc)
            } label: {
                VStack(alignment: .leading, spacing: 4) {
                    Text(loc.name)
                        .font(.headline)
                    Text(loc.type.rawValue)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        LocationListView(locations: Location.previewLocations)
            .navigationTitle("Locations")
    }
}

import SwiftUI

struct LocationListView: View {
    let locations: [Location]
    var vm: LocationsViewModel  // <--- 1. Add the ViewModel here

    var body: some View {
        List(locations) { loc in
            NavigationLink {
                // 2. Pass it down to the Detail View
                LocationDetailView(location: loc, vm: vm)
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
        // 3. Update Preview to provide a temporary VM
        LocationListView(
            locations: Location.previewLocations,
            vm: LocationsViewModel()
        )
        .navigationTitle("Locations")
    }
}

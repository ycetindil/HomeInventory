import SwiftUI

struct LocationSettingsDestination: Hashable {
    let locationId: UUID
    
    init(location: Location) {
        self.locationId = location.id
    }
}

struct ItemEditDestination: Hashable, Identifiable {
    let itemId: UUID
    
    var id: UUID { itemId }
    
    init(item: Item) {
        self.itemId = item.id
    }
}

struct LocationEditDestination: Hashable, Identifiable {
    let locationId: UUID
    
    var id: UUID { locationId }
    
    init(location: Location) {
        self.locationId = location.id
    }
}

struct ContentView: View {
    @Environment(LocationsViewModel.self) private var vm

    var body: some View {
        NavigationStack {
            LocationView(vm: vm, parent: nil)
                .navigationTitle("Locations")
                .navigationDestination(for: Location.self) { location in
                    LocationView(vm: vm, parent: location)
                        .navigationTitle(location.name)
                }
                .navigationDestination(for: Item.self) { item in
                    ItemDetailView(vm: vm, item: item)
                }
                .navigationDestination(for: LocationSettingsDestination.self) { destination in
                    if let location = vm.location(id: destination.locationId) {
                        LocationSettingsView(vm: vm, location: location)
                    }
                }
                .navigationDestination(for: ItemEditDestination.self) { destination in
                    if let item = vm.item(id: destination.itemId) {
                        ItemDetailView(vm: vm, item: item, initialEditMode: true)
                    }
                }
                .navigationDestination(for: LocationEditDestination.self) { destination in
                    if let location = vm.location(id: destination.locationId) {
                        LocationSettingsView(vm: vm, location: location)
                    }
                }
        }
    }
}

#Preview {
    ContentView()
        .environment(LocationsViewModel())
}

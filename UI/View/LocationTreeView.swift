import SwiftUI

struct LocationTreeView: View {
    let vm: LocationsViewModel
    let parent: Location?   // nil = roots
    
    @State private var showingAddLocation = false
    @State private var showingAddItem = false
    @State private var newItemName = ""
    
    var body: some View {
        List {
            // SECTION 1: Sub-Locations (The "Folders")
            Section("Locations") {
                let subLocations = (parent == nil)
                    ? vm.roots
                    : vm.children(of: parent!.id)
                
                if subLocations.isEmpty {
                    Text("No sub-locations")
                        .foregroundStyle(.secondary)
                        .font(.caption)
                }
                
                ForEach(subLocations) { loc in
                    NavigationLink {
                        // Recursive: Go deeper into the tree
                        LocationTreeView(vm: vm, parent: loc)
                            .navigationTitle(loc.name)
                    } label: {
                        HStack {
                            VStack(alignment: .leading) {
                                Text(loc.name).font(.headline)
                                Text(loc.type.rawValue).font(.caption).foregroundStyle(.secondary)
                            }
                            Spacer()
                            // Show count of children inside
                            let count = vm.childCount(of: loc.id)
                            if count > 0 {
                                Text("\(count)")
                                    .font(.caption2)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(.quaternary)
                                    .clipShape(Capsule())
                            }
                        }
                    }
                }
            }
            
            // SECTION 2: Items (The "Files") - Only show if we are inside a location
            if let parentLocation = parent {
                Section("Items") {
                    let items = vm.items(for: parentLocation.id)
                    
                    if items.isEmpty {
                        Text("No items")
                            .foregroundStyle(.secondary)
                            .font(.caption)
                    }
                    
                    ForEach(items) { item in
                        HStack {
                            Image(systemName: "box.truck.fill")
                                .foregroundStyle(.blue)
                            Text(item.name)
                        }
                    }
                    
                    // Quick Add Item Button
                    Button {
                        newItemName = ""
                        showingAddItem = true
                    } label: {
                        Label("Add Item", systemImage: "plus")
                    }
                }
            }
        }
        // Toolbar with "Add Location" (+ icon)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showingAddLocation = true
                } label: {
                    Image(systemName: "folder.badge.plus")
                }
            }
        }
        // Sheet for adding Sub-Locations
        .sheet(isPresented: $showingAddLocation) {
            AddLocationSheet(vm: vm, parent: parent)
        }
        // Popup for adding Items
        .alert("Add Item", isPresented: $showingAddItem) {
            TextField("Item Name", text: $newItemName)
            Button("Cancel", role: .cancel) { }
            Button("Add") {
                if !newItemName.isEmpty, let parentId = parent?.id {
                    vm.addItem(name: newItemName, parentId: parentId)
                }
            }
        } message: {
            Text("What is stored in \(parent?.name ?? "this location")?")
        }
    }
}

#Preview {
    NavigationStack {
        LocationTreeView(vm: LocationsViewModel(), parent: nil)
            .navigationTitle("Home Inventory")
    }
}

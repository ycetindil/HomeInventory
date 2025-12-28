import SwiftUI

struct LocationDetailView: View {
    let location: Location
    var vm: LocationsViewModel // We pass the brain down to this view
    
    @State private var showingAddItem = false
    @State private var newItemName = ""

    // Ask the VM for items that belong to THIS location
    var items: [Item] {
        vm.items(for: location.id)
    }

    var body: some View {
        List {
            // Section 1: The Items list
            Section("Items in \(location.name)") {
                if items.isEmpty {
                    Text("No items here yet.")
                        .foregroundStyle(.secondary)
                        .italic()
                }
                
                ForEach(items) { item in
                    Text("📦 \(item.name)")
                }
                // (We will add swipe-to-delete later)
                
                Button {
                    newItemName = ""
                    showingAddItem = true
                } label: {
                    Label("Add Item", systemImage: "plus.circle.fill")
                        .foregroundStyle(.blue)
                }
            }
            
            // Section 2: Metadata (Placeholders for now)
            Section("Details") {
                HStack {
                    Text("Type")
                    Spacer()
                    Text(location.type.rawValue.capitalized)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .navigationTitle(location.name)
        // The "Quick Add" Popup
        .alert("Add Item", isPresented: $showingAddItem) {
            TextField("Item Name", text: $newItemName)
            Button("Cancel", role: .cancel) { }
            Button("Add") {
                if !newItemName.isEmpty {
                    // Save to the database
                    vm.addItem(name: newItemName, parentId: location.id)
                }
            }
        } message: {
            Text("What is stored in \(location.name)?")
        }
    }
}

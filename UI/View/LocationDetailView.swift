import SwiftUI
import PhotosUI

struct LocationDetailView: View {
    let location: Location
    var vm: LocationsViewModel
    
    // State for the photo picker and "Add Item" alert
    @State private var selectedItem: PhotosPickerItem?
    @State private var showingAddItem = false
    @State private var newItemName = ""
    
    // Fetch items dynamically
    var items: [Item] {
        vm.items(for: location.id)
    }

    var body: some View {
        List {
            // --- SECTION 1: The Photo (Map) ---
            Section {
                // A. Show the Image (or placeholder)
                if let image = vm.image(for: location) {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(height: 250)
                        .listRowInsets(EdgeInsets())
                        .clipped()
                } else {
                    ContentUnavailableView("No Room Photo", systemImage: "camera")
                        .frame(height: 150)
                        .foregroundStyle(.secondary)
                }
                
                // B. The Button to Add/Change Photo
                PhotosPicker(selection: $selectedItem, matching: .images) {
                    Label(
                        location.primaryMapImageId == nil ? "Add Photo" : "Change Photo",
                        systemImage: "photo.badge.plus"
                    )
                    .frame(maxWidth: .infinity)
                    .fontWeight(.semibold)
                }
                .onChange(of: selectedItem) { _, newItem in
                    Task {
                        if let data = try? await newItem?.loadTransferable(type: Data.self),
                           let uiImage = UIImage(data: data) {
                            // Save the image to the VM
                            vm.setImage(uiImage, for: location.id)
                        }
                    }
                }
            } header: {
                Text("Room Map")
            }

            // --- SECTION 2: The Items ---
            Section("Items in \(location.name)") {
                if items.isEmpty {
                    Text("No items here yet.")
                        .italic()
                        .foregroundStyle(.secondary)
                }
                
                ForEach(items) { item in
                    HStack {
                        Image(systemName: "tag.fill")
                            .foregroundStyle(.orange)
                        Text(item.name)
                    }
                }
                
                Button {
                    newItemName = ""
                    showingAddItem = true
                } label: {
                    Label("Quick Add Item", systemImage: "plus")
                        .foregroundStyle(.blue)
                }
            }
        }
        .navigationTitle(location.name)
        // Popup for adding items
        .alert("Add Item", isPresented: $showingAddItem) {
            TextField("Item Name", text: $newItemName)
            Button("Cancel", role: .cancel) { }
            Button("Add") {
                if !newItemName.isEmpty {
                    vm.addItem(name: newItemName, parentId: location.id)
                }
            }
        } message: {
            Text("What is stored in \(location.name)?")
        }
    }
}

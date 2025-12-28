import SwiftUI
import PhotosUI

struct LocationDetailView: View {
    let location: Location
    var vm: LocationsViewModel
    
    @State private var showingAddItem = false
    @State private var newItemName = ""
    
    // Photo Picker State
    @State private var selectedItem: PhotosPickerItem?
    
    var items: [Item] {
        vm.items(for: location.id)
    }

    var body: some View {
        List {
            // SECTION 1: The "Map" (Photo)
            Section {
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
                }
                
                // The Button to Pick/Change Photo
                PhotosPicker(selection: $selectedItem, matching: .images) {
                    Label(location.primaryMapImageId == nil ? "Add Photo" : "Change Photo", systemImage: "photo")
                        .frame(maxWidth: .infinity)
                }
                .onChange(of: selectedItem) { _, newItem in
                    Task {
                        if let data = try? await newItem?.loadTransferable(type: Data.self),
                           let uiImage = UIImage(data: data) {
                            vm.setImage(uiImage, for: location.id)
                        }
                    }
                }
            } header: {
                Text("Room Map")
            }

            // SECTION 2: Items
            Section("Items in \(location.name)") {
                if items.isEmpty {
                    Text("No items here yet.")
                        .foregroundStyle(.secondary)
                        .italic()
                }
                
                ForEach(items) { item in
                    HStack {
                        Image(systemName: "tag.fill").foregroundStyle(.orange)
                        Text(item.name)
                    }
                }
                
                Button {
                    newItemName = ""
                    showingAddItem = true
                } label: {
                    Label("Quick Add Item", systemImage: "plus.circle.fill")
                }
            }
            
            // SECTION 3: Metadata
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

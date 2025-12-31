import SwiftUI
import PhotosUI // <--- Required for the picker

struct LocationView: View {
    let vm: LocationsViewModel
    let parent: Location?   // nil = roots
    
    // State for Adding Sub-locations and Items
    @State private var showingAddLocation = false
    @State private var showingAddItem = false
    @State private var newItemName = ""
    
    // State for Photo Picker
    @State private var selectedPhoto: PhotosPickerItem?
    
    // State for async image loading
    @State private var loadedImage: UIImage?
    
    // State for hotspot editing
    @State private var isEditingMap = false
    @State private var pendingHotspotCoords: (x: Double, y: Double)?
    @State private var showingAddHotspotAlert = false
    @State private var newLocationName = ""
    
    // State for location management
    @State private var locationToRename: Location?
    @State private var locationToDelete: Location?
    @State private var locationToMove: Location?
    @State private var showingRenameAlert = false
    @State private var showingDeleteAlert = false
    @State private var showingMoveLocationPicker = false
    @State private var newLocationNameForRename = ""
    @State private var isAddingLocation = false
    @State private var locationSettingsDestination: LocationSettingsDestination?
    
    // State for item management
    @State private var itemToMove: Item?
    @State private var itemToDuplicate: Item?
    @State private var showingMoveItemPicker = false
    @State private var itemToDelete: Item?
    @State private var showingDeleteItemConfirmation = false
    
    // State for programmatic navigation (location edit)
    @State private var navLocationToEdit: LocationEditDestination?
    
    // Get the latest location data from VM
    private var currentLocation: Location? {
        guard let parent = parent else { return nil }
        return vm.location(with: parent.id) ?? parent
    }
    
    // Filter hotspots for the current map image
    private var currentHotspots: [Hotspot] {
        guard let currentLoc = currentLocation,
              let mapImageId = currentLoc.primaryMapImageId else { return [] }
        return vm.hotspots.filter { $0.mapImageId == mapImageId }
    }
    
    var body: some View {
        contentWithDeleteAlert
    }
    
    private var contentWithSheets: some View {
        contentWithSearchAndToolbar
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background {
                if let destination = locationSettingsDestination {
                    NavigationLink(value: destination) {
                        EmptyView()
                    }
                    .hidden()
                }
            }
            .sheet(item: $locationToMove) { location in
                moveLocationSheet(for: location)
            }
            .sheet(item: $itemToMove) { item in
                moveItemSheet(for: item)
            }
            .sheet(item: $itemToDuplicate) { item in
                duplicateItemSheet(for: item)
            }
            .sheet(isPresented: $isAddingLocation) {
                AddLocationSheet(vm: vm, parent: parent)
            }
            .confirmationDialog("Delete Item?", isPresented: $showingDeleteItemConfirmation, titleVisibility: .visible) {
                Button("Delete", role: .destructive) {
                    if let item = itemToDelete {
                        vm.deleteItem(item.id)
                    }
                    itemToDelete = nil
                }
            } message: {
                Text("Are you sure? This cannot be undone.")
            }
            .background {
                if let locationEdit = navLocationToEdit {
                    NavigationLink(value: locationEdit) {
                        EmptyView()
                    }
                    .hidden()
                }
            }
            .onChange(of: locationSettingsDestination) { _, newValue in
                // Reset after navigation
                if newValue != nil {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        locationSettingsDestination = nil
                    }
                }
            }
            .onChange(of: navLocationToEdit) { _, newValue in
                // Reset after navigation
                if newValue != nil {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        navLocationToEdit = nil
                    }
                }
            }
            .onChange(of: itemToDelete) { _, newValue in
                showingDeleteItemConfirmation = newValue != nil
            }
    }
    
    private var contentWithDeleteAlert: some View {
        contentWithRenameAlert
            .alert("Delete Location", isPresented: $showingDeleteAlert) {
                Button("Cancel", role: .cancel) {
                    locationToDelete = nil
                }
                Button("Delete", role: .destructive) {
                    if let location = locationToDelete {
                        vm.deleteLocation(location.id)
                    }
                    locationToDelete = nil
                }
            } message: {
                if let location = locationToDelete {
                    Text("Are you sure you want to delete \"\(location.name)\"? This will also delete all sub-locations and items within it.")
                }
            }
    }
    
    private var contentWithRenameAlert: some View {
        contentWithFirstAlerts
            .alert("Rename Location", isPresented: $showingRenameAlert) {
                TextField("Location Name", text: $newLocationNameForRename)
                Button("Cancel", role: .cancel) {
                    locationToRename = nil
                    newLocationNameForRename = ""
                }
                Button("Save") {
                    if let location = locationToRename,
                       !newLocationNameForRename.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        vm.updateLocation(location, newName: newLocationNameForRename.trimmingCharacters(in: .whitespacesAndNewlines), type: location.type)
                    }
                    locationToRename = nil
                    newLocationNameForRename = ""
                }
            } message: {
                if let location = locationToRename {
                    Text("Enter a new name for \(location.name)")
                }
            }
    }
    
    private var contentWithFirstAlerts: some View {
        contentWithAddLocationAlert
    }
    
    private var contentWithAddLocationAlert: some View {
        contentWithAddItemAlert
            .alert("Add Location", isPresented: $showingAddHotspotAlert) {
                TextField("Location Name", text: $newLocationName)
                Button("Cancel", role: .cancel) {
                    pendingHotspotCoords = nil
                }
                Button("Add") {
                    handleCreateHotspot()
                }
            } message: {
                Text("Enter a name for the location at this hotspot")
            }
    }
    
    private var contentWithAddItemAlert: some View {
        contentWithSheets
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
    
    private var contentView: some View {
        VStack(spacing: 0) {
            // Breadcrumb navigation (only show when we have a parent location)
            if let parent = parent {
                BreadcrumbView(path: vm.breadcrumbPath(for: parent))
            }
            
            Group {
                if !vm.searchText.isEmpty {
                    searchResultsView
                } else {
                    locationListView
                }
            }
        }
    }
    
    private var contentWithSearchAndToolbar: some View {
        contentView
            .searchable(text: Binding(
                get: { vm.searchText },
                set: { vm.searchText = $0 }
            ), prompt: "Search items")
            .toolbar {
                if let currentLoc = currentLocation, currentLoc.primaryMapImageId != nil, vm.searchText.isEmpty {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(isEditingMap ? "Done" : "Edit Map") {
                            isEditingMap.toggle()
                        }
                    }
                }
                if parent != nil, let currentLoc = currentLocation {
                    ToolbarItem(placement: .primaryAction) {
                        NavigationLink(value: LocationEditDestination(location: currentLoc)) {
                            Text("Edit")
                        }
                    }
                }
            }
    }
    
    private func moveLocationSheet(for location: Location) -> some View {
        // Create a binding that handles getter/setter logic
        let selectionBinding = Binding<UUID?>(
            get: {
                // Getter: Return the current parentId
                location.parentId
            },
            set: { newId in
                // Setter: When user picks a new ID
                // If newId is nil, it means 'Move to Root'
                do {
                    try vm.moveLocation(location, to: newId)
                    locationToMove = nil
                } catch {
                    print("Error moving location: \(error.localizedDescription)")
                }
            }
        )
        
        return NavigationStack {
            LocationPicker(
                selection: selectionBinding,
                blockedIds: vm.allDescendantIds(of: location.id).union([location.id]),
                currentParentId: nil,
                originId: location.parentId,
                title: "Move to...",
                rootTitle: "Move to Top Level"
            )
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        locationToMove = nil
                    }
                }
            }
        }
        .environment(vm) // <--- Must be OUTSIDE LocationPicker, attached to NavStack
    }
    
    @ViewBuilder
    func generalLocationPicker(for item: Item) -> some View {
        LocationPicker(
            selection: Binding(
                get: { item.locationId },
                set: { newId in
                    if let id = newId {
                        vm.moveItem(item, to: id)
                    } else {
                        vm.moveItem(item, to: nil)
                    }
                    itemToMove = nil
                }
            ),
            blockedIds: [],
            currentParentId: nil,
            originId: item.locationId,
            title: "Move to...",
            rootTitle: "Remove from Location (Unassign)"
        )
    }
    
    private func moveItemSheet(for item: Item) -> some View {
        return NavigationStack {
            generalLocationPicker(for: item)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") {
                            itemToMove = nil
                        }
                    }
                }
        }
        .environment(vm)
    }
    
    private func duplicateItemSheet(for item: Item) -> some View {
        // Create a binding that handles getter/setter logic
        let selectionBinding = Binding<UUID?>(
            get: {
                // Getter: Start with no selection
                nil
            },
            set: { newId in
                // Setter: When user picks a new ID
                if let newId = newId {
                    vm.duplicateItem(item, to: newId)
                    itemToDuplicate = nil
                }
            }
        )
        
        return NavigationStack {
            LocationPicker(
                selection: selectionBinding,
                blockedIds: [],
                currentParentId: nil,
                originId: nil,
                title: "Duplicate to...",
                rootTitle: "Duplicate to Top Level"
            )
        }
        .environment(vm) // <--- Must be OUTSIDE LocationPicker, attached to NavStack
    }
    
    private var searchResultsView: some View {
        List {
            ForEach(vm.searchResults) { item in
                NavigationLink(value: ItemEditDestination(item: item)) {
                    HStack {
                        Image(systemName: "box.truck.fill")
                            .foregroundStyle(.blue)
                        VStack(alignment: .leading, spacing: 4) {
                            Text(item.name)
                                .foregroundStyle(.primary)
                            if let parentLocation = vm.location(for: item) {
                                Text(parentLocation.name)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        Spacer()
                    }
                }
            }
            
            if vm.searchResults.isEmpty {
                ContentUnavailableView.search(text: vm.searchText)
            }
        }
    }
    
    private var locationListView: some View {
        List {
            roomMapSection
            locationsSection
            itemsSection
        }
        .task {
            // Load image asynchronously when view appears
            if let currentLoc = currentLocation {
                loadedImage = await vm.image(for: currentLoc)
            }
        }
        .onChange(of: parent?.id) {
            // Reload image when location changes
            Task {
                if let currentLoc = currentLocation {
                    loadedImage = await vm.image(for: currentLoc)
                } else {
                    loadedImage = nil
                }
            }
        }
    }
    
    @ViewBuilder
    private var roomMapSection: some View {
        if let currentLoc = currentLocation {
            Section {
                // A. Show the HotspotImageView (if we have an image) or placeholder
                if currentLoc.primaryMapImageId != nil {
                    HotspotImageView(
                        imageState: loadedImage,
                        hotspots: currentHotspots,
                        isEditing: isEditingMap,
                        onAddHotspot: { x, y in
                            pendingHotspotCoords = (x: x, y: y)
                            newLocationName = ""
                            showingAddHotspotAlert = true
                        },
                        locationForHotspot: { locationId in
                            vm.location(with: locationId)
                        }
                    )
                    .frame(height: 250)
                    .listRowInsets(EdgeInsets())
                    .id(currentLoc.primaryMapImageId)
                    .task(id: currentLoc.primaryMapImageId) {
                        loadedImage = await vm.image(for: currentLoc)
                    }
                } else {
                    ContentUnavailableView("No Room Photo", systemImage: "camera")
                        .frame(height: 150)
                        .foregroundStyle(.secondary)
                }
                
                // B. The Button to Add/Change Photo
                PhotosPicker(selection: $selectedPhoto, matching: .images) {
                    Label(
                        currentLoc.primaryMapImageId == nil ? "Add Photo" : "Change Photo",
                        systemImage: "photo.badge.plus"
                    )
                    .frame(maxWidth: .infinity)
                    .fontWeight(.semibold)
                }
                .buttonStyle(.borderless) // Fixes clickability in List
                .onChange(of: selectedPhoto) { _, newItem in
                    Task {
                        if let data = try? await newItem?.loadTransferable(type: Data.self),
                           let uiImage = UIImage(data: data) {
                            vm.setImage(uiImage, for: currentLoc.id)
                            // The .task(id: currentLoc.primaryMapImageId) will automatically reload the image
                        }
                    }
                }
            } header: {
                Text("Room Photos")
            }
        }
    }
    
    private var locationsSection: some View {
        Section(parent == nil ? "Locations" : "Sub-locations") {
            let subLocations = (parent == nil)
                ? vm.roots
                : vm.children(of: parent!.id)
            
            if subLocations.isEmpty {
                Text("No sub-locations")
                    .foregroundStyle(.secondary)
                    .font(.caption)
            }
            
            ForEach(subLocations) { loc in
                locationRow(for: loc)
            }
            
            Button {
                isAddingLocation = true
            } label: {
                Text(parent == nil ? "+ Add Location" : "+ Add Sub-location")
                    .foregroundStyle(.blue)
            }
        }
    }
    
    private func locationRow(for loc: Location) -> some View {
        NavigationLink(value: loc) {
            HStack {
                Image(systemName: loc.type.iconName)
                    .foregroundStyle(.yellow)
                VStack(alignment: .leading) {
                    Text(loc.name).font(.headline)
                    Text(loc.type.rawValue).font(.caption).foregroundStyle(.secondary)
                }
                Spacer()
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
        .contextMenu {
            Button {
                navLocationToEdit = LocationEditDestination(location: loc)
            } label: {
                Label("Edit", systemImage: "pencil")
            }
            
            Button(role: .destructive) {
                locationToDelete = loc
                showingDeleteAlert = true
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
    }
    
    @ViewBuilder
    private var itemsSection: some View {
        if let parentLocation = parent {
            Section("Items") {
                let items = vm.items(for: parentLocation.id)
                
                if items.isEmpty {
                    Text("No items")
                        .foregroundStyle(.secondary)
                        .font(.caption)
                }
                
                ForEach(items) { item in
                    itemRow(for: item)
                }
                
                Button {
                    newItemName = ""
                    showingAddItem = true
                } label: {
                    Label("Add Item", systemImage: "plus")
                }
            }
        }
    }
    
    private func itemRow(for item: Item) -> some View {
        NavigationLink(value: ItemEditDestination(item: item)) {
            HStack {
                Image(systemName: "box.truck.fill")
                    .foregroundStyle(.blue)
                VStack(alignment: .leading, spacing: 4) {
                    Text(item.name)
                        .foregroundStyle(.primary)
                    if item.quantity > 1 {
                        Text("Quantity: \(item.quantity)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    if let note = item.note, !note.isEmpty {
                        Text(note)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    }
                }
                Spacer()
            }
        }
        .buttonStyle(.plain)
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            Button {
                itemToDuplicate = item
            } label: {
                Label("Duplicate", systemImage: "doc.on.doc")
            }
            .tint(.indigo)
            
            Button {
                itemToMove = item
            } label: {
                Label("Move", systemImage: "folder")
            }
            .tint(.orange)
            
            Button {
                let itemToCache = item
                // Small delay to allow swipe animation to settle
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    itemToDelete = itemToCache
                    showingDeleteItemConfirmation = true
                }
            } label: {
                Label("Delete", systemImage: "trash")
            }
            .tint(.red)
        }
        .contextMenu {
            Button {
                itemToDuplicate = item
            } label: {
                Label("Duplicate", systemImage: "doc.on.doc")
            }
            
            NavigationLink(value: ItemEditDestination(item: item)) {
                Label("Edit", systemImage: "pencil")
            }
            
            Button {
                itemToMove = item
            } label: {
                Label("Move", systemImage: "folder")
            }
            
            Button {
                let itemToCache = item
                // Small delay to allow swipe animation to settle
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    itemToDelete = itemToCache
                    showingDeleteItemConfirmation = true
                }
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
    }
    
    private func handleCreateHotspot() {
        guard let coords = pendingHotspotCoords,
              let currentLoc = currentLocation,
              let mapImageId = currentLoc.primaryMapImageId,
              !newLocationName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return
        }
        
        // Add the new location
        vm.addLocation(
            name: newLocationName.trimmingCharacters(in: .whitespacesAndNewlines),
            type: .room,
            parentId: currentLoc.id
        )
        
        // Find the newly created location (most recently added with matching parentId and name)
        if let newLocation = vm.locations.first(where: {
            $0.parentId == currentLoc.id &&
            $0.name == newLocationName.trimmingCharacters(in: .whitespacesAndNewlines)
        }) {
            // Add Hotspot to newLocation
            vm.addHotspot(
                locationId: newLocation.id,
                x: coords.x,
                y: coords.y,
                mapImageId: mapImageId
            )
        }
        // Reset state
        pendingHotspotCoords = nil
        newLocationName = ""
    }
}


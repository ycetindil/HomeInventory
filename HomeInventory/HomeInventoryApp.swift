import SwiftUI

@main
struct HomeInventoryApp: App {
    // 1. Create the persistent storage ("The Brain")
    @State private var repository = DiskInventoryRepository()
    
    init() {
        #if DEBUG
        _domainCompileCheck()
        #endif
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                // 2. Pass it to the ViewModel
                .environment(LocationsViewModel(repo: repository))
        }
    }

    #if DEBUG
    private func _domainCompileCheck() {
        _ = Location.self
        _ = LocationType.self
    }
    #endif
}

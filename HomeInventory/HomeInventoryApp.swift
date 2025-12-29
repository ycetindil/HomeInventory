import SwiftUI

@main
struct HomeInventoryApp: App {
    // Create the ViewModel once at app level
    @State private var viewModel = LocationsViewModel()
    
    init() {
        #if DEBUG
        _domainCompileCheck()
        #endif
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                // Pass the ViewModel to the environment
                .environment(viewModel)
        }
    }

    #if DEBUG
    private func _domainCompileCheck() {
        _ = Location.self
        _ = LocationType.self
    }
    #endif
}

import SwiftUI

@main
struct HomeInventoryApp: App {
    init() {
        #if DEBUG
        _domainCompileCheck()
        #endif
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }

    #if DEBUG
    private func _domainCompileCheck() {
        _ = Location.self
        _ = LocationType.self
    }
    #endif
}

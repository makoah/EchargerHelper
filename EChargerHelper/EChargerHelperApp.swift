import SwiftUI

@main
struct EChargerHelperApp: App {
    @StateObject private var sharedChargerService = RealChargerService()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(sharedChargerService)
        }
    }
}
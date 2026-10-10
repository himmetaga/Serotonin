import SwiftUI

@main
@MainActor
struct SerotoninApp: App {
    var body: some Scene {
        WindowGroup {
            GardenView()
                .preferredColorScheme(.dark)
        }
    }
}

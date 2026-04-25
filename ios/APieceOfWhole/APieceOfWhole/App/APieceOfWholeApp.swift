import SwiftUI

@main
struct APieceOfWholeApp: App {
    @State private var appState = AppState()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(appState)
                .task {
                    await appState.load()
                }
        }
    }
}

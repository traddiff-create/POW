import SwiftUI

struct ManageTabView: View {
    @Environment(AppState.self) var appState

    var body: some View {
        ZStack {
            Color.hereBackground.ignoresSafeArea()
            if appState.role == .admin {
                AdminDashboardView()
            } else {
                FacilitatorDashboardView()
            }
        }
        .navigationTitle("Manage")
        .navigationBarTitleDisplayMode(.large)
    }
}

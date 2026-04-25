import SwiftUI

struct MainTabView: View {
    @Environment(AppState.self) var appState
    @State private var selectedTab: Tab = .today

    enum Tab {
        case today, spiral, practice, journal, circle, myPiece, civic, settings, manage
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            TodayView()
                .tabItem { Label("Today", systemImage: "sun.horizon") }
                .tag(Tab.today)

            SpiralView()
                .tabItem { Label("Spiral", systemImage: "arrow.clockwise.circle") }
                .tag(Tab.spiral)

            PracticeLibraryView()
                .tabItem { Label("Practice", systemImage: "waveform") }
                .tag(Tab.practice)

            JournalListView()
                .tabItem { Label("Journal", systemImage: "book.closed") }
                .tag(Tab.journal)

            CircleView()
                .tabItem { Label("Circle", systemImage: "person.3") }
                .tag(Tab.circle)

            MyPieceView()
                .tabItem { Label("My Piece", systemImage: "leaf") }
                .tag(Tab.myPiece)

            CivicView()
                .tabItem { Label("Civic", systemImage: "building.columns") }
                .tag(Tab.civic)

            NavigationStack {
                SettingsView()
            }
            .tabItem { Label("Settings", systemImage: "gear") }
            .tag(Tab.settings)

            if appState.role != .participant {
                NavigationStack {
                    ManageTabView()
                }
                .tabItem { Label("Manage", systemImage: "slider.horizontal.3") }
                .tag(Tab.manage)
            }
        }
        .tint(Color.powSage)
    }
}

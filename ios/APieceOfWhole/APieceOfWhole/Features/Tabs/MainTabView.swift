import SwiftUI

struct MainTabView: View {
    @Environment(AppState.self) var appState
    @State private var selectedTab: Tab = .today

    enum Tab {
        case today, practice, learn, journal, circle, spiral, myPiece, civic, settings, manage
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            TodayView()
                .tabItem { Label("Today", systemImage: "sun.horizon") }
                .tag(Tab.today)

            PracticeLibraryView()
                .tabItem { Label("Practice", systemImage: "waveform") }
                .tag(Tab.practice)

            LearnView()
                .tabItem { Label("Learn", systemImage: "text.book.closed") }
                .tag(Tab.learn)

            JournalListView()
                .tabItem { Label("Journal", systemImage: "book.closed") }
                .tag(Tab.journal)

            CircleView()
                .tabItem { Label("Circle", systemImage: "person.3") }
                .tag(Tab.circle)

            SpiralView()
                .tabItem { Label("Spiral", systemImage: "arrow.clockwise.circle") }
                .tag(Tab.spiral)

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

            if appState.canAccessManagement {
                NavigationStack {
                    ManageTabView()
                }
                .tabItem { Label("Manage", systemImage: "slider.horizontal.3") }
                .tag(Tab.manage)
            }
        }
        .tint(Color.powSage)
        .onOpenURL { url in
            guard url.scheme == "apow", url.host == "tab" else { return }
            switch url.pathComponents.last {
            case "today":    selectedTab = .today
            case "practice": selectedTab = .practice
            case "learn":    selectedTab = .learn
            case "journal":  selectedTab = .journal
            case "circle":   selectedTab = .circle
            case "spiral":   selectedTab = .spiral
            case "mypiece":  selectedTab = .myPiece
            case "civic":    selectedTab = .civic
            case "settings": selectedTab = .settings
            case "manage":   selectedTab = .manage
            default: break
            }
        }
    }
}

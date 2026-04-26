import SwiftUI

struct MainTabView: View {
    @Environment(AppState.self) var appState
    @State private var selectedTab: Tab = .selfFoundation

    enum Tab {
        case selfFoundation, together, community
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            SelfView()
                .tabItem { Label("Self", systemImage: HereLeg.selfFoundation.systemImage) }
                .tag(Tab.selfFoundation)

            TogetherView()
                .tabItem { Label("Together", systemImage: HereLeg.together.systemImage) }
                .tag(Tab.together)

            CommunityView()
                .tabItem { Label("Community", systemImage: HereLeg.community.systemImage) }
                .tag(Tab.community)
        }
        .tint(Color.powSage)
        .onOpenURL { url in
            guard url.scheme == "apow", url.host == "tab" else { return }
            switch url.pathComponents.last {
            case "self", "today", "practice", "journal", "mypiece":
                selectedTab = .selfFoundation
            case "together", "circle":
                selectedTab = .together
            case "community", "civic", "learn", "spiral":
                selectedTab = .community
            default: break
            }
        }
    }
}

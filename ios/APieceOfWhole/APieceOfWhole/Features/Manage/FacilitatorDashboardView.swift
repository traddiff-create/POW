import SwiftUI

struct FacilitatorDashboardView: View {
    @Environment(AppState.self) var appState
    @State private var posts: [CirclePost] = []
    @State private var reports: [Report] = []
    @State private var isLoading = true

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                sectionHeader("Circle Posts", systemImage: "bubble.left.and.bubble.right")
                if posts.isEmpty && !isLoading {
                    emptyState("No posts yet in your circle.")
                } else {
                    ForEach(posts.prefix(10)) { post in
                        NavigationLink(destination: CirclePostDetailView(post: post)) {
                            CirclePostCard(post: post)
                        }
                        .buttonStyle(.plain)
                    }
                }

                sectionHeader("Open Reports", systemImage: "flag")
                if reports.isEmpty && !isLoading {
                    emptyState("No open reports.")
                } else {
                    ForEach(reports.filter { $0.status == "open" }) { report in
                        ReportRow(report: report)
                    }
                }
            }
            .padding(24)
        }
        .task { await load() }
    }

    private func sectionHeader(_ title: String, systemImage: String) -> some View {
        HStack {
            Label(title, systemImage: systemImage)
                .font(.powLabel)
                .foregroundStyle(Color.powForeground)
            Spacer()
        }
    }

    private func emptyState(_ text: String) -> some View {
        Text(text)
            .font(.powBody)
            .foregroundStyle(Color.powMuted)
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func load() async {
        guard let cohortID = appState.activeMembership?.cohortID else {
            isLoading = false
            return
        }
        async let p = try? SupabaseService.shared.fetchCirclePosts(cohortID: cohortID)
        async let r = try? SupabaseService.shared.fetchReports()
        posts = (await p) ?? []
        reports = (await r) ?? []
        isLoading = false
    }
}

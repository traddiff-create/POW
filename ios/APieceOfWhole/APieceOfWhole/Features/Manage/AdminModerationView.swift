import SwiftUI

struct AdminModerationView: View {
    @Environment(AppState.self) var appState
    @State private var reports: [Report] = []
    @State private var isLoading = true

    var body: some View {
        ZStack {
            Color.powBackground.ignoresSafeArea()
            if isLoading {
                ProgressView()
            } else if reports.isEmpty {
                Text("No reports.")
                    .font(.powBody).foregroundStyle(Color.powMuted)
            } else {
                List(reports) { report in
                    ReportRow(report: report)
                        .swipeActions(edge: .trailing) {
                            Button("Resolve") {
                                Task { await resolve(report, status: "resolved") }
                            }
                            .tint(Color.powSage)
                            Button("Dismiss") {
                                Task { await resolve(report, status: "dismissed") }
                            }
                            .tint(Color.powMuted)
                        }
                }
                .scrollContentBackground(.hidden)
                .background(Color.powBackground)
            }
        }
        .navigationTitle("Moderation")
        .navigationBarTitleDisplayMode(.inline)
        .task { await load() }
    }

    private func load() async {
        isLoading = true
        reports = (try? await SupabaseService.shared.fetchReports()) ?? []
        isLoading = false
    }

    private func resolve(_ report: Report, status: String) async {
        guard let resolverID = appState.session?.user.id.uuidString else { return }
        try? await SupabaseService.shared.updateReport(id: report.id, status: status, resolverID: resolverID)
        await load()
    }
}

struct ReportRow: View {
    let report: Report

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(report.reportedContentType ?? "content")
                    .font(.powCaption)
                    .foregroundStyle(Color.powMuted)
                    .textCase(.uppercase)
                Spacer()
                Text(report.status)
                    .font(.powCaption)
                    .foregroundStyle(statusColor)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(statusColor.opacity(0.12))
                    .clipShape(Capsule())
            }
            if let reason = report.reason {
                Text(reason)
                    .font(.powBody)
                    .foregroundStyle(Color.powForeground)
                    .lineLimit(2)
            }
            Text(formatDate(report.createdAt))
                .font(.powCaption)
                .foregroundStyle(Color.powMuted)
        }
        .padding(.vertical, 4)
    }

    private var statusColor: Color {
        switch report.status {
        case "resolved": return Color.powSage
        case "dismissed": return Color.powMuted
        case "reviewing": return Color.powStone
        default: return Color.powError
        }
    }

    private func formatDate(_ iso: String) -> String {
        guard let date = ISO8601DateFormatter().date(from: iso) else { return "" }
        let f = RelativeDateTimeFormatter()
        f.unitsStyle = .abbreviated
        return f.localizedString(for: date, relativeTo: Date())
    }
}

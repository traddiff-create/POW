import SwiftUI

struct AdminModerationView: View {
    @Environment(AppState.self) var appState
    @State private var reports: [Report] = []
    @State private var isLoading = true

    var body: some View {
        ZStack {
            Color.hereBackground.ignoresSafeArea()
            if isLoading {
                ProgressView()
            } else if reports.isEmpty {
                Text("No reports.")
                    .font(.hereBody).foregroundStyle(Color.hereMuted)
            } else {
                List(reports) { report in
                    ReportRow(report: report)
                        .swipeActions(edge: .trailing) {
                            Button("Resolve") {
                                Task { await resolve(report, status: "resolved") }
                            }
                            .tint(Color.hereSage)
                            Button("Dismiss") {
                                Task { await resolve(report, status: "dismissed") }
                            }
                            .tint(Color.hereMuted)
                        }
                }
                .scrollContentBackground(.hidden)
                .background(Color.hereBackground)
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
                    .font(.hereCaption)
                    .foregroundStyle(Color.hereMuted)
                    .textCase(.uppercase)
                Spacer()
                Text(report.status)
                    .font(.hereCaption)
                    .foregroundStyle(statusColor)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(statusColor.opacity(0.12))
                    .clipShape(Capsule())
            }
            if let reason = report.reason {
                Text(reason)
                    .font(.hereBody)
                    .foregroundStyle(Color.hereForeground)
                    .lineLimit(2)
            }
            Text(formatDate(report.createdAt))
                .font(.hereCaption)
                .foregroundStyle(Color.hereMuted)
        }
        .padding(.vertical, 4)
    }

    private var statusColor: Color {
        switch report.status {
        case "resolved": return Color.hereSage
        case "dismissed": return Color.hereMuted
        case "reviewing": return Color.hereStone
        default: return Color.hereError
        }
    }

    private func formatDate(_ iso: String) -> String {
        guard let date = ISO8601DateFormatter().date(from: iso) else { return "" }
        let f = RelativeDateTimeFormatter()
        f.unitsStyle = .abbreviated
        return f.localizedString(for: date, relativeTo: Date())
    }
}

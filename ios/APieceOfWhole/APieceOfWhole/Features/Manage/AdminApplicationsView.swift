import SwiftUI

struct AdminApplicationsView: View {
    @Environment(AppState.self) var appState
    @State private var applications: [CohortApplication] = []
    @State private var isLoading = true
    @State private var filterStatus: ApplicationStatus? = nil

    var filtered: [CohortApplication] {
        guard let f = filterStatus else { return applications }
        return applications.filter { $0.status == f }
    }

    var body: some View {
        ZStack {
            Color.hereBackground.ignoresSafeArea()
            Group {
                if isLoading {
                    ProgressView()
                } else if filtered.isEmpty {
                    Text("No applications found.")
                        .font(.hereBody).foregroundStyle(Color.hereMuted)
                } else {
                    List(filtered) { app in
                        NavigationLink(destination: ApplicationReviewView(application: app) {
                            Task { await load() }
                        }) {
                            ApplicationRow(application: app)
                        }
                    }
                    .scrollContentBackground(.hidden)
                    .background(Color.hereBackground)
                }
            }
        }
        .navigationTitle("Applications")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button("All") { filterStatus = nil }
                    ForEach(ApplicationStatus.allCases, id: \.self) { s in
                        Button(s.rawValue.replacingOccurrences(of: "_", with: " ").capitalized) {
                            filterStatus = s
                        }
                    }
                } label: {
                    Image(systemName: "line.3.horizontal.decrease.circle")
                        .foregroundStyle(Color.hereSage)
                }
            }
        }
        .task { await load() }
    }

    private func load() async {
        isLoading = true
        applications = (try? await SupabaseService.shared.fetchAllApplications()) ?? []
        isLoading = false
    }
}

struct ApplicationRow: View {
    let application: CohortApplication

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(application.applicantName)
                .font(.hereLabel)
                .foregroundStyle(Color.hereForeground)
            HStack {
                Text(application.applicantEmail)
                    .font(.hereCaption)
                    .foregroundStyle(Color.hereMuted)
                Spacer()
                StatusBadge(status: application.status)
            }
        }
        .padding(.vertical, 4)
    }
}

struct StatusBadge: View {
    let status: ApplicationStatus

    var color: Color {
        switch status {
        case .approved: return Color.hereSage
        case .rejected: return Color.hereError
        case .waitlisted: return Color.hereStone
        default: return Color.hereMuted
        }
    }

    var body: some View {
        Text(status.rawValue.replacingOccurrences(of: "_", with: " ").capitalized)
            .font(.hereCaption)
            .foregroundStyle(color)
            .padding(.horizontal, 8)
            .padding(.vertical, 2)
            .background(color.opacity(0.12))
            .clipShape(Capsule())
    }
}

struct ApplicationReviewView: View {
    let application: CohortApplication
    let onUpdate: () async -> Void
    @Environment(AppState.self) var appState
    @State private var isUpdating = false
    @State private var error: String?

    var body: some View {
        ZStack {
            Color.hereBackground.ignoresSafeArea()
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    infoSection
                    intakeSection
                    if application.status == .pending {
                        actionButtons
                    }
                    if let error { Text(error).font(.hereCaption).foregroundStyle(Color.hereError) }
                }
                .padding(24)
            }
        }
        .navigationTitle(application.applicantName)
        .navigationBarTitleDisplayMode(.inline)
    }

    private var infoSection: some View {
        HereCard {
            VStack(alignment: .leading, spacing: 8) {
                detailRow("Email", application.applicantEmail)
                detailRow("Status", application.status.rawValue.replacingOccurrences(of: "_", with: " ").capitalized)
                if let cohortID = application.cohortID {
                    detailRow("Cohort ID", cohortID)
                }
            }
            .padding(16)
        }
    }

    private var intakeSection: some View {
        HereCard {
            VStack(alignment: .leading, spacing: 12) {
                Label("Application Responses", systemImage: "doc.text")
                    .font(.hereLabel).foregroundStyle(Color.hereForeground)
                if let motivation = application.motivation {
                    intakeField("Motivation", motivation)
                }
                if let hoped = application.hopedChange {
                    intakeField("Hoped Change", hoped)
                }
                if let hours = application.weeklyCapacityHours {
                    intakeField("Weekly Hours Available", "\(hours)")
                }
                if let comfort = application.groupComfortLevel {
                    intakeField("Group Comfort (1-5)", "\(comfort)")
                }
            }
            .padding(16)
        }
    }

    private var actionButtons: some View {
        VStack(spacing: 12) {
            HereButton(title: "Approve", isLoading: isUpdating) {
                Task { await updateStatus(.approved) }
            }
            HereButton(title: "Waitlist", style: .ghost, isLoading: isUpdating) {
                Task { await updateStatus(.waitlisted) }
            }
            HereButton(title: "Reject", style: .ghost, isLoading: isUpdating) {
                Task { await updateStatus(.rejected) }
            }
        }
    }

    private func detailRow(_ label: String, _ value: String) -> some View {
        HStack {
            Text(label).font(.hereCaption).foregroundStyle(Color.hereMuted)
            Spacer()
            Text(value).font(.hereCaption).foregroundStyle(Color.hereForeground)
        }
    }

    private func intakeField(_ label: String, _ value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label).font(.hereCaption).foregroundStyle(Color.hereMuted)
            Text(value).font(.hereBody).foregroundStyle(Color.hereForeground)
        }
    }

    private func updateStatus(_ status: ApplicationStatus) async {
        guard let reviewerID = appState.session?.user.id.uuidString else { return }
        isUpdating = true
        error = nil
        do {
            try await SupabaseService.shared.updateApplicationStatus(
                id: application.id, status: status, reviewerID: reviewerID
            )
            await onUpdate()
        } catch {
            self.error = AppPublicError.message(for: error, context: .management)
        }
        isUpdating = false
    }
}

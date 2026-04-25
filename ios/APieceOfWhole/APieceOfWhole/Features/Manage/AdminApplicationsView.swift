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
            Color.powBackground.ignoresSafeArea()
            Group {
                if isLoading {
                    ProgressView()
                } else if filtered.isEmpty {
                    Text("No applications found.")
                        .font(.powBody).foregroundStyle(Color.powMuted)
                } else {
                    List(filtered) { app in
                        NavigationLink(destination: ApplicationReviewView(application: app) {
                            Task { await load() }
                        }) {
                            ApplicationRow(application: app)
                        }
                    }
                    .scrollContentBackground(.hidden)
                    .background(Color.powBackground)
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
                        .foregroundStyle(Color.powSage)
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
                .font(.powLabel)
                .foregroundStyle(Color.powForeground)
            HStack {
                Text(application.applicantEmail)
                    .font(.powCaption)
                    .foregroundStyle(Color.powMuted)
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
        case .approved: return Color.powSage
        case .rejected: return Color.powError
        case .waitlisted: return Color.powStone
        default: return Color.powMuted
        }
    }

    var body: some View {
        Text(status.rawValue.replacingOccurrences(of: "_", with: " ").capitalized)
            .font(.powCaption)
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
            Color.powBackground.ignoresSafeArea()
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    infoSection
                    intakeSection
                    if application.status == .pending {
                        actionButtons
                    }
                    if let error { Text(error).font(.powCaption).foregroundStyle(Color.powError) }
                }
                .padding(24)
            }
        }
        .navigationTitle(application.applicantName)
        .navigationBarTitleDisplayMode(.inline)
    }

    private var infoSection: some View {
        POWCard {
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
        POWCard {
            VStack(alignment: .leading, spacing: 12) {
                Label("Application Responses", systemImage: "doc.text")
                    .font(.powLabel).foregroundStyle(Color.powForeground)
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
            POWButton(title: "Approve", isLoading: isUpdating) {
                Task { await updateStatus(.approved) }
            }
            POWButton(title: "Waitlist", style: .ghost, isLoading: isUpdating) {
                Task { await updateStatus(.waitlisted) }
            }
            POWButton(title: "Reject", style: .ghost, isLoading: isUpdating) {
                Task { await updateStatus(.rejected) }
            }
        }
    }

    private func detailRow(_ label: String, _ value: String) -> some View {
        HStack {
            Text(label).font(.powCaption).foregroundStyle(Color.powMuted)
            Spacer()
            Text(value).font(.powCaption).foregroundStyle(Color.powForeground)
        }
    }

    private func intakeField(_ label: String, _ value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label).font(.powCaption).foregroundStyle(Color.powMuted)
            Text(value).font(.powBody).foregroundStyle(Color.powForeground)
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
            self.error = error.localizedDescription
        }
        isUpdating = false
    }
}

import SwiftUI

extension Cohort: Hashable {
    static func == (lhs: Cohort, rhs: Cohort) -> Bool { lhs.id == rhs.id }
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
}

struct CohortListView: View {
    @Binding var path: NavigationPath
    @Environment(AppState.self) var appState
    @State private var cohorts: [Cohort] = []
    @State private var applications: [CohortApplication] = []
    @State private var isLoading = true
    @State private var error: String?

    var body: some View {
        ZStack {
            Color.powBackground.ignoresSafeArea()

            if isLoading {
                ProgressView()
            } else if let error {
                VStack(spacing: 16) {
                    Text("Couldn't load cohorts")
                        .font(.powTitle2)
                        .foregroundStyle(Color.powForeground)
                    Text(error)
                        .font(.powBody)
                        .foregroundStyle(Color.powMuted)
                    POWButton(title: "Retry") { Task { await load() } }
                }
                .padding(24)
            } else if cohorts.isEmpty {
                VStack(spacing: 12) {
                    Text("No cohorts open right now")
                        .font(.powTitle2)
                        .foregroundStyle(Color.powForeground)
                    Text("Check back soon — new cohorts open periodically.")
                        .font(.powBody)
                        .foregroundStyle(Color.powMuted)
                        .multilineTextAlignment(.center)
                }
                .padding(24)
            } else {
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(cohorts) { cohort in
                            CohortCard(cohort: cohort, existingApplication: applicationFor(cohort)) {
                                path.append(cohort)
                            }
                        }
                    }
                    .padding(24)
                }
            }
        }
        .navigationTitle("Open Cohorts")
        .task { await load() }
    }

    private func load() async {
        isLoading = true
        error = nil
        do {
            cohorts = try await appState.fetchOpenCohorts()
            applications = try await appState.fetchApplicationsForCurrentUser()
        } catch {
            self.error = error.localizedDescription
        }
        isLoading = false
    }

    private func applicationFor(_ cohort: Cohort) -> CohortApplication? {
        applications.first { $0.cohortID == cohort.id }
    }
}

struct CohortCard: View {
    let cohort: Cohort
    let existingApplication: CohortApplication?
    let onApply: () -> Void

    var body: some View {
        POWCard {
            VStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(cohort.name)
                        .font(.powTitle2)
                        .foregroundStyle(Color.powForeground)
                        .accessibilityIdentifier("cohort.card.\(cohort.id)")

                    if let description = cohort.description {
                        Text(description)
                            .font(.powBody)
                            .foregroundStyle(Color.powMuted)
                            .lineLimit(3)
                    }
                }

                HStack {
                    Label(cohort.formattedPrice, systemImage: "tag")
                        .font(.powCallout)
                        .foregroundStyle(Color.powMuted)

                    if let startDate = cohort.startDate {
                        Spacer()
                        Label(formatDate(startDate), systemImage: "calendar")
                            .font(.powCallout)
                            .foregroundStyle(Color.powMuted)
                    }
                }

                if let app = existingApplication {
                    ApplicationStatusBadge(status: app.status)
                        .accessibilityIdentifier("cohort.applicationStatus.\(cohort.id)")
                } else {
                    POWButton(title: "Apply", action: onApply)
                        .accessibilityIdentifier("cohort.applyButton.\(cohort.id)")
                }
            }
            .padding(20)
        }
    }

    private func formatDate(_ isoString: String) -> String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withFullDate]
        guard let date = formatter.date(from: isoString) else { return isoString }
        let out = DateFormatter()
        out.dateStyle = .medium
        return out.string(from: date)
    }
}

struct ApplicationStatusBadge: View {
    let status: ApplicationStatus

    var body: some View {
        HStack(spacing: 6) {
            Circle().fill(statusColor).frame(width: 8, height: 8)
            Text(statusLabel)
                .font(.powCallout)
                .foregroundStyle(statusColor)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(statusColor.opacity(0.1))
        .clipShape(Capsule())
    }

    private var statusLabel: String {
        switch status {
        case .pending: return "Application Submitted"
        case .approved: return "Approved — Ready to Pay"
        case .rejected: return "Not Selected"
        case .waitlisted: return "Waitlisted"
        }
    }

    private var statusColor: Color {
        switch status {
        case .pending: return .powStone
        case .approved: return .powSage
        case .rejected: return .powError
        case .waitlisted: return .powMuted
        }
    }
}

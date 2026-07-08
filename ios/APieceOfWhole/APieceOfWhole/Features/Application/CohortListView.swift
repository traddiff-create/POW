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
            Color.hereBackground.ignoresSafeArea()

            if isLoading {
                ProgressView()
            } else if let error {
                VStack(spacing: 16) {
                    Text("Couldn't load cohorts")
                        .font(.hereTitle2)
                        .foregroundStyle(Color.hereForeground)
                    Text(error)
                        .font(.hereBody)
                        .foregroundStyle(Color.hereMuted)
                    HereButton(title: "Retry") { Task { await load() } }
                }
                .padding(24)
            } else if cohorts.isEmpty {
                VStack(spacing: 12) {
                    Text("No cohorts open right now")
                        .font(.hereTitle2)
                        .foregroundStyle(Color.hereForeground)
                    Text("Check back soon — new cohorts open periodically.")
                        .font(.hereBody)
                        .foregroundStyle(Color.hereMuted)
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
            self.error = AppPublicError.message(for: error, context: .cohorts)
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
        HereCard {
            VStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(cohort.name)
                        .font(.hereTitle2)
                        .foregroundStyle(Color.hereForeground)
                        .accessibilityIdentifier("cohort.card.\(cohort.id)")

                    if let description = cohort.description {
                        Text(description)
                            .font(.hereBody)
                            .foregroundStyle(Color.hereMuted)
                            .lineLimit(3)
                    }
                }

                HStack {
                    Label(cohort.formattedPrice, systemImage: "tag")
                        .font(.hereCallout)
                        .foregroundStyle(Color.hereMuted)

                    if let startDate = cohort.startDate {
                        Spacer()
                        Label(formatDate(startDate), systemImage: "calendar")
                            .font(.hereCallout)
                            .foregroundStyle(Color.hereMuted)
                    }
                }

                if let app = existingApplication {
                    ApplicationStatusBadge(status: app.status)
                        .accessibilityIdentifier("cohort.applicationStatus.\(cohort.id)")
                } else {
                    HereButton(title: "Apply", action: onApply)
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
                .font(.hereCallout)
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
        case .pending: return .hereStone
        case .approved: return .hereSage
        case .rejected: return .hereError
        case .waitlisted: return .hereMuted
        }
    }
}

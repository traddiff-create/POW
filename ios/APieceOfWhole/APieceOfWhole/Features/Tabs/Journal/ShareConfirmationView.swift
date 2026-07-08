import SwiftUI

struct ShareConfirmationView: View {
    let entry: JournalEntry
    let onShared: () async -> Void
    @Environment(AppState.self) var appState
    @Environment(\.dismiss) var dismiss
    @State private var isLoading = false
    @State private var error: String?

    var body: some View {
        NavigationStack {
            ZStack {
                Color.hereBackground.ignoresSafeArea()
                VStack(spacing: 32) {
                    Spacer()

                    VStack(spacing: 16) {
                        Image(systemName: "person.2.circle")
                            .font(.system(size: 56))
                            .foregroundStyle(Color.hereSage)

                        Text("Share to Your Circle?")
                            .font(.hereTitle)
                            .foregroundStyle(Color.hereForeground)
                            .multilineTextAlignment(.center)

                        Text("This entry will be visible to everyone in your circle. You cannot un-share it.")
                            .font(.hereBody)
                            .foregroundStyle(Color.hereMuted)
                            .multilineTextAlignment(.center)

                        HereCard {
                            VStack(alignment: .leading, spacing: 8) {
                                if let title = entry.title {
                                    Text(title)
                                        .font(.hereLabel)
                                        .foregroundStyle(Color.hereForeground)
                                }
                                Text(entry.body ?? "")
                                    .font(.hereCallout)
                                    .foregroundStyle(Color.hereMuted)
                                    .lineLimit(4)
                            }
                            .padding(16)
                        }
                    }

                    if let error {
                        Text(error)
                            .font(.hereCaption)
                            .foregroundStyle(Color.hereError)
                            .multilineTextAlignment(.center)
                    }

                    VStack(spacing: 12) {
                        HereButton(title: "Share to Circle", isLoading: isLoading) {
                            Task { await share() }
                        }
                        Button("Keep Private") { dismiss() }
                            .font(.hereCallout)
                            .foregroundStyle(Color.hereMuted)
                    }

                    Spacer()
                }
                .padding(.horizontal, 28)
            }
            .navigationTitle("Share Entry")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }

    private func share() async {
        guard let userID = appState.session?.user.id.uuidString,
              let cohortID = appState.activeMembership?.cohortID,
              let circleID = appState.circleID else {
            error = "Could not find your circle. Please contact support."
            return
        }
        isLoading = true
        error = nil
        do {
            try await SupabaseService.shared.shareJournalEntry(
                entryID: entry.id,
                userID: userID,
                cohortID: cohortID,
                circleID: circleID,
                body: entry.body ?? ""
            )
            await onShared()
            dismiss()
        } catch {
            self.error = AppPublicError.message(for: error, context: .journal)
        }
        isLoading = false
    }
}

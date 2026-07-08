import SwiftUI

struct DeleteAccountView: View {
    @Environment(AppState.self) var appState
    @Environment(\.dismiss) var dismiss
    @State private var reason = ""
    @State private var isSubmitting = false
    @State private var didSubmit = false
    @State private var error: String?

    var body: some View {
        NavigationStack {
            ZStack {
                Color.hereBackground.ignoresSafeArea()
                ScrollView {
                    VStack(spacing: 24) {
                        Image(systemName: didSubmit ? "checkmark.circle" : "person.crop.circle.badge.minus")
                            .font(.system(size: 56))
                            .foregroundStyle(didSubmit ? Color.hereSage : Color.hereMuted)

                        Text(didSubmit ? "Request Received" : "Delete Account")
                            .font(.hereTitle2)
                            .foregroundStyle(Color.hereForeground)

                        if didSubmit {
                            Text("Your account deletion request has been recorded. We will process it within 30 days unless retention is legally required.")
                                .font(.hereBody)
                                .foregroundStyle(Color.hereMuted)
                                .multilineTextAlignment(.center)
                            HereButton(title: "Done") {
                                dismiss()
                            }
                        } else {
                            VStack(spacing: 12) {
                                Text("You can request deletion of your account and associated personal data from inside the app. This removes your profile, cohort activity, check-ins, journal entries, and circle content unless we are legally required to retain a record.")
                                    .font(.hereBody)
                                    .foregroundStyle(Color.hereMuted)
                                    .multilineTextAlignment(.center)

                                Text("This action is reviewed by support before completion. You may be contacted at your account email if we need to confirm details.")
                                    .font(.hereCaption)
                                    .foregroundStyle(Color.hereMuted)
                                    .multilineTextAlignment(.center)
                            }

                            HereTextField(
                                label: "Reason (optional)",
                                text: $reason,
                                placeholder: "Anything you want support to know",
                                axis: .vertical
                            )

                            if let error {
                                Text(error)
                                    .font(.hereCaption)
                                    .foregroundStyle(Color.hereError)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }

                            HereButton(title: "Request Account Deletion", isLoading: isSubmitting) {
                                Task { await submitRequest() }
                            }
                        }
                    }
                    .padding(28)
                }
            }
            .navigationTitle("Delete Account")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }

    private func submitRequest() async {
        guard let userID = appState.session?.user.id.uuidString else { return }
        isSubmitting = true
        error = nil
        do {
            try await SupabaseService.shared.submitAccountDeletionRequest(
                userID: userID,
                reason: reason.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : reason
            )
            didSubmit = true
        } catch {
            self.error = AppPublicError.message(for: error, context: .accountDeletion)
        }
        isSubmitting = false
    }
}

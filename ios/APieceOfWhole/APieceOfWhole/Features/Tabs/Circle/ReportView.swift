import SwiftUI

struct ReportView: View {
    let contentType: String
    let contentID: String
    @Environment(AppState.self) var appState
    @Environment(\.dismiss) var dismiss
    @State private var selectedReason: String? = nil
    @State private var details = ""
    @State private var isSubmitting = false
    @State private var submitted = false
    @State private var error: String?

    private let reasons = [
        "Harassment or bullying",
        "Spam or unwanted content",
        "Harmful or dangerous content",
        "Misinformation",
        "Violates community guidelines",
        "Other"
    ]

    var body: some View {
        NavigationStack {
            ZStack {
                Color.hereBackground.ignoresSafeArea()

                if submitted {
                    submittedView
                } else {
                    formView
                }
            }
            .navigationTitle("Report Content")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }

    private var formView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                Text("What's the issue?")
                    .font(.hereLabel)
                    .foregroundStyle(Color.hereForeground)

                VStack(spacing: 8) {
                    ForEach(reasons, id: \.self) { reason in
                        Button {
                            selectedReason = reason
                        } label: {
                            HStack {
                                Text(reason)
                                    .font(.hereBody)
                                    .foregroundStyle(Color.hereForeground)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                if selectedReason == reason {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundStyle(Color.hereSage)
                                } else {
                                    Image(systemName: "circle")
                                        .foregroundStyle(Color.hereBorder)
                                }
                            }
                            .padding(16)
                            .background(
                                selectedReason == reason ? Color.hereSageLight : Color.hereSurface
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(
                                        selectedReason == reason ? Color.hereSage : Color.hereBorder,
                                        lineWidth: 1
                                    )
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }

                HereTextField(
                    label: "Additional details (optional)",
                    text: $details,
                    placeholder: "Share more context…",
                    axis: .vertical
                )
                .frame(minHeight: 100, alignment: .top)

                if let error {
                    Text(error)
                        .font(.hereCaption)
                        .foregroundStyle(Color.hereError)
                }

                HereButton(title: "Submit Report", isLoading: isSubmitting) {
                    Task { await submit() }
                }
                .disabled(selectedReason == nil)
            }
            .padding(24)
        }
    }

    private var submittedView: some View {
        VStack(spacing: 20) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 56))
                .foregroundStyle(Color.hereSage)
            Text("Report Submitted")
                .font(.hereTitle2)
                .foregroundStyle(Color.hereForeground)
            Text("Thank you. Our team will review this content and take appropriate action.")
                .font(.hereBody)
                .foregroundStyle(Color.hereMuted)
                .multilineTextAlignment(.center)
            HereButton(title: "Done") { dismiss() }
                .padding(.top, 8)
        }
        .padding(28)
    }

    private func submit() async {
        guard let reason = selectedReason,
              let userID = appState.session?.user.id.uuidString else { return }
        isSubmitting = true
        error = nil
        let submission = ReportSubmission(
            reporterID: userID,
            reportedContentID: contentID,
            reportedContentType: contentType,
            reason: details.trimmingCharacters(in: .whitespaces).isEmpty
                ? reason
                : "\(reason): \(details.trimmingCharacters(in: .whitespaces))"
        )
        do {
            try await SupabaseService.shared.submitReport(submission)
            submitted = true
        } catch {
            self.error = AppPublicError.message(for: error, context: .circle)
        }
        isSubmitting = false
    }
}

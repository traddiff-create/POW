import SwiftUI

struct AdminNotificationsView: View {
    @Environment(AppState.self) var appState
    @State private var targetType: TargetType = .all
    @State private var specificUserID = ""
    @State private var notificationType = "announcement"
    @State private var notifTitle = ""
    @State private var notifBody = ""
    @State private var isSending = false
    @State private var error: String?
    @State private var sent = false

    enum TargetType: String, CaseIterable {
        case all = "All Users"
        case specific = "Specific User"
    }

    var body: some View {
        ZStack {
            Color.hereBackground.ignoresSafeArea()
            ScrollView {
                VStack(spacing: 20) {
                    HereCard {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Target").font(.hereLabel).foregroundStyle(Color.hereForeground)
                            Picker("Target", selection: $targetType) {
                                ForEach(TargetType.allCases, id: \.self) { t in
                                    Text(t.rawValue).tag(t)
                                }
                            }
                            .pickerStyle(.segmented)
                            if targetType == .specific {
                                HereTextField(label: "User ID", text: $specificUserID, placeholder: "UUID of target user")
                            }
                        }
                        .padding(16)
                    }

                    HereCard {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Message").font(.hereLabel).foregroundStyle(Color.hereForeground)
                            HereTextField(label: "Title", text: $notifTitle, placeholder: "Notification title")
                            HereTextField(label: "Body", text: $notifBody, placeholder: "Optional message body", axis: .vertical)
                        }
                        .padding(16)
                    }

                    if sent {
                        Text("Notification sent.")
                            .font(.hereBody).foregroundStyle(Color.hereSage)
                    }
                    if let error {
                        Text(error).font(.hereCaption).foregroundStyle(Color.hereError)
                    }

                    HereButton(title: "Send Notification", isLoading: isSending) {
                        Task { await send() }
                    }
                    .disabled(notifTitle.trimmingCharacters(in: .whitespaces).isEmpty)
                }
                .padding(24)
            }
        }
        .navigationTitle("Send Notification")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func send() async {
        isSending = true
        error = nil
        sent = false
        do {
            let targetID = targetType == .specific ? specificUserID.trimmingCharacters(in: .whitespaces) : nil
            try await SupabaseService.shared.sendAdminNotification(
                targetUserID: targetID,
                type: notificationType,
                title: notifTitle.trimmingCharacters(in: .whitespaces),
                body: notifBody.isEmpty ? nil : notifBody
            )
            sent = true
            notifTitle = ""
            notifBody = ""
            specificUserID = ""
        } catch {
            self.error = AppPublicError.message(for: error, context: .management)
        }
        isSending = false
    }
}

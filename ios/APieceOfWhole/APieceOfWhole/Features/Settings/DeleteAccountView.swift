import SwiftUI

struct DeleteAccountView: View {
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                Color.powBackground.ignoresSafeArea()
                VStack(spacing: 24) {
                    Spacer()
                    Image(systemName: "person.crop.circle.badge.minus")
                        .font(.system(size: 56))
                        .foregroundStyle(Color.powMuted)
                    Text("Delete Account")
                        .font(.powTitle2)
                        .foregroundStyle(Color.powForeground)
                    Text("To delete your account and all associated data, please send an email to:")
                        .font(.powBody)
                        .foregroundStyle(Color.powMuted)
                        .multilineTextAlignment(.center)
                    Text("support@apieceofwhole.com")
                        .font(.powLabel)
                        .foregroundStyle(Color.powForeground)
                    Text("Include \"Delete My Account\" in the subject line. We will process your request within 30 days.")
                        .font(.powCaption)
                        .foregroundStyle(Color.powMuted)
                        .multilineTextAlignment(.center)
                    POWButton(title: "Email Deletion Request") {
                        let subject = "Delete My Account".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
                        if let url = URL(string: "mailto:support@apieceofwhole.com?subject=\(subject)") {
                            UIApplication.shared.open(url)
                        }
                    }
                    Spacer()
                }
                .padding(28)
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
}

import SwiftUI

struct SupportView: View {
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                Color.powBackground.ignoresSafeArea()
                VStack(spacing: 24) {
                    Spacer()
                    Image(systemName: "envelope.circle")
                        .font(.system(size: 56))
                        .foregroundStyle(Color.powSage)
                    Text("Contact Support")
                        .font(.powTitle2)
                        .foregroundStyle(Color.powForeground)
                    Text("Have a question or need help? Reach out to our support team.")
                        .font(.powBody)
                        .foregroundStyle(Color.powMuted)
                        .multilineTextAlignment(.center)
                    POWButton(title: "Email Support") {
                        if let url = URL(string: "mailto:support@apieceofwhole.com") {
                            UIApplication.shared.open(url)
                        }
                    }
                    Text("We typically respond within 2 business days.")
                        .font(.powCaption)
                        .foregroundStyle(Color.powMuted)
                    Spacer()
                }
                .padding(28)
            }
            .navigationTitle("Support")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

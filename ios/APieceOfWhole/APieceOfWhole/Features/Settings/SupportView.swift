import SwiftUI

struct SupportView: View {
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                Color.hereBackground.ignoresSafeArea()
                VStack(spacing: 24) {
                    Spacer()
                    Image(systemName: "envelope.circle")
                        .font(.system(size: 56))
                        .foregroundStyle(Color.hereSage)
                    Text("Contact Support")
                        .font(.hereTitle2)
                        .foregroundStyle(Color.hereForeground)
                    Text("Have a question or need help? Reach out to our support team.")
                        .font(.hereBody)
                        .foregroundStyle(Color.hereMuted)
                        .multilineTextAlignment(.center)
                    HereButton(title: "Email Support") {
                        if let url = URL(string: "mailto:rory@traddiff.com") {
                            UIApplication.shared.open(url)
                        }
                    }
                    Text("We typically respond within 2 business days.")
                        .font(.hereCaption)
                        .foregroundStyle(Color.hereMuted)
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

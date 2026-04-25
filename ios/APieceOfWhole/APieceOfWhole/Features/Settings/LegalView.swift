import SwiftUI

struct LegalView: View {
    @Environment(\.dismiss) var dismiss
    @State private var selectedTab = 0

    var body: some View {
        NavigationStack {
            ZStack {
                Color.powBackground.ignoresSafeArea()
                VStack(spacing: 0) {
                    Picker("Document", selection: $selectedTab) {
                        Text("Terms").tag(0)
                        Text("Privacy").tag(1)
                        Text("Community").tag(2)
                    }
                    .pickerStyle(.segmented)
                    .padding(16)

                    ScrollView {
                        Text(documentText)
                            .font(.powBody)
                            .foregroundStyle(Color.powForeground)
                            .padding(24)
                    }
                }
            }
            .navigationTitle(documentTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }

    private var documentTitle: String {
        switch selectedTab {
        case 0: return "Terms of Service"
        case 1: return "Privacy Policy"
        default: return "Community Guidelines"
        }
    }

    private var documentText: String {
        switch selectedTab {
        case 0:
            return """
            Terms of Service

            By using A Piece of Whole, you agree to use this app for personal, non-commercial purposes only. You must be 18 or older to participate. You agree not to share harmful, harassing, or misleading content.

            This app provides a community support experience and does not constitute therapy, medical advice, or crisis intervention. We reserve the right to remove participants who violate community standards.

            For questions, contact support@apieceofwhole.com.
            """
        case 1:
            return """
            Privacy Policy

            We collect your email address, display name, and the content you choose to share in the app (check-ins, journal entries, circle posts). Private journal entries are never shared with other users.

            We use Supabase to store your data securely. We do not sell your data to third parties.

            You may request deletion of your account and data at any time by contacting support@apieceofwhole.com.
            """
        default:
            return """
            Community Guidelines

            A Piece of Whole is a space for honest, caring engagement. We ask that all participants:

            • Share from your own experience
            • Listen with curiosity, not judgment
            • Respect the privacy of what is shared in circle
            • Refrain from giving unsolicited advice
            • Report content that feels harmful or unsafe

            Violations may result in removal from the program without refund. Our team reviews all reports with care.
            """
        }
    }
}

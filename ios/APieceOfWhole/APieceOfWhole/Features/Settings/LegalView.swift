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

            Effective date: April 25, 2026

            A Piece of Whole is an 8-week educational and community support program for adults. By creating an account or participating in a cohort, you confirm that you are at least 18 years old and that the information you provide is accurate.

            This app is not therapy, medical care, legal advice, or crisis intervention. It does not diagnose, treat, or prevent any condition and does not create a therapist-client, clinician-patient, attorney-client, or emergency-services relationship. If you are in danger or crisis, call emergency services or 988 in the United States.

            You are responsible for what you share. Keep other participants' stories private, do not post harassing or harmful content, and do not use the app to solicit, threaten, impersonate, or mislead others. We may moderate content, restrict access, or remove participants when needed to protect the community or comply with law.

            Cohort access may require an in-app purchase. Apple handles purchase processing. Refund requests are handled under Apple's App Store policies unless a separate written agreement applies.

            We may update the app, program content, or these terms. Continued use after updates means you accept the updated terms. Questions can be sent to hello@apieceofwhole.com.
            """
        case 1:
            return """
            Privacy Policy

            Effective date: April 25, 2026

            We collect the information needed to operate A Piece of Whole: account identifiers such as your email address and user ID, your display name, application responses, cohort enrollment records, purchase entitlement records, check-ins, journal entries, circle posts, comments, reports, notifications, and account deletion requests.

            Private check-ins and journal entries are intended to be visible only to you. Circle posts and comments are visible to members and facilitators of your cohort according to the app's sharing controls. Reports may be reviewed by facilitators or administrators for safety and moderation.

            We use service providers such as Supabase for authentication, database, storage, and edge functions, and Apple for App Store purchases. We do not sell personal data and we do not use personal data for cross-app tracking.

            We use your data to provide app functionality, manage cohorts, process entitlements, support safety and moderation, respond to requests, and maintain the service. We retain data while your account is active and as needed for security, legal, operational, or dispute-resolution purposes.

            You can request account deletion in Settings. We will process deletion requests within 30 days unless limited retention is legally required. Privacy questions can be sent to hello@apieceofwhole.com.
            """
        default:
            return """
            Community Guidelines

            A Piece of Whole is a space for honest, caring engagement. Connection is not just an idea here; it is the practice. We ask that all participants:

            - Share from your own experience.
            - Listen with curiosity, not judgment.
            - Respect the privacy of what is shared in circle.
            - Avoid unsolicited advice, diagnosis, or treatment claims.
            - Do not harass, shame, threaten, exploit, or impersonate others.
            - Do not share another person's private information without consent.
            - Keep civic discussion nonpartisan, values-based, and grounded in care rather than ideology.
            - Report content that feels harmful or unsafe.

            Circle participation is not a replacement for professional care or emergency support. If a post suggests immediate danger, contact emergency services or a crisis resource rather than relying on the app.

            Violations may result in content removal, restricted access, removal from the program, or other action needed to protect participants. Our team reviews reports with care.
            """
        }
    }
}

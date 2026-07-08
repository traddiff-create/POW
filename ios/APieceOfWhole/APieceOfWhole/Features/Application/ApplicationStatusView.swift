import SwiftUI

struct ApplicationStatusView: View {
    let application: CohortApplication
    @Environment(AppState.self) var appState
    @State private var showPayment = false

    var body: some View {
        ZStack {
            Color.hereBackground.ignoresSafeArea()

            VStack(spacing: 32) {
                Spacer()

                VStack(spacing: 16) {
                    statusIcon
                        .font(.system(size: 56))
                        .foregroundStyle(statusColor)

                    Text(statusHeadline)
                        .font(.hereTitle)
                        .foregroundStyle(Color.hereForeground)
                        .multilineTextAlignment(.center)
                        .accessibilityIdentifier("applicationStatus.headline")

                    Text(statusMessage)
                        .font(.hereBody)
                        .foregroundStyle(Color.hereMuted)
                        .multilineTextAlignment(.center)
                }

                if application.status == .approved {
                    HereButton(title: "Complete Your Enrollment") {
                        showPayment = true
                    }
                    .accessibilityIdentifier("applicationStatus.completeEnrollmentButton")
                }

                NavigationLink(destination: WhyIHereView()) {
                    Text("Review Why I'm Here")
                        .font(.hereCallout)
                        .foregroundStyle(Color.hereSage)
                }
                .accessibilityIdentifier("applicationStatus.whyHereLink")

                Spacer()
            }
            .padding(.horizontal, 28)
        }
        .navigationTitle("Application Status")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                ApplicantAccountMenu()
            }
        }
        .sheet(isPresented: $showPayment) {
            if let cohortID = application.cohortID {
                PaymentScreenView(cohortID: cohortID)
            }
        }
    }

    private var statusIcon: Image {
        switch application.status {
        case .pending: return Image(systemName: "clock.circle")
        case .approved: return Image(systemName: "checkmark.circle")
        case .rejected: return Image(systemName: "xmark.circle")
        case .waitlisted: return Image(systemName: "list.bullet.circle")
        }
    }

    private var statusColor: Color {
        switch application.status {
        case .pending: return .hereStone
        case .approved: return .hereSage
        case .rejected: return .hereError
        case .waitlisted: return .hereMuted
        }
    }

    private var statusHeadline: String {
        switch application.status {
        case .pending: return "Application Received"
        case .approved: return "You've Been Accepted!"
        case .rejected: return "Not Selected This Round"
        case .waitlisted: return "You're on the Waitlist"
        }
    }

    private var statusMessage: String {
        switch application.status {
        case .pending:
            return "Thank you for applying. We'll review your application and reach out via email within 5–7 business days."
        case .approved:
            return "Congratulations! Complete your enrollment by purchasing your cohort access below."
        case .rejected:
            return "Thank you for your interest. We encourage you to apply again when the next cohort opens."
        case .waitlisted:
            return "You're on our waitlist. We'll contact you if a spot becomes available."
        }
    }
}

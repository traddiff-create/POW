import SwiftUI

struct ApplicationStatusView: View {
    let application: CohortApplication
    @Environment(AppState.self) var appState
    @State private var showPayment = false

    var body: some View {
        ZStack {
            Color.powBackground.ignoresSafeArea()

            VStack(spacing: 32) {
                Spacer()

                VStack(spacing: 16) {
                    statusIcon
                        .font(.system(size: 56))
                        .foregroundStyle(statusColor)

                    Text(statusHeadline)
                        .font(.powTitle)
                        .foregroundStyle(Color.powForeground)
                        .multilineTextAlignment(.center)

                    Text(statusMessage)
                        .font(.powBody)
                        .foregroundStyle(Color.powMuted)
                        .multilineTextAlignment(.center)
                }

                if application.status == .approved {
                    POWButton(title: "Complete Your Enrollment") {
                        showPayment = true
                    }
                }

                Spacer()
            }
            .padding(.horizontal, 28)
        }
        .navigationTitle("Application Status")
        .navigationBarTitleDisplayMode(.inline)
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
        case .pending: return .powStone
        case .approved: return .powSage
        case .rejected: return .powError
        case .waitlisted: return .powMuted
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

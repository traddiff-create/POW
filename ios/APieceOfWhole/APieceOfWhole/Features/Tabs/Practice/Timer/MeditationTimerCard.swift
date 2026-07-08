import SwiftUI

struct MeditationTimerCard: View {
    let sessionStore: MeditationSessionStore
    let settings: MeditationTimerSettingsStore
    let onOpen: () -> Void

    var body: some View {
        HereCard {
            VStack(alignment: .leading, spacing: 16) {
                HStack(alignment: .top, spacing: 14) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.hereSageLight)
                            .frame(width: 54, height: 54)
                        Image(systemName: "timer")
                            .font(.system(size: 24, weight: .medium))
                            .foregroundStyle(Color.hereSage)
                    }

                    VStack(alignment: .leading, spacing: 6) {
                        Text("Meditation Timer")
                            .font(.hereTitle2)
                            .foregroundStyle(Color.hereForeground)

                        Text("\(settings.selectedDurationMinutes) min selected")
                            .font(.hereCallout)
                            .foregroundStyle(Color.hereMuted)

                        Text(statsText)
                            .font(.hereCaption)
                            .foregroundStyle(Color.hereMuted)
                    }

                    Spacer()
                }

                HereButton(title: "Open Timer", action: onOpen)
            }
            .padding(18)
        }
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("meditationTimerCard")
    }

    private var statsText: String {
        guard sessionStore.completedSessionCount > 0 else {
            return "No completed sessions yet"
        }
        let sessionLabel = sessionStore.completedSessionCount == 1 ? "session" : "sessions"
        return "\(sessionStore.completedSessionCount) \(sessionLabel) - \(sessionStore.totalCompletedMinutes) min"
    }
}

#Preview {
    MeditationTimerCard(
        sessionStore: MeditationSessionStore(),
        settings: MeditationTimerSettingsStore(),
        onOpen: {}
    )
    .padding()
    .background(Color.hereBackground)
}

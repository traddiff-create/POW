import Foundation
import OSLog
import UserNotifications

private let meditationNotificationLogger = Logger(
    subsystem: "com.traddifftech.apieceofwhole",
    category: "MeditationNotifications"
)

struct MeditationNotificationScheduler: Sendable {
    private static let sessionEndIdentifier = "pow_meditation_session_end"

    func scheduleSessionEnd(after seconds: Int) {
        guard seconds > 0 else { return }

        let center = UNUserNotificationCenter.current()
        center.getNotificationSettings { settings in
            switch settings.authorizationStatus {
            case .authorized, .provisional, .ephemeral:
                Self.addSessionEndNotification(after: seconds)
            case .notDetermined:
                center.requestAuthorization(options: [.alert, .sound, .badge, .timeSensitive]) { granted, _ in
                    guard granted else { return }
                    Self.addSessionEndNotification(after: seconds)
                }
            case .denied:
                meditationNotificationLogger.info("Notification permission denied for meditation session end")
            @unknown default:
                break
            }
        }
    }

    func cancelSessionEnd() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(
            withIdentifiers: [Self.sessionEndIdentifier]
        )
    }

    private static func addSessionEndNotification(after seconds: Int) {
        let content = UNMutableNotificationContent()
        content.title = "Session Complete"
        content.body = "Your meditation session has ended."
        content.sound = .default
        content.interruptionLevel = .timeSensitive

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(seconds), repeats: false)
        let request = UNNotificationRequest(identifier: sessionEndIdentifier, content: content, trigger: trigger)

        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [sessionEndIdentifier])
        UNUserNotificationCenter.current().add(request) { error in
            if let error {
                meditationNotificationLogger.error("Could not schedule session end notification: \(error.localizedDescription, privacy: .private)")
            }
        }
    }
}

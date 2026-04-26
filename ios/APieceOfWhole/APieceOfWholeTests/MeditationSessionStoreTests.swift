import Foundation
import Testing
@testable import APieceOfWhole

@Suite("Meditation Session Store")
@MainActor
struct MeditationSessionStoreTests {
    @Test
    func GivenCompletedSession_WhenSaved_ThenItRoundTripsThroughUserDefaults() throws {
        let suiteName = "MeditationSessionStoreTests-\(UUID().uuidString)"
        let defaults = try #require(UserDefaults(suiteName: suiteName))
        defer {
            defaults.removePersistentDomain(forName: suiteName)
        }

        let startedAt = Date(timeIntervalSince1970: 1_000)
        let completedAt = Date(timeIntervalSince1970: 1_600)
        let record = MeditationSessionRecord(
            startedAt: startedAt,
            completedAt: completedAt,
            plannedDurationSeconds: 600,
            actualDurationSeconds: 600,
            backgroundSound: "Silence",
            endSound: "Chime",
            windDownSeconds: 120,
            completed: true
        )

        let store = MeditationSessionStore(defaults: defaults)
        store.saveSession(record)

        let reloaded = MeditationSessionStore(defaults: defaults)
        #expect(reloaded.sessions == [record])
        #expect(reloaded.completedSessionCount == 1)
        #expect(reloaded.totalCompletedMinutes == 10)
        #expect(reloaded.latestCompletedSession == record)
    }
}

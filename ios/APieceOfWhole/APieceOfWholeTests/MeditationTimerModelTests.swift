import Foundation
import Testing
@testable import APieceOfWhole

@Suite("Meditation Timer Model")
@MainActor
struct MeditationTimerModelTests {
    @Test
    func GivenSeconds_WhenFormatting_ThenMinuteStringIsReturned() {
        #expect(MeditationTimerModel.formatTime(0) == "0:00")
        #expect(MeditationTimerModel.formatTime(9) == "0:09")
        #expect(MeditationTimerModel.formatTime(125) == "2:05")
        #expect(MeditationTimerModel.formatTime(-3) == "0:00")
    }

    @Test
    func GivenInvalidDurations_WhenValidated_ThenValuesAreClamped() {
        #expect(MeditationTimerModel.validatedDuration(-4) == 1)
        #expect(MeditationTimerModel.validatedDuration(20) == 20)
        #expect(MeditationTimerModel.validatedDuration(300) == 120)
    }

    @Test
    func GivenCountdown_WhenAdvanced_ThenTimerStarts() {
        var now = Date(timeIntervalSince1970: 1_000)
        let timer = MeditationTimerModel(selectedDurationMinutes: 1, autoTick: false) { now }

        timer.prepareCountdown()
        #expect(timer.state == .countdown)
        #expect(timer.countdownValue == 3)

        timer.advanceCountdown()
        #expect(timer.countdownValue == 2)
        timer.advanceCountdown()
        #expect(timer.countdownValue == 1)
        timer.advanceCountdown()

        #expect(timer.state == .running)
        #expect(timer.startedAt == now)
        #expect(timer.timeRemainingSeconds == 60)
    }

    @Test
    func GivenRunningTimer_WhenPausedResumedAndRefreshed_ThenItCompletesFromEndDate() {
        var now = Date(timeIntervalSince1970: 2_000)
        let timer = MeditationTimerModel(selectedDurationMinutes: 1, autoTick: false) { now }

        timer.startTimer()
        now = now.addingTimeInterval(20)
        timer.refresh(now: now)
        #expect(timer.timeRemainingSeconds == 40)

        timer.togglePause()
        #expect(timer.state == .paused)
        #expect(timer.timeRemainingSeconds == 40)

        now = now.addingTimeInterval(100)
        timer.refresh(now: now)
        #expect(timer.state == .paused)
        #expect(timer.timeRemainingSeconds == 40)

        timer.togglePause()
        #expect(timer.state == .running)

        now = now.addingTimeInterval(40)
        timer.refresh(now: now)
        #expect(timer.state == .completed)
        #expect(timer.timeRemainingSeconds == 0)
        #expect(timer.completedAt == now)
    }
}

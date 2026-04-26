import Foundation
import Observation

@MainActor
@Observable
final class MeditationTimerModel {
    static let minimumDurationMinutes = 1
    static let maximumDurationMinutes = 120
    static let selectableDurations = [3, 5] + stride(from: 10, through: 120, by: 5)

    private(set) var selectedDurationMinutes: Int
    private(set) var state: MeditationTimerState = .idle
    private(set) var countdownValue = 3
    private(set) var timeRemainingSeconds = 0
    private(set) var windDownRemainingSeconds = 0
    private(set) var startedAt: Date?
    private(set) var completedAt: Date?

    @ObservationIgnored private var endDate: Date?
    @ObservationIgnored private var windDownEndDate: Date?
    @ObservationIgnored private var pausedTimeRemainingSeconds = 0
    @ObservationIgnored private var countdownTimer: Timer?
    @ObservationIgnored private var tickTimer: Timer?
    @ObservationIgnored private var windDownTimer: Timer?
    @ObservationIgnored private let autoTick: Bool
    @ObservationIgnored private let nowProvider: @MainActor () -> Date

    init(
        selectedDurationMinutes: Int = 20,
        autoTick: Bool = true,
        now: @escaping @MainActor () -> Date = Date.init
    ) {
        self.selectedDurationMinutes = Self.validatedDuration(selectedDurationMinutes)
        self.autoTick = autoTick
        self.nowProvider = now
    }

    var plannedDurationSeconds: Int {
        selectedDurationMinutes * 60
    }

    var progress: Double {
        guard plannedDurationSeconds > 0 else { return 0 }
        let elapsed = Double(plannedDurationSeconds - timeRemainingSeconds)
        return min(max(elapsed / Double(plannedDurationSeconds), 0), 1)
    }

    static func validatedDuration(_ minutes: Int) -> Int {
        min(max(minutes, minimumDurationMinutes), maximumDurationMinutes)
    }

    static func formatTime(_ seconds: Int) -> String {
        let safeSeconds = max(seconds, 0)
        let minutes = safeSeconds / 60
        let remainingSeconds = safeSeconds % 60
        return "\(minutes):\(String(format: "%02d", remainingSeconds))"
    }

    func updateDuration(minutes: Int) {
        guard state == .idle else { return }
        selectedDurationMinutes = Self.validatedDuration(minutes)
    }

    func prepareCountdown() {
        invalidateAllTimers()
        completedAt = nil
        startedAt = nil
        endDate = nil
        pausedTimeRemainingSeconds = 0
        timeRemainingSeconds = plannedDurationSeconds
        countdownValue = 3
        state = .countdown

        guard autoTick else { return }
        countdownTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.advanceCountdown()
            }
        }
    }

    func advanceCountdown() {
        guard state == .countdown else { return }
        if countdownValue > 1 {
            countdownValue -= 1
        } else {
            startTimer()
        }
    }

    func startTimer() {
        countdownTimer?.invalidate()
        countdownTimer = nil

        let now = nowProvider()
        startedAt = now
        completedAt = nil
        timeRemainingSeconds = plannedDurationSeconds
        endDate = now.addingTimeInterval(TimeInterval(plannedDurationSeconds))
        pausedTimeRemainingSeconds = 0
        state = .running
        scheduleTickTimer()
    }

    func togglePause() {
        switch state {
        case .running:
            refresh()
            pausedTimeRemainingSeconds = timeRemainingSeconds
            tickTimer?.invalidate()
            tickTimer = nil
            endDate = nil
            state = .paused
        case .paused:
            let remaining = max(pausedTimeRemainingSeconds, 1)
            endDate = nowProvider().addingTimeInterval(TimeInterval(remaining))
            timeRemainingSeconds = remaining
            state = .running
            scheduleTickTimer()
        default:
            break
        }
    }

    func refresh(now currentDate: Date? = nil) {
        guard state == .running, let endDate else { return }
        let now = currentDate ?? nowProvider()
        let remaining = Int(ceil(endDate.timeIntervalSince(now)))
        guard remaining > 0 else {
            completeTimer(now: now)
            return
        }
        timeRemainingSeconds = remaining
    }

    func startWindDown(seconds: Int) {
        guard seconds > 0 else {
            state = .completed
            return
        }
        tickTimer?.invalidate()
        tickTimer = nil
        windDownRemainingSeconds = seconds
        windDownEndDate = nowProvider().addingTimeInterval(TimeInterval(seconds))
        state = .windingDown

        guard autoTick else { return }
        windDownTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.refreshWindDown()
            }
        }
    }

    func refreshWindDown(now currentDate: Date? = nil) {
        guard state == .windingDown, let windDownEndDate else { return }
        let now = currentDate ?? nowProvider()
        let remaining = Int(ceil(windDownEndDate.timeIntervalSince(now)))
        guard remaining > 0 else {
            windDownTimer?.invalidate()
            windDownTimer = nil
            windDownRemainingSeconds = 0
            state = .completed
            return
        }
        windDownRemainingSeconds = remaining
    }

    func stop() {
        invalidateAllTimers()
        state = .idle
        countdownValue = 3
        timeRemainingSeconds = 0
        windDownRemainingSeconds = 0
        startedAt = nil
        completedAt = nil
        endDate = nil
        windDownEndDate = nil
        pausedTimeRemainingSeconds = 0
    }

    private func completeTimer(now: Date) {
        tickTimer?.invalidate()
        tickTimer = nil
        endDate = nil
        timeRemainingSeconds = 0
        completedAt = now
        state = .completed
    }

    private func scheduleTickTimer() {
        tickTimer?.invalidate()
        tickTimer = nil
        guard autoTick else { return }
        tickTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.refresh()
            }
        }
    }

    private func invalidateAllTimers() {
        countdownTimer?.invalidate()
        tickTimer?.invalidate()
        windDownTimer?.invalidate()
        countdownTimer = nil
        tickTimer = nil
        windDownTimer = nil
    }
}

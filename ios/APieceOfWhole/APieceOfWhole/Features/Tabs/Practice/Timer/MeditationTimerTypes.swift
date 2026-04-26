import Foundation

enum MeditationTimerState: String, Codable, Equatable, Sendable {
    case idle
    case countdown
    case running
    case paused
    case windingDown
    case completed
}

struct MeditationSessionRecord: Codable, Identifiable, Equatable, Sendable {
    let id: UUID
    let startedAt: Date
    let completedAt: Date
    let plannedDurationSeconds: Int
    let actualDurationSeconds: Int
    let backgroundSound: String
    let endSound: String
    let windDownSeconds: Int
    let completed: Bool

    init(
        id: UUID = UUID(),
        startedAt: Date,
        completedAt: Date,
        plannedDurationSeconds: Int,
        actualDurationSeconds: Int,
        backgroundSound: String,
        endSound: String,
        windDownSeconds: Int,
        completed: Bool
    ) {
        self.id = id
        self.startedAt = startedAt
        self.completedAt = completedAt
        self.plannedDurationSeconds = plannedDurationSeconds
        self.actualDurationSeconds = actualDurationSeconds
        self.backgroundSound = backgroundSound
        self.endSound = endSound
        self.windDownSeconds = windDownSeconds
        self.completed = completed
    }
}

struct MeditationTimerPreset: Codable, Identifiable, Equatable, Sendable {
    let id: UUID
    var name: String
    var durationMinutes: Int
    var backgroundSound: String
    var endSound: String
    var volume: Double
    var windDownEnabled: Bool
    var windDownSeconds: Int

    init(
        id: UUID = UUID(),
        name: String,
        durationMinutes: Int,
        backgroundSound: String,
        endSound: String,
        volume: Double,
        windDownEnabled: Bool,
        windDownSeconds: Int
    ) {
        self.id = id
        self.name = name
        self.durationMinutes = durationMinutes
        self.backgroundSound = backgroundSound
        self.endSound = endSound
        self.volume = volume
        self.windDownEnabled = windDownEnabled
        self.windDownSeconds = windDownSeconds
    }
}

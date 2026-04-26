import Foundation
import Observation

@MainActor
@Observable
final class MeditationSessionStore {
    private(set) var sessions: [MeditationSessionRecord] = []

    @ObservationIgnored private let defaults: UserDefaults
    @ObservationIgnored private let sessionsKey = "pow_meditation_sessions"

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        sessions = Self.loadSessions(from: defaults, key: sessionsKey)
    }

    var completedSessions: [MeditationSessionRecord] {
        sessions.filter(\.completed)
    }

    var completedSessionCount: Int {
        completedSessions.count
    }

    var totalCompletedMinutes: Int {
        completedSessions.reduce(0) { total, session in
            total + max(session.actualDurationSeconds / 60, 0)
        }
    }

    var latestCompletedSession: MeditationSessionRecord? {
        completedSessions.first
    }

    func saveSession(_ session: MeditationSessionRecord) {
        if let index = sessions.firstIndex(where: { $0.id == session.id }) {
            sessions[index] = session
        } else {
            sessions.insert(session, at: 0)
        }
        sessions.sort { $0.completedAt > $1.completedAt }
        persist()
    }

    func clear() {
        sessions = []
        defaults.removeObject(forKey: sessionsKey)
    }

    private func persist() {
        guard let data = try? JSONEncoder().encode(sessions) else { return }
        defaults.set(data, forKey: sessionsKey)
    }

    private static func loadSessions(from defaults: UserDefaults, key: String) -> [MeditationSessionRecord] {
        guard let data = defaults.data(forKey: key),
              let decoded = try? JSONDecoder().decode([MeditationSessionRecord].self, from: data) else {
            return []
        }
        return decoded.sorted { $0.completedAt > $1.completedAt }
    }
}

@MainActor
@Observable
final class MeditationTimerSettingsStore {
    private(set) var selectedDurationMinutes: Int
    private(set) var selectedBackgroundSound: String
    private(set) var selectedEndSound: String
    private(set) var volume: Double
    private(set) var windDownEnabled: Bool
    private(set) var windDownSeconds: Int
    private(set) var presets: [MeditationTimerPreset]

    @ObservationIgnored private let defaults: UserDefaults
    @ObservationIgnored private let durationKey = "pow_meditation_selected_duration"
    @ObservationIgnored private let backgroundSoundKey = "pow_meditation_background_sound"
    @ObservationIgnored private let endSoundKey = "pow_meditation_end_sound"
    @ObservationIgnored private let volumeKey = "pow_meditation_volume"
    @ObservationIgnored private let windDownEnabledKey = "pow_meditation_wind_down_enabled"
    @ObservationIgnored private let windDownSecondsKey = "pow_meditation_wind_down_seconds"
    @ObservationIgnored private let presetsKey = "pow_meditation_presets"
    @ObservationIgnored private let maxPresets = 8

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults

        let storedDuration = defaults.object(forKey: durationKey) as? Int ?? 20
        selectedDurationMinutes = MeditationTimerModel.validatedDuration(storedDuration)

        let storedBackground = defaults.string(forKey: backgroundSoundKey) ?? "Silence"
        selectedBackgroundSound = MeditationAudioController.availableBackgroundSounds.contains(storedBackground)
            ? storedBackground
            : "Silence"

        let storedEnd = defaults.string(forKey: endSoundKey) ?? "Chime"
        selectedEndSound = MeditationAudioController.availableEndSounds.contains(storedEnd) ? storedEnd : "Chime"

        if defaults.object(forKey: volumeKey) == nil {
            volume = 0.5
        } else {
            volume = Self.clampedVolume(defaults.double(forKey: volumeKey))
        }

        if defaults.object(forKey: windDownEnabledKey) == nil {
            windDownEnabled = true
        } else {
            windDownEnabled = defaults.bool(forKey: windDownEnabledKey)
        }

        let storedWindDown = defaults.object(forKey: windDownSecondsKey) as? Int ?? 120
        windDownSeconds = Self.validatedWindDownSeconds(storedWindDown)

        presets = Self.loadPresets(from: defaults, key: presetsKey)
    }

    func setDurationMinutes(_ minutes: Int) {
        selectedDurationMinutes = MeditationTimerModel.validatedDuration(minutes)
        defaults.set(selectedDurationMinutes, forKey: durationKey)
    }

    func setBackgroundSound(_ sound: String) {
        guard MeditationAudioController.availableBackgroundSounds.contains(sound) else { return }
        selectedBackgroundSound = sound
        defaults.set(sound, forKey: backgroundSoundKey)
    }

    func setEndSound(_ sound: String) {
        guard MeditationAudioController.availableEndSounds.contains(sound) else { return }
        selectedEndSound = sound
        defaults.set(sound, forKey: endSoundKey)
    }

    func setVolume(_ newVolume: Double) {
        volume = Self.clampedVolume(newVolume)
        defaults.set(volume, forKey: volumeKey)
    }

    func setWindDownEnabled(_ isEnabled: Bool) {
        windDownEnabled = isEnabled
        defaults.set(isEnabled, forKey: windDownEnabledKey)
    }

    func setWindDownSeconds(_ seconds: Int) {
        windDownSeconds = Self.validatedWindDownSeconds(seconds)
        defaults.set(windDownSeconds, forKey: windDownSecondsKey)
    }

    func saveCurrentPreset(named rawName: String) {
        let name = rawName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !name.isEmpty, presets.count < maxPresets else { return }
        let preset = MeditationTimerPreset(
            name: name,
            durationMinutes: selectedDurationMinutes,
            backgroundSound: selectedBackgroundSound,
            endSound: selectedEndSound,
            volume: volume,
            windDownEnabled: windDownEnabled,
            windDownSeconds: windDownSeconds
        )
        presets.append(preset)
        persistPresets()
    }

    func applyPreset(_ preset: MeditationTimerPreset) {
        setDurationMinutes(preset.durationMinutes)
        setBackgroundSound(preset.backgroundSound)
        setEndSound(preset.endSound)
        setVolume(preset.volume)
        setWindDownEnabled(preset.windDownEnabled)
        setWindDownSeconds(preset.windDownSeconds)
    }

    func deletePreset(id: UUID) {
        presets.removeAll { $0.id == id }
        persistPresets()
    }

    private func persistPresets() {
        guard let data = try? JSONEncoder().encode(presets) else { return }
        defaults.set(data, forKey: presetsKey)
    }

    private static func loadPresets(from defaults: UserDefaults, key: String) -> [MeditationTimerPreset] {
        guard let data = defaults.data(forKey: key),
              let decoded = try? JSONDecoder().decode([MeditationTimerPreset].self, from: data) else {
            return []
        }
        return decoded
    }

    private static func clampedVolume(_ volume: Double) -> Double {
        min(max(volume, 0), 1)
    }

    private static func validatedWindDownSeconds(_ seconds: Int) -> Int {
        let allowed = [60, 120, 180]
        return allowed.contains(seconds) ? seconds : 120
    }
}

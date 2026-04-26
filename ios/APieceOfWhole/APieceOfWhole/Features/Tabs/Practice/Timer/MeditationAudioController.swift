import AVFoundation
import Foundation
import Observation
import OSLog

private let meditationAudioLogger = Logger(
    subsystem: "com.traddifftech.apieceofwhole",
    category: "MeditationAudio"
)

@MainActor
@Observable
final class MeditationAudioController {
    static let availableBackgroundSounds = [
        "Silence",
        "Brown Noise",
        "Fire",
        "Flowing Water",
        "Forest Camp",
        "Gong Session",
        "Ocean",
        "Rain",
        "Sound Bowls",
        "Stream",
        "Vipassanā",
        "Walking Meditation",
        "Water Bubbles",
        "White Noise"
    ]

    static let availableEndSounds = ["Bong", "Chime", "Gong", "None"]

    private(set) var currentBackgroundSound: String?

    @ObservationIgnored private var backgroundPlayer: AVAudioPlayer?
    @ObservationIgnored private var endSoundPlayer: AVAudioPlayer?
    @ObservationIgnored private var fadeTask: Task<Void, Never>?
    @ObservationIgnored private var previewStopTask: Task<Void, Never>?
    @ObservationIgnored private var isAudioSessionActive = false

    init() {
        configureAudioSession()
    }

    func playBackgroundSound(named sound: String, volume: Double) {
        stopBackgroundSound()
        activateSessionIfNeeded()

        let safeVolume = Float(min(max(volume, 0), 1))
        let resourceName = sound == "Silence" ? "Silence" : sound
        guard let url = medAudioURL(for: resourceName) else {
            meditationAudioLogger.warning("Background sound not found: \(resourceName, privacy: .public)")
            return
        }

        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.numberOfLoops = -1
            player.prepareToPlay()
            player.volume = 0
            backgroundPlayer = player
            currentBackgroundSound = sound
            player.play()

            let targetVolume: Float = sound == "Silence" ? 0 : 0.6 * safeVolume
            fadeBackground(to: targetVolume, duration: 2)
        } catch {
            meditationAudioLogger.error("Could not play background sound: \(error.localizedDescription, privacy: .private)")
        }
    }

    func pauseBackgroundSound() {
        backgroundPlayer?.pause()
    }

    func resumeBackgroundSound() {
        activateSessionIfNeeded()
        backgroundPlayer?.play()
    }

    func stopBackgroundSound(withFadeOut: Bool = false) {
        previewStopTask?.cancel()
        previewStopTask = nil
        fadeTask?.cancel()
        fadeTask = nil

        guard withFadeOut, let player = backgroundPlayer else {
            backgroundPlayer?.stop()
            backgroundPlayer = nil
            currentBackgroundSound = nil
            deactivateSessionIfPossible()
            return
        }

        fadeTask = Task { @MainActor in
            let steps = 20
            let decrement = player.volume / Float(steps)
            for _ in 0..<steps {
                guard !Task.isCancelled else { return }
                player.volume = max(player.volume - decrement, 0)
                try? await Task.sleep(for: .milliseconds(100))
            }
            player.stop()
            backgroundPlayer = nil
            currentBackgroundSound = nil
            deactivateSessionIfPossible()
        }
    }

    func playEndSound(named sound: String, volume: Double) {
        guard sound != "None" else { return }
        activateSessionIfNeeded()

        guard let url = endAudioURL(for: sound) else {
            meditationAudioLogger.warning("End sound not found: \(sound, privacy: .public)")
            return
        }

        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.numberOfLoops = 0
            player.volume = 0.8 * Float(min(max(volume, 0), 1))
            player.prepareToPlay()
            endSoundPlayer = player
            player.play()
        } catch {
            meditationAudioLogger.error("Could not play end sound: \(error.localizedDescription, privacy: .private)")
        }
    }

    func previewBackgroundSound(named sound: String, volume: Double) {
        playBackgroundSound(named: sound, volume: volume)
        previewStopTask?.cancel()
        previewStopTask = Task { @MainActor in
            try? await Task.sleep(for: .seconds(3))
            guard !Task.isCancelled else { return }
            stopBackgroundSound(withFadeOut: true)
        }
    }

    func playEndSoundPreview(named sound: String, volume: Double) {
        endSoundPlayer?.stop()
        endSoundPlayer = nil
        playEndSound(named: sound, volume: volume)
    }

    func stopAll() {
        stopBackgroundSound()
        endSoundPlayer?.stop()
        endSoundPlayer = nil
        deactivateSessionIfPossible()
    }

    private func configureAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [.mixWithOthers])
        } catch {
            meditationAudioLogger.error("Could not configure audio session: \(error.localizedDescription, privacy: .private)")
        }
    }

    private func activateSessionIfNeeded() {
        guard !isAudioSessionActive else { return }
        do {
            try AVAudioSession.sharedInstance().setActive(true)
            isAudioSessionActive = true
        } catch {
            meditationAudioLogger.error("Could not activate audio session: \(error.localizedDescription, privacy: .private)")
        }
    }

    private func deactivateSessionIfPossible() {
        guard backgroundPlayer == nil, endSoundPlayer == nil, isAudioSessionActive else { return }
        do {
            try AVAudioSession.sharedInstance().setActive(false, options: [.notifyOthersOnDeactivation])
            isAudioSessionActive = false
        } catch {
            meditationAudioLogger.error("Could not deactivate audio session: \(error.localizedDescription, privacy: .private)")
        }
    }

    private func fadeBackground(to targetVolume: Float, duration: TimeInterval) {
        fadeTask?.cancel()
        guard let player = backgroundPlayer else { return }
        fadeTask = Task { @MainActor in
            let steps = 20
            let interval = duration / Double(steps)
            let increment = targetVolume / Float(steps)
            for _ in 0..<steps {
                guard !Task.isCancelled else { return }
                player.volume = min(player.volume + increment, targetVolume)
                try? await Task.sleep(for: .milliseconds(Int(interval * 1000)))
            }
            player.volume = targetVolume
        }
    }

    private func medAudioURL(for resourceName: String) -> URL? {
        Bundle.main.url(forResource: resourceName, withExtension: "m4a", subdirectory: "Audio/Med")
            ?? Bundle.main.url(forResource: resourceName, withExtension: "mp3", subdirectory: "Audio/Med")
    }

    private func endAudioURL(for resourceName: String) -> URL? {
        Bundle.main.url(forResource: resourceName, withExtension: "m4a", subdirectory: "Audio/End")
            ?? Bundle.main.url(forResource: resourceName, withExtension: "mp3", subdirectory: "Audio/End")
    }
}

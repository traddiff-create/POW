import SwiftUI
import UIKit

struct MeditationTimerFlowView: View {
    @Bindable var settings: MeditationTimerSettingsStore
    let sessionStore: MeditationSessionStore

    @Environment(\.dismiss) private var dismiss
    @State private var timer = MeditationTimerModel()
    @State private var audio = MeditationAudioController()
    @State private var sessionStarted = false
    @State private var completionHandled = false
    @State private var windDownStarted = false
    @State private var showExitConfirmation = false

    private let notifications = MeditationNotificationScheduler()

    var body: some View {
        Group {
            switch timer.state {
            case .idle:
                NavigationStack {
                    MeditationTimerSetupView(
                        settings: settings,
                        sessionStore: sessionStore,
                        onStart: startCountdown,
                        onClose: { dismiss() }
                    )
                }
            case .countdown:
                MeditationCountdownView(timer: timer)
            case .running, .paused:
                MeditationActiveTimerView(
                    timer: timer,
                    onTogglePause: togglePause,
                    onExit: { showExitConfirmation = true }
                )
            case .windingDown:
                MeditationWindDownView(
                    timer: timer,
                    onSkip: { dismiss() }
                )
            case .completed:
                MeditationCompletionView()
            }
        }
        .onChange(of: timer.state) { _, newState in
            handleStateChange(newState)
        }
        .alert("End session?", isPresented: $showExitConfirmation) {
            Button("Keep Sitting", role: .cancel) {}
            Button("End Session", role: .destructive) {
                cancelSession()
            }
        } message: {
            Text("This session will not be saved.")
        }
        .onDisappear {
            notifications.cancelSessionEnd()
            if timer.state != .completed {
                timer.stop()
                audio.stopAll()
            } else {
                audio.stopBackgroundSound()
            }
        }
    }

    private func startCountdown() {
        timer.updateDuration(minutes: settings.selectedDurationMinutes)
        timer.prepareCountdown()
    }

    private func togglePause() {
        timer.togglePause()
        switch timer.state {
        case .paused:
            audio.pauseBackgroundSound()
            notifications.cancelSessionEnd()
        case .running:
            audio.resumeBackgroundSound()
            notifications.scheduleSessionEnd(after: timer.timeRemainingSeconds)
        default:
            break
        }
    }

    private func handleStateChange(_ state: MeditationTimerState) {
        switch state {
        case .running where !sessionStarted:
            sessionStarted = true
            audio.playBackgroundSound(named: settings.selectedBackgroundSound, volume: settings.volume)
            notifications.scheduleSessionEnd(after: timer.timeRemainingSeconds)
        case .completed:
            handleCompletion()
        default:
            break
        }
    }

    private func handleCompletion() {
        if completionHandled {
            dismissSoon()
            return
        }

        completionHandled = true
        notifications.cancelSessionEnd()
        audio.stopBackgroundSound()
        playCompletionHaptics()
        audio.playEndSound(named: settings.selectedEndSound, volume: settings.volume)
        saveCompletedSession()

        if settings.windDownEnabled, settings.windDownSeconds > 0, !windDownStarted {
            windDownStarted = true
            timer.startWindDown(seconds: settings.windDownSeconds)
        } else {
            dismissSoon()
        }
    }

    private func saveCompletedSession() {
        guard let startedAt = timer.startedAt,
              let completedAt = timer.completedAt else { return }
        let record = MeditationSessionRecord(
            startedAt: startedAt,
            completedAt: completedAt,
            plannedDurationSeconds: timer.plannedDurationSeconds,
            actualDurationSeconds: timer.plannedDurationSeconds,
            backgroundSound: settings.selectedBackgroundSound,
            endSound: settings.selectedEndSound,
            windDownSeconds: settings.windDownEnabled ? settings.windDownSeconds : 0,
            completed: true
        )
        sessionStore.saveSession(record)
    }

    private func cancelSession() {
        notifications.cancelSessionEnd()
        timer.stop()
        audio.stopAll()
        dismiss()
    }

    private func dismissSoon() {
        Task { @MainActor in
            try? await Task.sleep(for: .milliseconds(800))
            dismiss()
        }
    }

    private func playCompletionHaptics() {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(.success)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            generator.notificationOccurred(.success)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            generator.notificationOccurred(.success)
        }
    }
}

private struct MeditationTimerSetupView: View {
    @Bindable var settings: MeditationTimerSettingsStore
    let sessionStore: MeditationSessionStore
    let onStart: () -> Void
    let onClose: () -> Void

    @State private var showSavePreset = false
    @State private var presetName = ""

    var body: some View {
        ZStack {
            Color.hereBackground.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 18) {
                    durationSection
                    soundSection
                    windDownSection
                    presetSection
                    recentSection
                    HereButton(title: "Begin", action: onStart)
                        .padding(.top, 4)
                }
                .padding(24)
            }
        }
        .navigationTitle("Meditation Timer")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button(action: onClose) {
                    Image(systemName: "xmark")
                }
                .foregroundStyle(Color.hereSage)
                .accessibilityLabel("Close")
            }
        }
        .alert("Save Preset", isPresented: $showSavePreset) {
            TextField("Name", text: $presetName)
            Button("Save") {
                settings.saveCurrentPreset(named: presetName)
                presetName = ""
            }
            Button("Cancel", role: .cancel) {
                presetName = ""
            }
        }
    }

    private var durationSection: some View {
        HereCard {
            VStack(spacing: 18) {
                Text("Duration")
                    .font(.hereLabel)
                    .foregroundStyle(Color.hereMuted)
                    .frame(maxWidth: .infinity, alignment: .leading)

                HStack(spacing: 24) {
                    iconButton("minus") {
                        adjustDuration(delta: -5)
                    }

                    VStack(spacing: 4) {
                        Text("\(settings.selectedDurationMinutes)")
                            .font(.system(size: 64, weight: .semibold, design: .rounded))
                            .monospacedDigit()
                            .foregroundStyle(Color.hereSage)
                        Text("minutes")
                            .font(.hereCaption)
                            .foregroundStyle(Color.hereMuted)
                    }
                    .frame(minWidth: 140)

                    iconButton("plus") {
                        adjustDuration(delta: 5)
                    }
                }

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach([3, 5, 10, 15, 20, 30, 45, 60], id: \.self) { minutes in
                            Button {
                                settings.setDurationMinutes(minutes)
                            } label: {
                                Text("\(minutes)")
                                    .font(.hereCaption)
                                    .foregroundStyle(settings.selectedDurationMinutes == minutes ? Color.hereForeground : Color.hereMuted)
                                    .frame(width: 38, height: 32)
                                    .background(settings.selectedDurationMinutes == minutes ? Color.hereSageLight : Color.hereSurface)
                                    .clipShape(Capsule())
                                    .overlay(Capsule().stroke(Color.hereBorder, lineWidth: 1))
                            }
                        }
                    }
                }
            }
            .padding(18)
        }
    }

    private var soundSection: some View {
        HereCard {
            VStack(alignment: .leading, spacing: 16) {
                Text("Sound")
                    .font(.hereLabel)
                    .foregroundStyle(Color.hereMuted)

                VStack(spacing: 0) {
                    ForEach(MeditationAudioController.availableBackgroundSounds, id: \.self) { sound in
                        selectionRow(
                            title: sound,
                            isSelected: settings.selectedBackgroundSound == sound,
                            systemImage: sound == "Silence" ? "speaker.slash" : "waveform",
                            action: { settings.setBackgroundSound(sound) }
                        )
                    }
                }

                Divider()

                Text("End Sound")
                    .font(.hereLabel)
                    .foregroundStyle(Color.hereMuted)

                HStack(spacing: 8) {
                    ForEach(MeditationAudioController.availableEndSounds, id: \.self) { sound in
                        Button {
                            settings.setEndSound(sound)
                        } label: {
                            Text(sound)
                                .font(.hereCaption)
                                .foregroundStyle(settings.selectedEndSound == sound ? Color.hereForeground : Color.hereMuted)
                                .padding(.horizontal, 12)
                                .frame(height: 34)
                                .background(settings.selectedEndSound == sound ? Color.hereSageLight : Color.hereSurface)
                                .clipShape(Capsule())
                                .overlay(Capsule().stroke(Color.hereBorder, lineWidth: 1))
                        }
                    }
                }

                HStack {
                    Text("Volume")
                        .font(.hereCallout)
                        .foregroundStyle(Color.hereForeground)
                    Slider(
                        value: Binding(
                            get: { settings.volume },
                            set: { settings.setVolume($0) }
                        ),
                        in: 0...1
                    )
                    .tint(Color.hereSage)
                }
            }
            .padding(18)
        }
    }

    private var windDownSection: some View {
        HereCard {
            VStack(alignment: .leading, spacing: 14) {
                Toggle(
                    isOn: Binding(
                        get: { settings.windDownEnabled },
                        set: { settings.setWindDownEnabled($0) }
                    )
                ) {
                    Text("Wind-down")
                        .font(.hereHeadline)
                        .foregroundStyle(Color.hereForeground)
                }
                .tint(Color.hereSage)

                if settings.windDownEnabled {
                    HStack(spacing: 8) {
                        ForEach([60, 120, 180], id: \.self) { seconds in
                            Button {
                                settings.setWindDownSeconds(seconds)
                            } label: {
                                Text("\(seconds / 60) min")
                                    .font(.hereCaption)
                                    .foregroundStyle(settings.windDownSeconds == seconds ? Color.hereForeground : Color.hereMuted)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 36)
                                    .background(settings.windDownSeconds == seconds ? Color.hereSageLight : Color.hereSurface)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.hereBorder, lineWidth: 1))
                            }
                        }
                    }
                }
            }
            .padding(18)
        }
    }

    private var presetSection: some View {
        HereCard {
            VStack(alignment: .leading, spacing: 14) {
                HStack {
                    Text("Presets")
                        .font(.hereLabel)
                        .foregroundStyle(Color.hereMuted)
                    Spacer()
                    Button {
                        showSavePreset = true
                    } label: {
                        Image(systemName: "plus.circle")
                            .font(.system(size: 22))
                            .foregroundStyle(Color.hereSage)
                    }
                    .disabled(settings.presets.count >= 8)
                    .accessibilityLabel("Save preset")
                }

                if settings.presets.isEmpty {
                    Text("No saved presets")
                        .font(.hereCallout)
                        .foregroundStyle(Color.hereMuted)
                } else {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(settings.presets) { preset in
                                Button {
                                    settings.applyPreset(preset)
                                } label: {
                                    Text(preset.name)
                                        .font(.hereCaption)
                                        .foregroundStyle(Color.hereSage)
                                        .padding(.horizontal, 12)
                                        .frame(height: 34)
                                        .background(Color.hereSageLight)
                                        .clipShape(Capsule())
                                }
                                .contextMenu {
                                    Button(role: .destructive) {
                                        settings.deletePreset(id: preset.id)
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .padding(18)
        }
    }

    private var recentSection: some View {
        HereCard {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Local Sessions")
                        .font(.hereLabel)
                        .foregroundStyle(Color.hereMuted)
                    Text("\(sessionStore.completedSessionCount)")
                        .font(.hereTitle)
                        .foregroundStyle(Color.hereForeground)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Minutes")
                        .font(.hereLabel)
                        .foregroundStyle(Color.hereMuted)
                    Text("\(sessionStore.totalCompletedMinutes)")
                        .font(.hereTitle)
                        .foregroundStyle(Color.hereForeground)
                }
            }
            .padding(18)
        }
    }

    private func adjustDuration(delta: Int) {
        settings.setDurationMinutes(settings.selectedDurationMinutes + delta)
    }

    private func iconButton(_ systemImage: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(Color.hereSage)
                .frame(width: 44, height: 44)
                .background(Color.hereSurface)
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.hereBorder, lineWidth: 1))
        }
    }

    private func selectionRow(
        title: String,
        isSelected: Bool,
        systemImage: String,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: systemImage)
                    .frame(width: 24)
                    .foregroundStyle(isSelected ? Color.hereSage : Color.hereMuted)
                Text(title)
                    .font(.hereCallout)
                    .foregroundStyle(Color.hereForeground)
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(Color.hereSage)
                }
            }
            .padding(.vertical, 10)
        }
        .buttonStyle(.plain)
    }
}

private struct MeditationCountdownView: View {
    let timer: MeditationTimerModel

    var body: some View {
        ZStack {
            Color.hereBackground.ignoresSafeArea()

            VStack(spacing: 12) {
                Text("\(timer.countdownValue)")
                    .font(.system(size: 96, weight: .semibold, design: .rounded))
                    .monospacedDigit()
                    .foregroundStyle(Color.hereSage)
                Text("Begin")
                    .font(.hereLabel)
                    .foregroundStyle(Color.hereMuted)
            }
        }
    }
}

private struct MeditationActiveTimerView: View {
    let timer: MeditationTimerModel
    let onTogglePause: () -> Void
    let onExit: () -> Void

    @State private var breathScale = 0.86

    var body: some View {
        ZStack {
            Color.hereBackground.ignoresSafeArea()

            Button(action: onTogglePause) {
                VStack(spacing: 28) {
                    Spacer()

                    ZStack {
                        Circle()
                            .stroke(Color.hereBorder, lineWidth: 12)
                            .frame(width: 260, height: 260)
                        Circle()
                            .trim(from: 0, to: timer.progress)
                            .stroke(Color.hereSage, style: StrokeStyle(lineWidth: 12, lineCap: .round))
                            .rotationEffect(.degrees(-90))
                            .frame(width: 260, height: 260)

                        VStack(spacing: 8) {
                            Text(MeditationTimerModel.formatTime(timer.timeRemainingSeconds))
                                .font(.system(size: 58, weight: .semibold, design: .rounded))
                                .monospacedDigit()
                                .foregroundStyle(Color.hereForeground)
                            Text(timer.state == .paused ? "Paused" : "Sitting")
                                .font(.hereLabel)
                                .foregroundStyle(Color.hereMuted)
                        }
                    }

                    ZStack {
                        Circle()
                            .fill(Color.hereSageLight)
                            .frame(width: 74, height: 74)
                            .scaleEffect(timer.state == .paused ? 1 : breathScale)
                        Image(systemName: timer.state == .paused ? "pause.fill" : "wind")
                            .font(.system(size: 22))
                            .foregroundStyle(Color.hereSage)
                    }
                    .animation(
                        timer.state == .paused ? .default : .easeInOut(duration: 4).repeatForever(autoreverses: true),
                        value: breathScale
                    )

                    Text(timer.state == .paused ? "Tap to resume" : "Tap to pause")
                        .font(.hereCaption)
                        .foregroundStyle(Color.hereMuted)

                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel(timer.state == .paused ? "Resume meditation timer" : "Pause meditation timer")
            .accessibilityValue(MeditationTimerModel.formatTime(timer.timeRemainingSeconds))
            .onAppear {
                breathScale = 1.22
            }

            VStack {
                HStack {
                    Spacer()
                    Button(action: onExit) {
                        Image(systemName: "xmark")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundStyle(Color.hereMuted)
                            .frame(width: 44, height: 44)
                    }
                    .accessibilityLabel("End session")
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)
                Spacer()
            }
        }
    }
}

private struct MeditationWindDownView: View {
    let timer: MeditationTimerModel
    let onSkip: () -> Void

    var body: some View {
        ZStack {
            Color.hereBackground.ignoresSafeArea()

            VStack(spacing: 22) {
                Spacer()
                Image(systemName: "leaf")
                    .font(.system(size: 48))
                    .foregroundStyle(Color.hereSage)
                Text(MeditationTimerModel.formatTime(timer.windDownRemainingSeconds))
                    .font(.system(size: 58, weight: .semibold, design: .rounded))
                    .monospacedDigit()
                    .foregroundStyle(Color.hereForeground)
                Text("Wind-down")
                    .font(.hereLabel)
                    .foregroundStyle(Color.hereMuted)
                Spacer()
                Button(action: onSkip) {
                    Text("Done")
                        .font(.hereHeadline)
                        .foregroundStyle(Color.hereSage)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                }
                .padding(.horizontal, 28)
                .padding(.bottom, 28)
            }
        }
    }
}

private struct MeditationCompletionView: View {
    var body: some View {
        ZStack {
            Color.hereBackground.ignoresSafeArea()
            VStack(spacing: 12) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 58))
                    .foregroundStyle(Color.hereSage)
                Text("Complete")
                    .font(.hereTitle)
                    .foregroundStyle(Color.hereForeground)
            }
        }
    }
}

#Preview {
    MeditationTimerFlowView(
        settings: MeditationTimerSettingsStore(),
        sessionStore: MeditationSessionStore()
    )
}

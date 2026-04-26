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
            Color.powBackground.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 18) {
                    durationSection
                    soundSection
                    windDownSection
                    presetSection
                    recentSection
                    POWButton(title: "Begin", action: onStart)
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
                .foregroundStyle(Color.powSage)
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
        POWCard {
            VStack(spacing: 18) {
                Text("Duration")
                    .font(.powLabel)
                    .foregroundStyle(Color.powMuted)
                    .frame(maxWidth: .infinity, alignment: .leading)

                HStack(spacing: 24) {
                    iconButton("minus") {
                        adjustDuration(delta: -5)
                    }

                    VStack(spacing: 4) {
                        Text("\(settings.selectedDurationMinutes)")
                            .font(.system(size: 64, weight: .semibold, design: .rounded))
                            .monospacedDigit()
                            .foregroundStyle(Color.powSage)
                        Text("minutes")
                            .font(.powCaption)
                            .foregroundStyle(Color.powMuted)
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
                                    .font(.powCaption)
                                    .foregroundStyle(settings.selectedDurationMinutes == minutes ? Color.powForeground : Color.powMuted)
                                    .frame(width: 38, height: 32)
                                    .background(settings.selectedDurationMinutes == minutes ? Color.powSageLight : Color.powSurface)
                                    .clipShape(Capsule())
                                    .overlay(Capsule().stroke(Color.powBorder, lineWidth: 1))
                            }
                        }
                    }
                }
            }
            .padding(18)
        }
    }

    private var soundSection: some View {
        POWCard {
            VStack(alignment: .leading, spacing: 16) {
                Text("Sound")
                    .font(.powLabel)
                    .foregroundStyle(Color.powMuted)

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
                    .font(.powLabel)
                    .foregroundStyle(Color.powMuted)

                HStack(spacing: 8) {
                    ForEach(MeditationAudioController.availableEndSounds, id: \.self) { sound in
                        Button {
                            settings.setEndSound(sound)
                        } label: {
                            Text(sound)
                                .font(.powCaption)
                                .foregroundStyle(settings.selectedEndSound == sound ? Color.powForeground : Color.powMuted)
                                .padding(.horizontal, 12)
                                .frame(height: 34)
                                .background(settings.selectedEndSound == sound ? Color.powSageLight : Color.powSurface)
                                .clipShape(Capsule())
                                .overlay(Capsule().stroke(Color.powBorder, lineWidth: 1))
                        }
                    }
                }

                HStack {
                    Text("Volume")
                        .font(.powCallout)
                        .foregroundStyle(Color.powForeground)
                    Slider(
                        value: Binding(
                            get: { settings.volume },
                            set: { settings.setVolume($0) }
                        ),
                        in: 0...1
                    )
                    .tint(Color.powSage)
                }
            }
            .padding(18)
        }
    }

    private var windDownSection: some View {
        POWCard {
            VStack(alignment: .leading, spacing: 14) {
                Toggle(
                    isOn: Binding(
                        get: { settings.windDownEnabled },
                        set: { settings.setWindDownEnabled($0) }
                    )
                ) {
                    Text("Wind-down")
                        .font(.powHeadline)
                        .foregroundStyle(Color.powForeground)
                }
                .tint(Color.powSage)

                if settings.windDownEnabled {
                    HStack(spacing: 8) {
                        ForEach([60, 120, 180], id: \.self) { seconds in
                            Button {
                                settings.setWindDownSeconds(seconds)
                            } label: {
                                Text("\(seconds / 60) min")
                                    .font(.powCaption)
                                    .foregroundStyle(settings.windDownSeconds == seconds ? Color.powForeground : Color.powMuted)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 36)
                                    .background(settings.windDownSeconds == seconds ? Color.powSageLight : Color.powSurface)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.powBorder, lineWidth: 1))
                            }
                        }
                    }
                }
            }
            .padding(18)
        }
    }

    private var presetSection: some View {
        POWCard {
            VStack(alignment: .leading, spacing: 14) {
                HStack {
                    Text("Presets")
                        .font(.powLabel)
                        .foregroundStyle(Color.powMuted)
                    Spacer()
                    Button {
                        showSavePreset = true
                    } label: {
                        Image(systemName: "plus.circle")
                            .font(.system(size: 22))
                            .foregroundStyle(Color.powSage)
                    }
                    .disabled(settings.presets.count >= 8)
                    .accessibilityLabel("Save preset")
                }

                if settings.presets.isEmpty {
                    Text("No saved presets")
                        .font(.powCallout)
                        .foregroundStyle(Color.powMuted)
                } else {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(settings.presets) { preset in
                                Button {
                                    settings.applyPreset(preset)
                                } label: {
                                    Text(preset.name)
                                        .font(.powCaption)
                                        .foregroundStyle(Color.powSage)
                                        .padding(.horizontal, 12)
                                        .frame(height: 34)
                                        .background(Color.powSageLight)
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
        POWCard {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Local Sessions")
                        .font(.powLabel)
                        .foregroundStyle(Color.powMuted)
                    Text("\(sessionStore.completedSessionCount)")
                        .font(.powTitle)
                        .foregroundStyle(Color.powForeground)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Minutes")
                        .font(.powLabel)
                        .foregroundStyle(Color.powMuted)
                    Text("\(sessionStore.totalCompletedMinutes)")
                        .font(.powTitle)
                        .foregroundStyle(Color.powForeground)
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
                .foregroundStyle(Color.powSage)
                .frame(width: 44, height: 44)
                .background(Color.powSurface)
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.powBorder, lineWidth: 1))
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
                    .foregroundStyle(isSelected ? Color.powSage : Color.powMuted)
                Text(title)
                    .font(.powCallout)
                    .foregroundStyle(Color.powForeground)
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(Color.powSage)
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
            Color.powBackground.ignoresSafeArea()

            VStack(spacing: 12) {
                Text("\(timer.countdownValue)")
                    .font(.system(size: 96, weight: .semibold, design: .rounded))
                    .monospacedDigit()
                    .foregroundStyle(Color.powSage)
                Text("Begin")
                    .font(.powLabel)
                    .foregroundStyle(Color.powMuted)
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
            Color.powBackground.ignoresSafeArea()

            Button(action: onTogglePause) {
                VStack(spacing: 28) {
                    Spacer()

                    ZStack {
                        Circle()
                            .stroke(Color.powBorder, lineWidth: 12)
                            .frame(width: 260, height: 260)
                        Circle()
                            .trim(from: 0, to: timer.progress)
                            .stroke(Color.powSage, style: StrokeStyle(lineWidth: 12, lineCap: .round))
                            .rotationEffect(.degrees(-90))
                            .frame(width: 260, height: 260)

                        VStack(spacing: 8) {
                            Text(MeditationTimerModel.formatTime(timer.timeRemainingSeconds))
                                .font(.system(size: 58, weight: .semibold, design: .rounded))
                                .monospacedDigit()
                                .foregroundStyle(Color.powForeground)
                            Text(timer.state == .paused ? "Paused" : "Sitting")
                                .font(.powLabel)
                                .foregroundStyle(Color.powMuted)
                        }
                    }

                    ZStack {
                        Circle()
                            .fill(Color.powSageLight)
                            .frame(width: 74, height: 74)
                            .scaleEffect(timer.state == .paused ? 1 : breathScale)
                        Image(systemName: timer.state == .paused ? "pause.fill" : "wind")
                            .font(.system(size: 22))
                            .foregroundStyle(Color.powSage)
                    }
                    .animation(
                        timer.state == .paused ? .default : .easeInOut(duration: 4).repeatForever(autoreverses: true),
                        value: breathScale
                    )

                    Text(timer.state == .paused ? "Tap to resume" : "Tap to pause")
                        .font(.powCaption)
                        .foregroundStyle(Color.powMuted)

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
                            .foregroundStyle(Color.powMuted)
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
            Color.powBackground.ignoresSafeArea()

            VStack(spacing: 22) {
                Spacer()
                Image(systemName: "leaf")
                    .font(.system(size: 48))
                    .foregroundStyle(Color.powSage)
                Text(MeditationTimerModel.formatTime(timer.windDownRemainingSeconds))
                    .font(.system(size: 58, weight: .semibold, design: .rounded))
                    .monospacedDigit()
                    .foregroundStyle(Color.powForeground)
                Text("Wind-down")
                    .font(.powLabel)
                    .foregroundStyle(Color.powMuted)
                Spacer()
                Button(action: onSkip) {
                    Text("Done")
                        .font(.powHeadline)
                        .foregroundStyle(Color.powSage)
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
            Color.powBackground.ignoresSafeArea()
            VStack(spacing: 12) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 58))
                    .foregroundStyle(Color.powSage)
                Text("Complete")
                    .font(.powTitle)
                    .foregroundStyle(Color.powForeground)
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

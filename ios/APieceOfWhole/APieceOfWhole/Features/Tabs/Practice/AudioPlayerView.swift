import SwiftUI
import AVFoundation

@Observable
@MainActor
final class AudioPlayerModel {
    var isPlaying = false
    var progress: Double = 0
    var duration: Double = 0
    var isLoading = false
    var error: String?

    private var player: AVPlayer?
    private var timeObserver: Any?

    func load(url: URL) {
        isLoading = true
        let item = AVPlayerItem(url: url)
        player = AVPlayer(playerItem: item)

        Task {
            do {
                let asset = AVURLAsset(url: url)
                let durationValue = try await asset.load(.duration)
                self.duration = durationValue.seconds
            } catch {
                self.error = "Could not load audio"
            }
            isLoading = false
        }

        timeObserver = player?.addPeriodicTimeObserver(
            forInterval: CMTime(seconds: 0.5, preferredTimescale: 600),
            queue: .main
        ) { [weak self] time in
            Task { @MainActor in
                guard let self, let player = self.player else { return }
                let current = time.seconds
                let total = player.currentItem?.duration.seconds ?? 1
                if total.isFinite && total > 0 {
                    self.progress = current / total
                    if current >= total - 0.1 {
                        self.isPlaying = false
                        self.progress = 0
                        player.seek(to: .zero)
                    }
                }
            }
        }
    }

    func togglePlayPause() {
        guard let player else { return }
        if isPlaying {
            player.pause()
        } else {
            player.play()
        }
        isPlaying.toggle()
    }

    func seek(to fraction: Double) {
        guard let player, duration > 0 else { return }
        let targetTime = CMTime(seconds: fraction * duration, preferredTimescale: 600)
        player.seek(to: targetTime)
        progress = fraction
    }

    func stop() {
        if let observer = timeObserver {
            player?.removeTimeObserver(observer)
        }
        player?.pause()
        player = nil
        timeObserver = nil
        isPlaying = false
        progress = 0
    }
}

struct AudioPlayerView: View {
    let audioURL: URL
    @State private var model = AudioPlayerModel()

    var body: some View {
        POWCard {
            VStack(spacing: 16) {
                HStack(spacing: 16) {
                    Button {
                        model.togglePlayPause()
                    } label: {
                        ZStack {
                            Circle()
                                .fill(Color.powSage)
                                .frame(width: 52, height: 52)
                            if model.isLoading {
                                ProgressView().tint(.white)
                            } else {
                                Image(systemName: model.isPlaying ? "pause.fill" : "play.fill")
                                    .font(.system(size: 20))
                                    .foregroundStyle(Color.white)
                            }
                        }
                    }
                    .disabled(model.isLoading)

                    VStack(alignment: .leading, spacing: 4) {
                        Slider(value: Binding(
                            get: { model.progress },
                            set: { model.seek(to: $0) }
                        ))
                        .tint(Color.powSage)

                        HStack {
                            Text(formatTime(model.progress * model.duration))
                                .font(.powCaption)
                                .foregroundStyle(Color.powMuted)
                            Spacer()
                            Text(formatTime(model.duration))
                                .font(.powCaption)
                                .foregroundStyle(Color.powMuted)
                        }
                    }
                }

                if let error = model.error {
                    Text(error)
                        .font(.powCaption)
                        .foregroundStyle(Color.powError)
                }
            }
            .padding(16)
        }
        .onAppear {
            model.load(url: audioURL)
        }
        .onDisappear { model.stop() }
    }

    private func formatTime(_ seconds: Double) -> String {
        guard seconds.isFinite && seconds >= 0 else { return "0:00" }
        let mins = Int(seconds) / 60
        let secs = Int(seconds) % 60
        return "\(mins):\(String(format: "%02d", secs))"
    }
}

import SwiftUI

struct PracticeDetailView: View {
    let practice: Practice
    @State private var isSaved = false

    var body: some View {
        ZStack {
            Color.powBackground.ignoresSafeArea()
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(practice.title)
                            .font(.powTitle2)
                            .foregroundStyle(Color.powForeground)

                        if let subtitle = practice.subtitle {
                            Text(subtitle)
                                .font(.powBody)
                                .foregroundStyle(Color.powMuted)
                        }

                        HStack(spacing: 16) {
                            if let duration = practice.durationMinutes {
                                Label("\(duration) min", systemImage: "clock")
                                    .font(.powCallout)
                                    .foregroundStyle(Color.powMuted)
                            }
                            if let layer = practice.layerValues.first {
                                Label(layerLabel(layer), systemImage: "circle.hexagongrid")
                                    .font(.powCallout)
                                    .foregroundStyle(Color.powMuted)
                            }
                        }

                        VStack(alignment: .leading, spacing: 8) {
                            if let sourceKind = practice.sourceKind {
                                metadataPill(sourceKindLabel(sourceKind))
                            }
                            if let evidence = practice.evidenceLevel {
                                metadataPill("Evidence: \(evidenceLabel(evidence))")
                            }
                            if let risk = practice.riskLevel {
                                metadataPill("Risk: \(riskLabel(risk))")
                            }
                        }
                    }

                    if let audioURL = resolvedAudioURL {
                        AudioPlayerView(audioURL: audioURL)
                    }

                    if let body = practice.bodyText {
                        Divider()
                        Text(body)
                            .font(.powBody)
                            .foregroundStyle(Color.powForeground)
                    }

                    if let riskNote = practice.riskNote {
                        POWCard {
                            Text(riskNote)
                                .font(.powCallout)
                                .foregroundStyle(Color.powMuted)
                                .padding(16)
                        }
                    }
                }
                .padding(24)
            }
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    isSaved.toggle()
                    UserDefaults.standard.set(isSaved, forKey: "saved_practice_\(practice.id)")
                } label: {
                    Image(systemName: isSaved ? "bookmark.fill" : "bookmark")
                        .foregroundStyle(Color.powSage)
                }
            }
        }
        .onAppear {
            isSaved = UserDefaults.standard.bool(forKey: "saved_practice_\(practice.id)")
        }
    }

    private var resolvedAudioURL: URL? {
        guard let audioPath = practice.audioPath else { return nil }
        switch practice.audioSource {
        case "ios_bundle":
            return bundledAudioURL(path: audioPath)
        case "remote_url":
            return URL(string: audioPath)
        default:
            return URL(string: audioPath)
        }
    }

    private func bundledAudioURL(path: String) -> URL? {
        let nsPath = path as NSString
        let directory = nsPath.deletingLastPathComponent
        let filename = nsPath.lastPathComponent as NSString
        let name = filename.deletingPathExtension
        let ext = filename.pathExtension
        let subdirectory = directory.isEmpty || directory == "." ? "Audio" : "Audio/\(directory)"
        return Bundle.main.url(
            forResource: name,
            withExtension: ext.isEmpty ? nil : ext,
            subdirectory: subdirectory
        )
    }

    private func metadataPill(_ text: String) -> some View {
        Text(text)
            .font(.powCaption)
            .foregroundStyle(Color.powMuted)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(Color.powSurface)
            .clipShape(Capsule())
            .overlay(Capsule().stroke(Color.powBorder, lineWidth: 1))
    }

    private func sourceKindLabel(_ sourceKind: String) -> String {
        switch sourceKind {
        case "meditation_technique": return "Technique"
        case "audio_library": return practice.audioSource == "ios_bundle" ? "Bundled audio" : "Audio"
        case "legacy_curriculum": return "Curriculum"
        default: return sourceKind.replacingOccurrences(of: "_", with: " ").capitalized
        }
    }

    private func evidenceLabel(_ evidence: String) -> String {
        evidence.replacingOccurrences(of: "_", with: " ").capitalized
    }

    private func riskLabel(_ risk: String) -> String {
        risk.replacingOccurrences(of: "_", with: " ").capitalized
    }

    private func layerLabel(_ layer: String) -> String {
        switch layer {
        case "self_regulation": return "Self-Regulation"
        case "co_regulation": return "Co-Regulation"
        case "community": return "Community"
        case "agency": return "Agency"
        case "civic_engagement": return "Civic Engagement"
        default: return layer
        }
    }
}

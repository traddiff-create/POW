import SwiftUI

struct PracticeLibraryView: View {
    @State private var practices: [Practice] = []
    @State private var selectedLayer: String? = nil
    @State private var isLoading = true
    @State private var error: String?
    @State private var meditationSessionStore = MeditationSessionStore()
    @State private var meditationSettings = MeditationTimerSettingsStore()
    @State private var showMeditationTimer = false

    private let layers = ["self_regulation", "co_regulation", "community", "agency", "civic_engagement"]
    private let layerLabels: [String: String] = [
        "self_regulation": "Self-Regulation",
        "co_regulation": "Co-Regulation",
        "community": "Community",
        "agency": "Agency",
        "civic_engagement": "Civic Engagement"
    ]

    var filtered: [Practice] {
        guard let layer = selectedLayer else { return practices }
        return practices.filter { $0.layerValues.contains(layer) }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.hereBackground.ignoresSafeArea()

                VStack(spacing: 0) {
                    layerFilter
                    philosophyIntro
                        .padding(.horizontal, 24)
                        .padding(.bottom, 8)
                    MeditationTimerCard(
                        sessionStore: meditationSessionStore,
                        settings: meditationSettings
                    ) {
                        showMeditationTimer = true
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 8)
                    if isLoading {
                        ProgressView().padding(.top, 48)
                        Spacer()
                    } else if let error {
                        errorView(error)
                    } else if filtered.isEmpty {
                        emptyView
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 16) {
                                ForEach(filtered) { practice in
                                    NavigationLink(destination: PracticeDetailView(practice: practice)) {
                                        PracticeCard(practice: practice)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding(24)
                        }
                    }
                }
            }
            .navigationTitle("Practice")
            .navigationBarTitleDisplayMode(.large)
            .task { await load() }
            .fullScreenCover(isPresented: $showMeditationTimer) {
                MeditationTimerFlowView(
                    settings: meditationSettings,
                    sessionStore: meditationSessionStore
                )
            }
        }
    }

    private var layerFilter: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                filterChip(label: "All", value: nil)
                ForEach(layers, id: \.self) { layer in
                    filterChip(label: layerLabels[layer] ?? layer, value: layer)
                }
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
        }
    }

    private var philosophyIntro: some View {
        HereCard {
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: "circle.hexagongrid")
                    .font(.system(size: 20))
                    .foregroundStyle(Color.hereSage)
                    .frame(width: 28)

                VStack(alignment: .leading, spacing: 4) {
                    Text("Practice returning")
                        .font(.hereLabel)
                        .foregroundStyle(Color.hereForeground)
                    Text(HerePhilosophy.practiceCopy)
                        .font(.hereCallout)
                        .foregroundStyle(Color.hereMuted)
                }
            }
            .padding(16)
        }
    }

    private func filterChip(label: String, value: String?) -> some View {
        let isSelected = selectedLayer == value
        return Button {
            selectedLayer = value
        } label: {
            Text(label)
                .font(.hereCallout)
                .foregroundStyle(isSelected ? Color.white : Color.hereForeground)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Color.hereSage : Color.hereSurface)
                .clipShape(Capsule())
                .overlay(Capsule().stroke(isSelected ? Color.hereSage : Color.hereBorder, lineWidth: 1))
        }
    }

    private var emptyView: some View {
        VStack(spacing: 12) {
            Image(systemName: "waveform")
                .font(.system(size: 48))
                .foregroundStyle(Color.hereMuted)
            Text("No practices found")
                .font(.hereTitle2)
                .foregroundStyle(Color.hereForeground)
        }
        .padding(48)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func errorView(_ message: String) -> some View {
        VStack(spacing: 16) {
            Text(message)
                .font(.hereBody)
                .foregroundStyle(Color.hereMuted)
                .multilineTextAlignment(.center)
            HereButton(title: "Retry") { Task { await load() } }
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func load() async {
        isLoading = true
        error = nil
        do {
            practices = try await SupabaseService.shared.fetchPractices()
        } catch {
            self.error = AppPublicError.message(for: error, context: .practice)
        }
        isLoading = false
    }
}

struct PracticeCard: View {
    let practice: Practice

    var body: some View {
        HereCard {
            HStack(spacing: 16) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.hereSage.opacity(0.12))
                        .frame(width: 56, height: 56)
                    Image(systemName: practice.iconName ?? (practice.audioPath != nil ? "waveform" : "text.alignleft"))
                        .font(.system(size: 24))
                        .foregroundStyle(Color.hereSage)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(practice.title)
                        .font(.hereBody)
                        .foregroundStyle(Color.hereForeground)
                        .lineLimit(2)

                    if let subtitle = practice.subtitle {
                        Text(subtitle)
                            .font(.hereCaption)
                            .foregroundStyle(Color.hereMuted)
                            .lineLimit(1)
                    }

                    HStack(spacing: 8) {
                        if let duration = practice.durationMinutes {
                            Label("\(duration) min", systemImage: "clock")
                        }
                        if practice.hasAudio {
                            Label("Audio", systemImage: "waveform")
                        }
                    }
                    .font(.hereCaption)
                    .foregroundStyle(Color.hereMuted)

                    VStack(alignment: .leading, spacing: 4) {
                        if let sourceKind = practice.sourceKind {
                            Text(sourceKindLabel(sourceKind))
                        }
                        if let evidence = practice.evidenceLevel {
                            Text("Evidence: \(evidenceLabel(evidence))")
                        }
                        if let risk = practice.riskLevel {
                            Text("Risk: \(riskLabel(risk))")
                        }
                    }
                    .font(.hereCaption)
                    .foregroundStyle(Color.hereMuted)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.hereCaption)
                    .foregroundStyle(Color.hereMuted)
            }
            .padding(16)
        }
    }

    private func sourceKindLabel(_ sourceKind: String) -> String {
        switch sourceKind {
        case "meditation_technique": return "Technique"
        case "audio_library": return "Audio"
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
}

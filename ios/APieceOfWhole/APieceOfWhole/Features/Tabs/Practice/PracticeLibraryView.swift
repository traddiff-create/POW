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
                Color.powBackground.ignoresSafeArea()

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
        POWCard {
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: "circle.hexagongrid")
                    .font(.system(size: 20))
                    .foregroundStyle(Color.powSage)
                    .frame(width: 28)

                VStack(alignment: .leading, spacing: 4) {
                    Text("Practice the spiral")
                        .font(.powLabel)
                        .foregroundStyle(Color.powForeground)
                    Text(POWPhilosophy.practiceCopy)
                        .font(.powCallout)
                        .foregroundStyle(Color.powMuted)
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
                .font(.powCallout)
                .foregroundStyle(isSelected ? Color.white : Color.powForeground)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Color.powSage : Color.powSurface)
                .clipShape(Capsule())
                .overlay(Capsule().stroke(isSelected ? Color.powSage : Color.powBorder, lineWidth: 1))
        }
    }

    private var emptyView: some View {
        VStack(spacing: 12) {
            Image(systemName: "waveform")
                .font(.system(size: 48))
                .foregroundStyle(Color.powMuted)
            Text("No practices found")
                .font(.powTitle2)
                .foregroundStyle(Color.powForeground)
        }
        .padding(48)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func errorView(_ message: String) -> some View {
        VStack(spacing: 16) {
            Text(message)
                .font(.powBody)
                .foregroundStyle(Color.powMuted)
                .multilineTextAlignment(.center)
            POWButton(title: "Retry") { Task { await load() } }
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
        POWCard {
            HStack(spacing: 16) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.powSage.opacity(0.12))
                        .frame(width: 56, height: 56)
                    Image(systemName: practice.iconName ?? (practice.audioPath != nil ? "waveform" : "text.alignleft"))
                        .font(.system(size: 24))
                        .foregroundStyle(Color.powSage)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(practice.title)
                        .font(.powBody)
                        .foregroundStyle(Color.powForeground)
                        .lineLimit(2)

                    if let subtitle = practice.subtitle {
                        Text(subtitle)
                            .font(.powCaption)
                            .foregroundStyle(Color.powMuted)
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
                    .font(.powCaption)
                    .foregroundStyle(Color.powMuted)

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
                    .font(.powCaption)
                    .foregroundStyle(Color.powMuted)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.powCaption)
                    .foregroundStyle(Color.powMuted)
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

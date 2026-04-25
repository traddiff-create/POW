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

                        HStack(spacing: 16) {
                            if let duration = practice.durationMinutes {
                                Label("\(duration) min", systemImage: "clock")
                                    .font(.powCallout)
                                    .foregroundStyle(Color.powMuted)
                            }
                            if let category = practice.category {
                                Label(layerLabel(category), systemImage: "circle.hexagongrid")
                                    .font(.powCallout)
                                    .foregroundStyle(Color.powMuted)
                            }
                        }
                    }

                    if let audioPath = practice.audioPath {
                        AudioPlayerView(audioURL: audioPath)
                    }

                    if let body = practice.bodyText {
                        Divider()
                        Text(body)
                            .font(.powBody)
                            .foregroundStyle(Color.powForeground)
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

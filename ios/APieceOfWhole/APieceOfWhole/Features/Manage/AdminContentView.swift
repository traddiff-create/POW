import SwiftUI

struct AdminContentView: View {
    @State private var practices: [Practice] = []
    @State private var civicLessons: [CivicLesson] = []
    @State private var isLoading = true
    @State private var selectedTab = 0

    var body: some View {
        ZStack {
            Color.hereBackground.ignoresSafeArea()
            VStack(spacing: 0) {
                Picker("Type", selection: $selectedTab) {
                    Text("Practices").tag(0)
                    Text("Civic").tag(1)
                }
                .pickerStyle(.segmented)
                .padding(16)

                if isLoading {
                    ProgressView()
                    Spacer()
                } else if selectedTab == 0 {
                    List(practices) { practice in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(practice.title)
                                .font(.hereLabel)
                                .foregroundStyle(Color.hereForeground)
                            HStack {
                                if let week = practice.weekNumber {
                                    Text("Week \(week)")
                                        .font(.hereCaption)
                                        .foregroundStyle(Color.hereMuted)
                                }
                                if let duration = practice.durationMinutes {
                                    Text("• \(duration) min")
                                        .font(.hereCaption)
                                        .foregroundStyle(Color.hereMuted)
                                }
                            }
                        }
                    }
                    .scrollContentBackground(.hidden)
                    .background(Color.hereBackground)
                } else {
                    List(civicLessons) { lesson in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(lesson.title)
                                .font(.hereLabel)
                                .foregroundStyle(Color.hereForeground)
                            if let minutes = lesson.estimatedMinutes {
                                Text("\(minutes) min")
                                    .font(.hereCaption)
                                    .foregroundStyle(Color.hereMuted)
                            }
                        }
                    }
                    .scrollContentBackground(.hidden)
                    .background(Color.hereBackground)
                }
            }
        }
        .navigationTitle("Content Library")
        .navigationBarTitleDisplayMode(.inline)
        .task { await load() }
    }

    private func load() async {
        isLoading = true
        async let p = try? SupabaseService.shared.fetchPractices(publishedOnly: false)
        async let c = try? SupabaseService.shared.fetchCivicLessons()
        practices = (await p) ?? []
        civicLessons = (await c) ?? []
        isLoading = false
    }
}

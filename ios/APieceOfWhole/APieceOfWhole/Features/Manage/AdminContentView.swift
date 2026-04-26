import SwiftUI

struct AdminContentView: View {
    @State private var practices: [Practice] = []
    @State private var civicLessons: [CivicLesson] = []
    @State private var isLoading = true
    @State private var selectedTab = 0

    var body: some View {
        ZStack {
            Color.powBackground.ignoresSafeArea()
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
                                .font(.powLabel)
                                .foregroundStyle(Color.powForeground)
                            HStack {
                                if let week = practice.weekNumber {
                                    Text("Week \(week)")
                                        .font(.powCaption)
                                        .foregroundStyle(Color.powMuted)
                                }
                                if let duration = practice.durationMinutes {
                                    Text("• \(duration) min")
                                        .font(.powCaption)
                                        .foregroundStyle(Color.powMuted)
                                }
                            }
                        }
                    }
                    .scrollContentBackground(.hidden)
                    .background(Color.powBackground)
                } else {
                    List(civicLessons) { lesson in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(lesson.title)
                                .font(.powLabel)
                                .foregroundStyle(Color.powForeground)
                            if let minutes = lesson.estimatedMinutes {
                                Text("\(minutes) min")
                                    .font(.powCaption)
                                    .foregroundStyle(Color.powMuted)
                            }
                        }
                    }
                    .scrollContentBackground(.hidden)
                    .background(Color.powBackground)
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

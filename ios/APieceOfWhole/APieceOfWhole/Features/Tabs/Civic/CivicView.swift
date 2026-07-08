import SwiftUI

struct CivicView: View {
    @State private var lessons: [CivicLesson] = []
    @State private var isLoading = true
    @State private var error: String?

    var body: some View {
        NavigationStack {
            ZStack {
                Color.hereBackground.ignoresSafeArea()

                if isLoading {
                    ProgressView()
                } else if let error {
                    VStack(spacing: 16) {
                        Text(error).font(.hereBody).foregroundStyle(Color.hereMuted)
                        HereButton(title: "Retry") { Task { await load() } }
                    }
                    .padding(24)
                } else {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 20) {
                            introHeader
                            LazyVStack(spacing: 12) {
                                ForEach(lessons) { lesson in
                                    NavigationLink(destination: CivicModuleDetailView(lesson: lesson)) {
                                        CivicLessonCard(lesson: lesson)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                        .padding(24)
                    }
                }
            }
            .navigationTitle("Civic Life")
            .navigationBarTitleDisplayMode(.large)
            .task { await load() }
        }
    }

    private var introHeader: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("From personal to collective")
                .font(.hereTitle2)
                .foregroundStyle(Color.hereForeground)
            Text(HerePhilosophy.civicCopy)
                .font(.hereBody)
                .foregroundStyle(Color.hereMuted)
            Text("Explore how regulation, relationship, and agency connect to local participation and collective change.")
                .font(.hereCallout)
                .foregroundStyle(Color.hereMuted)
        }
    }

    private func load() async {
        isLoading = true
        error = nil
        do {
            lessons = try await SupabaseService.shared.fetchCivicLessons()
        } catch {
            self.error = AppPublicError.message(for: error, context: .civic)
        }
        isLoading = false
    }
}

struct CivicLessonCard: View {
    let lesson: CivicLesson

    var body: some View {
        HereCard {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(Color.hereSageLight)
                        .frame(width: 44, height: 44)
                    Text("\(lesson.orderIndex ?? 1)")
                        .font(.hereLabel)
                        .foregroundStyle(Color.hereSage)
                }
                VStack(alignment: .leading, spacing: 4) {
                    Text(lesson.title)
                        .font(.hereLabel)
                        .foregroundStyle(Color.hereForeground)
                    if let minutes = lesson.estimatedMinutes {
                        Label("\(minutes) min", systemImage: "clock")
                            .font(.hereCaption)
                            .foregroundStyle(Color.hereMuted)
                    }
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.hereCaption)
                    .foregroundStyle(Color.hereMuted)
            }
            .padding(16)
        }
    }
}

struct CivicModuleDetailView: View {
    let lesson: CivicLesson

    var body: some View {
        ZStack {
            Color.hereBackground.ignoresSafeArea()
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    VStack(alignment: .leading, spacing: 8) {
                        if let minutes = lesson.estimatedMinutes {
                            Label("\(minutes) min read", systemImage: "clock")
                                .font(.hereCaption)
                                .foregroundStyle(Color.hereMuted)
                        }
                        Text(lesson.title)
                            .font(.hereTitle)
                            .foregroundStyle(Color.hereForeground)
                    }

                    if let body = lesson.bodyText, !body.isEmpty {
                        Text(body)
                            .font(.hereBody)
                            .foregroundStyle(Color.hereForeground)
                    }

                    if let prompt = lesson.reflectionPrompt, !prompt.isEmpty {
                        HereCard {
                            VStack(alignment: .leading, spacing: 8) {
                                Label("Reflection", systemImage: "bubble.left.and.quote.bubble.right")
                                    .font(.hereCaption)
                                    .foregroundStyle(Color.hereMuted)
                                Text(prompt)
                                    .font(.hereBody)
                                    .foregroundStyle(Color.hereForeground)
                            }
                            .padding(16)
                        }
                    }

                    Text("This app is not a substitute for civic engagement, legal advice, or professional guidance. Take action at the pace that feels grounded and sustainable.")
                        .font(.hereCaption)
                        .foregroundStyle(Color.hereMuted)
                        .multilineTextAlignment(.center)
                        .padding(.top, 8)
                }
                .padding(24)
            }
        }
        .navigationTitle(lesson.title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

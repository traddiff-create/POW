import SwiftUI

struct CivicView: View {
    @State private var lessons: [CivicLesson] = []
    @State private var isLoading = true
    @State private var error: String?

    var body: some View {
        NavigationStack {
            ZStack {
                Color.powBackground.ignoresSafeArea()

                if isLoading {
                    ProgressView()
                } else if let error {
                    VStack(spacing: 16) {
                        Text(error).font(.powBody).foregroundStyle(Color.powMuted)
                        POWButton(title: "Retry") { Task { await load() } }
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
                .font(.powTitle2)
                .foregroundStyle(Color.powForeground)
            Text(POWPhilosophy.civicCopy)
                .font(.powBody)
                .foregroundStyle(Color.powMuted)
            Text("Explore how regulation, relationship, and agency connect to local participation and collective change.")
                .font(.powCallout)
                .foregroundStyle(Color.powMuted)
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
        POWCard {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(Color.powSageLight)
                        .frame(width: 44, height: 44)
                    Text("\(lesson.orderIndex ?? 1)")
                        .font(.powLabel)
                        .foregroundStyle(Color.powSage)
                }
                VStack(alignment: .leading, spacing: 4) {
                    Text(lesson.title)
                        .font(.powLabel)
                        .foregroundStyle(Color.powForeground)
                    if let minutes = lesson.estimatedMinutes {
                        Label("\(minutes) min", systemImage: "clock")
                            .font(.powCaption)
                            .foregroundStyle(Color.powMuted)
                    }
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.powCaption)
                    .foregroundStyle(Color.powMuted)
            }
            .padding(16)
        }
    }
}

struct CivicModuleDetailView: View {
    let lesson: CivicLesson

    var body: some View {
        ZStack {
            Color.powBackground.ignoresSafeArea()
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    VStack(alignment: .leading, spacing: 8) {
                        if let minutes = lesson.estimatedMinutes {
                            Label("\(minutes) min read", systemImage: "clock")
                                .font(.powCaption)
                                .foregroundStyle(Color.powMuted)
                        }
                        Text(lesson.title)
                            .font(.powTitle)
                            .foregroundStyle(Color.powForeground)
                    }

                    if let body = lesson.bodyText, !body.isEmpty {
                        Text(body)
                            .font(.powBody)
                            .foregroundStyle(Color.powForeground)
                    }

                    if let prompt = lesson.reflectionPrompt, !prompt.isEmpty {
                        POWCard {
                            VStack(alignment: .leading, spacing: 8) {
                                Label("Reflection", systemImage: "bubble.left.and.quote.bubble.right")
                                    .font(.powCaption)
                                    .foregroundStyle(Color.powMuted)
                                Text(prompt)
                                    .font(.powBody)
                                    .foregroundStyle(Color.powForeground)
                            }
                            .padding(16)
                        }
                    }

                    Text("This app is not a substitute for civic engagement, legal advice, or professional guidance. Take action at the pace that feels grounded and sustainable.")
                        .font(.powCaption)
                        .foregroundStyle(Color.powMuted)
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

import SwiftUI

struct SelfView: View {
    var body: some View {
        NavigationStack {
            HereLegScrollView(title: "Self") {
                HereHeaderView(
                    leg: .selfFoundation,
                    detail: HerePhilosophy.selfCopy
                )

                DailyPracticePromptCard(prompt: HerePromptCatalog.dailyPrompt(for: .selfFoundation))

                HereCard {
                    VStack(alignment: .leading, spacing: 12) {
                        Label("5-minute practice", systemImage: "paintbrush")
                            .font(.hereLabel)
                            .foregroundStyle(Color.hereMuted)
                        Text("Create for the process, not the outcome")
                            .font(.hereTitle2)
                            .foregroundStyle(Color.hereForeground)
                        Text("Draw, write, hum, move, or make something small for five minutes. The point is not to produce something impressive. The point is to notice what happens when you let the process matter.")
                            .font(.hereBody)
                            .foregroundStyle(Color.hereMuted)
                    }
                    .padding(20)
                }

                VStack(spacing: 12) {
                    HereActionLink(
                        title: "Daily Check-In",
                        detail: "Notice mood, stress, capacity, and what your body is saying.",
                        systemImage: "heart.text.square",
                        destination: TodayView()
                    )

                    HereActionLink(
                        title: "Meditation & Breathwork",
                        detail: "Use audio practices, breath, and the timer to return to regulation.",
                        systemImage: "waveform",
                        destination: PracticeLibraryView()
                    )

                    HereActionLink(
                        title: "Journal",
                        detail: "Keep a private record of what is present and what is changing.",
                        systemImage: "book.closed",
                        destination: JournalListView()
                    )

                    HereActionLink(
                        title: "My Piece",
                        detail: "Name your values, gifts, capacity, boundaries, and next contribution.",
                        systemImage: "puzzlepiece",
                        destination: MyPieceView()
                    )

                    HereActionLink(
                        title: "Why I'm Here",
                        detail: "Revisit the application answers that brought you into this work.",
                        systemImage: "quote.bubble",
                        destination: WhyIHereView()
                    )
                }
            }
            .toolbar { HereToolbarLinks() }
        }
    }
}

struct TogetherView: View {
    var body: some View {
        NavigationStack {
            HereLegScrollView(title: "Together") {
                HereHeaderView(
                    leg: .together,
                    detail: HerePhilosophy.togetherCopy
                )

                DailyPracticePromptCard(prompt: HerePromptCatalog.dailyPrompt(for: .together))

                HereCard {
                    VStack(alignment: .leading, spacing: 12) {
                        Label("Co-regulation", systemImage: "person.2")
                            .font(.hereLabel)
                            .foregroundStyle(Color.hereMuted)
                        Text("A grounding presence is a superpower")
                            .font(.hereTitle2)
                            .foregroundStyle(Color.hereForeground)
                        Text("We are social creatures. Much of communication happens below words: posture, pace, breath, tone, and attention. Practicing steadiness with others can support social ease and bring peace into ordinary moments.")
                            .font(.hereBody)
                            .foregroundStyle(Color.hereMuted)
                    }
                    .padding(20)
                }

                VStack(spacing: 12) {
                    HereActionLink(
                        title: "Ground With Someone",
                        detail: "A short practice for breathing, listening, and settling beside another person.",
                        systemImage: "hands.sparkles",
                        destination: GroundingWithOthersView()
                    )

                    HereActionLink(
                        title: "Circle",
                        detail: "Share carefully, listen generously, and practice connection with your cohort.",
                        systemImage: "person.3",
                        destination: CircleView()
                    )

                    HereActionLink(
                        title: "Learn Together",
                        detail: "Read and listen to ideas about co-regulation, relationship, and shared practice.",
                        systemImage: "text.book.closed",
                        destination: LearnView()
                    )
                }
            }
            .toolbar { HereToolbarLinks() }
        }
    }
}

struct CommunityView: View {
    var body: some View {
        NavigationStack {
            HereLegScrollView(title: "Community") {
                HereHeaderView(
                    leg: .community,
                    detail: HerePhilosophy.communityCopy
                )

                DailyPracticePromptCard(prompt: HerePromptCatalog.dailyPrompt(for: .community))
                LocalIntentionCard()

                VStack(spacing: 12) {
                    HereActionLink(
                        title: "Why We're Here",
                        detail: "Read anonymous, opt-in reflections from people practicing Here.",
                        systemImage: "quote.opening",
                        destination: WhyWereHereView()
                    )

                    HereActionLink(
                        title: "Civic Practice",
                        detail: "Explore local, values-based participation grounded in care.",
                        systemImage: "building.columns",
                        destination: CivicView()
                    )

                    HereActionLink(
                        title: "Learn Community",
                        detail: "Use the library to connect inner practice with neighbors, place, and civic life.",
                        systemImage: "text.book.closed",
                        destination: LearnView()
                    )
                }
            }
            .toolbar { HereToolbarLinks() }
        }
    }
}

private struct HereLegScrollView<Content: View>: View {
    let title: String
    @ViewBuilder var content: Content

    var body: some View {
        ZStack {
            Color.hereBackground.ignoresSafeArea()
            ScrollView {
                VStack(spacing: 18) {
                    content
                }
                .padding(24)
            }
        }
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.large)
    }
}

private struct HereHeaderView: View {
    let leg: HereLeg
    let detail: String

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                Image(systemName: leg.systemImage)
                    .font(.system(size: 24))
                    .foregroundStyle(Color.hereSage)
                    .frame(width: 36, height: 36)
                    .background(Color.hereSageLight)
                    .clipShape(Circle())

                VStack(alignment: .leading, spacing: 2) {
                    Text(leg.subtitle)
                        .font(.hereLabel)
                        .foregroundStyle(Color.hereMuted)
                    Text(leg.title)
                        .font(.hereTitle)
                        .foregroundStyle(Color.hereForeground)
                }
            }

            Text(detail)
                .font(.hereBody)
                .foregroundStyle(Color.hereMuted)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct DailyPracticePromptCard: View {
    let prompt: HerePrompt
    @Environment(AppState.self) private var appState
    @State private var entry: DailyPracticeEntry?
    @State private var reflection = ""
    @State private var isLoading = true
    @State private var isSaving = false
    @State private var error: String?

    var body: some View {
        HereCard {
            VStack(alignment: .leading, spacing: 14) {
                HStack(alignment: .top) {
                    Label("Today's practice", systemImage: prompt.leg.systemImage)
                        .font(.hereLabel)
                        .foregroundStyle(Color.hereMuted)

                    Spacer()

                    if entry != nil {
                        Label("Done", systemImage: "checkmark.circle.fill")
                            .font(.hereCaption)
                            .foregroundStyle(Color.hereSage)
                    }
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text(prompt.title)
                        .font(.hereTitle2)
                        .foregroundStyle(Color.hereForeground)
                    Text(prompt.body)
                        .font(.hereBody)
                        .foregroundStyle(Color.hereMuted)
                }

                HereTextField(
                    label: "Private reflection",
                    text: $reflection,
                    placeholder: prompt.placeholder,
                    axis: .vertical,
                    accessibilityID: "here.prompt.\(prompt.leg.rawValue).reflectionField"
                )

                if let error {
                    Text(error)
                        .font(.hereCaption)
                        .foregroundStyle(Color.hereError)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }

                HereButton(
                    title: entry == nil ? "Mark Today's Practice" : "Update Reflection",
                    isLoading: isSaving
                ) {
                    Task { await save() }
                }
                .disabled(isLoading || isSaving)
                .accessibilityIdentifier("here.prompt.\(prompt.leg.rawValue).saveButton")
            }
            .padding(20)
        }
        .task { await load() }
    }

    private func load() async {
        guard let userID = appState.session?.user.id.uuidString else {
            isLoading = false
            return
        }

        entry = try? await SupabaseService.shared.fetchTodayDailyPracticeEntry(
            userID: userID,
            leg: prompt.leg
        )
        reflection = entry?.privateReflection ?? ""
        isLoading = false
    }

    private func save() async {
        guard let userID = appState.session?.user.id.uuidString else { return }
        isSaving = true
        error = nil

        do {
            let trimmed = reflection.trimmingCharacters(in: .whitespacesAndNewlines)
            let submission = DailyPracticeSubmission(
                userID: userID,
                leg: prompt.leg,
                promptID: prompt.id,
                promptTitle: prompt.title,
                privateReflection: trimmed.isEmpty ? nil : trimmed,
                practiceDate: SupabaseService.practiceDateString()
            )
            entry = try await SupabaseService.shared.saveDailyPracticeEntry(submission)
            reflection = entry?.privateReflection ?? ""
        } catch {
            self.error = AppPublicError.message(for: error, context: .here)
        }

        isSaving = false
    }
}

private struct HereActionLink<Destination: View>: View {
    let title: String
    let detail: String
    let systemImage: String
    let destination: Destination

    var body: some View {
        NavigationLink(destination: destination) {
            HereCard {
                HStack(alignment: .top, spacing: 14) {
                    Image(systemName: systemImage)
                        .font(.system(size: 20))
                        .foregroundStyle(Color.hereSage)
                        .frame(width: 30)

                    VStack(alignment: .leading, spacing: 5) {
                        Text(title)
                            .font(.hereBody)
                            .foregroundStyle(Color.hereForeground)
                        Text(detail)
                            .font(.hereCallout)
                            .foregroundStyle(Color.hereMuted)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(.hereCaption)
                        .foregroundStyle(Color.hereMuted)
                        .padding(.top, 4)
                }
                .padding(16)
            }
        }
        .buttonStyle(.plain)
    }
}

private struct LocalIntentionCard: View {
    var body: some View {
        HereCard {
            VStack(alignment: .leading, spacing: 12) {
                Label("Local invitations", systemImage: "figure.walk")
                    .font(.hereLabel)
                    .foregroundStyle(Color.hereMuted)
                Text("Small actions that accumulate")
                    .font(.hereTitle2)
                    .foregroundStyle(Color.hereForeground)

                VStack(alignment: .leading, spacing: 10) {
                    HereBullet(text: "Take a walk and notice one living thing you usually pass by.")
                    HereBullet(text: "Reach out to a neighbor with one simple, low-pressure offer.")
                    HereBullet(text: "Name gratitude for the land you are on and one intention for how you will live here today.")
                }
            }
            .padding(20)
        }
    }
}

private struct HereBullet: View {
    let text: String

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Circle()
                .fill(Color.hereSage)
                .frame(width: 6, height: 6)
                .padding(.top, 8)
            Text(text)
                .font(.hereCallout)
                .foregroundStyle(Color.hereMuted)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

private struct HereToolbarLinks: ToolbarContent {
    @Environment(AppState.self) private var appState

    var body: some ToolbarContent {
        ToolbarItemGroup(placement: .topBarTrailing) {
            if appState.canAccessManagement {
                NavigationLink(destination: ManageTabView()) {
                    Image(systemName: "slider.horizontal.3")
                }
                .accessibilityLabel("Manage")
            }

            NavigationLink(destination: SettingsView()) {
                Image(systemName: "gear")
            }
            .accessibilityLabel("Settings")
        }
    }
}

struct GroundingWithOthersView: View {
    var body: some View {
        ZStack {
            Color.hereBackground.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Ground With Someone")
                            .font(.hereTitle)
                            .foregroundStyle(Color.hereForeground)
                        Text("A short co-regulation practice for two people or a small group.")
                            .font(.hereBody)
                            .foregroundStyle(Color.hereMuted)
                    }

                    HereCard {
                        VStack(alignment: .leading, spacing: 14) {
                            HereNumberedStep(number: "1", title: "Arrive", detail: "Sit or stand where everyone can be comfortable. Let silence be part of the practice.")
                            HereNumberedStep(number: "2", title: "Slow", detail: "Take three slower breaths. Let your shoulders drop before you speak.")
                            HereNumberedStep(number: "3", title: "Notice", detail: "Name one neutral body sensation or one thing you can see.")
                            HereNumberedStep(number: "4", title: "Listen", detail: "Let each person finish a sentence without fixing, teaching, or rushing.")
                            HereNumberedStep(number: "5", title: "Close", detail: "Thank each other for practicing steadiness.")
                        }
                        .padding(20)
                    }

                    Text("This is a relational practice, not therapy or crisis care. If someone is in danger or crisis, contact emergency support or 988.")
                        .font(.hereCaption)
                        .foregroundStyle(Color.hereMuted)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(24)
            }
        }
        .navigationTitle("Together")
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct HereNumberedStep: View {
    let number: String
    let title: String
    let detail: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Text(number)
                .font(.hereCaption)
                .foregroundStyle(Color.hereForeground)
                .frame(width: 28, height: 28)
                .background(Color.hereSageLight)
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.hereBody)
                    .foregroundStyle(Color.hereForeground)
                Text(detail)
                    .font(.hereCallout)
                    .foregroundStyle(Color.hereMuted)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}

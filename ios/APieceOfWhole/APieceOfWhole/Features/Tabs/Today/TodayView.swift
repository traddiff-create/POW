import SwiftUI

struct TodayView: View {
    @Environment(AppState.self) var appState
    @State private var weekTheme: CurriculumItem?
    @State private var todayPractice: Practice?
    @State private var recentCheckIn: CheckIn?
    @State private var showCheckIn = false
    @State private var isLoading = true

    var body: some View {
        NavigationStack {
            ZStack {
                Color.hereBackground.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        greetingSection
                        checkInSection
                        if let theme = weekTheme { weekThemeCard(theme) }
                        if let practice = todayPractice { practiceCard(practice) }
                        groundingButton
                    }
                    .padding(24)
                }
            }
            .navigationTitle("Today")
            .navigationBarTitleDisplayMode(.large)
            .task { await load() }
            .sheet(isPresented: $showCheckIn) {
                CheckInFormView { await load() }
            }
        }
    }

    private var greetingSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(greeting)
                .font(.hereTitle2)
                .foregroundStyle(Color.hereForeground)
            if let week = appState.activeMembership.flatMap({ _ in currentWeek }) {
                Text("Week \(week) of 8")
                    .font(.hereCallout)
                    .foregroundStyle(Color.hereMuted)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var checkInSection: some View {
        HereCard {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Label("Check In", systemImage: "heart.text.square")
                        .font(.hereLabel)
                        .foregroundStyle(Color.hereForeground)
                    Spacer()
                    if recentCheckIn != nil {
                        Label("Done today", systemImage: "checkmark.circle.fill")
                            .font(.hereCaption)
                            .foregroundStyle(Color.hereSage)
                    }
                }

                if recentCheckIn == nil {
                    Text("How are you arriving today?")
                        .font(.hereBody)
                        .foregroundStyle(Color.hereMuted)
                    HereButton(title: "Begin Check-In") { showCheckIn = true }
                } else {
                    Text("Your check-in is recorded. Come back tomorrow.")
                        .font(.hereBody)
                        .foregroundStyle(Color.hereMuted)
                }
            }
            .padding(20)
        }
    }

    private func weekThemeCard(_ theme: CurriculumItem) -> some View {
        HereCard {
            VStack(alignment: .leading, spacing: 12) {
                Label("This Week's Theme", systemImage: "sparkles")
                    .font(.hereCaption)
                    .foregroundStyle(Color.hereMuted)
                Text(theme.title)
                    .font(.hereTitle2)
                    .foregroundStyle(Color.hereForeground)
                if let description = theme.theme {
                    Text(description)
                        .font(.hereBody)
                        .foregroundStyle(Color.hereMuted)
                        .lineLimit(3)
                }
            }
            .padding(20)
        }
    }

    private func practiceCard(_ practice: Practice) -> some View {
        HereCard {
            VStack(alignment: .leading, spacing: 12) {
                Label("Suggested Practice", systemImage: "waveform")
                    .font(.hereCaption)
                    .foregroundStyle(Color.hereMuted)
                Text(practice.title)
                    .font(.hereTitle2)
                    .foregroundStyle(Color.hereForeground)
                if let duration = practice.durationMinutes {
                    Label("\(duration) min", systemImage: "clock")
                        .font(.hereCallout)
                        .foregroundStyle(Color.hereSage)
                }
                NavigationLink(destination: PracticeDetailView(practice: practice)) {
                    Text("Open Practice")
                        .font(.hereCallout)
                        .foregroundStyle(Color.hereSage)
                }
            }
            .padding(20)
        }
    }

    private var groundingButton: some View {
        VStack(spacing: 8) {
            Text("Need to return to center?")
                .font(.hereCaption)
                .foregroundStyle(Color.hereMuted)
            NavigationLink(destination: GroundingPracticeView()) {
                HStack {
                    Image(systemName: "wind")
                    Text("Return to Regulation")
                }
                .font(.hereCallout)
                .foregroundStyle(Color.hereSage)
            }
        }
        .padding(.top, 8)
    }

    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        let name = appState.profile?.displayName?.components(separatedBy: " ").first ?? "there"
        if hour < 12 { return "Good morning, \(name)" }
        if hour < 17 { return "Good afternoon, \(name)" }
        return "Good evening, \(name)"
    }

    private var currentWeek: Int? {
        guard let membership = appState.activeMembership,
              let enrolled = parseDate(membership.enrolledAt) else { return nil }
        let days = Calendar.current.dateComponents([.day], from: enrolled, to: Date()).day ?? 0
        return min(max(days / 7 + 1, 1), 8)
    }

    private func parseDate(_ string: String) -> Date? {
        let formatter = ISO8601DateFormatter()
        return formatter.date(from: string)
    }

    private func load() async {
        guard let userID = appState.session?.user.id.uuidString else {
            isLoading = false
            return
        }
        async let checkIn = try? SupabaseService.shared.fetchTodayCheckIn(userID: userID)

        if let cohortID = appState.activeMembership?.cohortID {
            let week = currentWeek ?? 1
            async let curriculum = try? SupabaseService.shared.fetchCurrentWeekTheme(cohortID: cohortID, week: week)
            async let practice = try? SupabaseService.shared.fetchSuggestedPractice(cohortID: cohortID, week: week)
            weekTheme = await curriculum
            todayPractice = await practice
        } else {
            weekTheme = nil
            let practices = (try? await SupabaseService.shared.fetchPractices()) ?? []
            todayPractice = practices.first
        }

        recentCheckIn = await checkIn
        isLoading = false
    }
}

struct GroundingPracticeView: View {
    var body: some View {
        ZStack {
            Color.hereBackground.ignoresSafeArea()
            VStack(spacing: 24) {
                Image(systemName: "wind")
                    .font(.system(size: 64))
                    .foregroundStyle(Color.hereSage)
                Text("5-4-3-2-1 Grounding")
                    .font(.hereTitle)
                    .foregroundStyle(Color.hereForeground)
                Text("Name 5 things you can see, 4 you can touch, 3 you can hear, 2 you can smell, 1 you can taste. Breathe slowly between each one.")
                    .font(.hereBody)
                    .foregroundStyle(Color.hereMuted)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 8)
                Text("This app is not therapy or medical care. If you are in crisis, please contact 988.")
                    .font(.hereCaption)
                    .foregroundStyle(Color.hereMuted)
                    .multilineTextAlignment(.center)
            }
            .padding(28)
        }
        .navigationTitle("Return to Regulation")
        .navigationBarTitleDisplayMode(.inline)
    }
}

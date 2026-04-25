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
                Color.powBackground.ignoresSafeArea()

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
                .font(.powTitle2)
                .foregroundStyle(Color.powForeground)
            if let week = appState.activeMembership.flatMap({ _ in currentWeek }) {
                Text("Week \(week) of 8")
                    .font(.powCallout)
                    .foregroundStyle(Color.powMuted)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var checkInSection: some View {
        POWCard {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Label("Check In", systemImage: "heart.text.square")
                        .font(.powLabel)
                        .foregroundStyle(Color.powForeground)
                    Spacer()
                    if recentCheckIn != nil {
                        Label("Done today", systemImage: "checkmark.circle.fill")
                            .font(.powCaption)
                            .foregroundStyle(Color.powSage)
                    }
                }

                if recentCheckIn == nil {
                    Text("How are you arriving today?")
                        .font(.powBody)
                        .foregroundStyle(Color.powMuted)
                    POWButton(title: "Begin Check-In") { showCheckIn = true }
                } else {
                    Text("Your check-in is recorded. Come back tomorrow.")
                        .font(.powBody)
                        .foregroundStyle(Color.powMuted)
                }
            }
            .padding(20)
        }
    }

    private func weekThemeCard(_ theme: CurriculumItem) -> some View {
        POWCard {
            VStack(alignment: .leading, spacing: 12) {
                Label("This Week's Theme", systemImage: "sparkles")
                    .font(.powCaption)
                    .foregroundStyle(Color.powMuted)
                Text(theme.title)
                    .font(.powTitle2)
                    .foregroundStyle(Color.powForeground)
                if let description = theme.theme {
                    Text(description)
                        .font(.powBody)
                        .foregroundStyle(Color.powMuted)
                        .lineLimit(3)
                }
            }
            .padding(20)
        }
    }

    private func practiceCard(_ practice: Practice) -> some View {
        POWCard {
            VStack(alignment: .leading, spacing: 12) {
                Label("Suggested Practice", systemImage: "waveform")
                    .font(.powCaption)
                    .foregroundStyle(Color.powMuted)
                Text(practice.title)
                    .font(.powTitle2)
                    .foregroundStyle(Color.powForeground)
                if let duration = practice.durationMinutes {
                    Label("\(duration) min", systemImage: "clock")
                        .font(.powCallout)
                        .foregroundStyle(Color.powSage)
                }
                NavigationLink(destination: PracticeDetailView(practice: practice)) {
                    Text("Open Practice")
                        .font(.powCallout)
                        .foregroundStyle(Color.powSage)
                }
            }
            .padding(20)
        }
    }

    private var groundingButton: some View {
        VStack(spacing: 8) {
            Text("Need to return to center?")
                .font(.powCaption)
                .foregroundStyle(Color.powMuted)
            NavigationLink(destination: GroundingPracticeView()) {
                HStack {
                    Image(systemName: "wind")
                    Text("Return to Regulation")
                }
                .font(.powCallout)
                .foregroundStyle(Color.powSage)
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
        guard let userID = appState.session?.user.id.uuidString,
              let cohortID = appState.activeMembership?.cohortID else {
            isLoading = false
            return
        }
        let week = currentWeek ?? 1
        async let checkIn = try? SupabaseService.shared.fetchTodayCheckIn(userID: userID)
        async let curriculum = try? SupabaseService.shared.fetchCurrentWeekTheme(cohortID: cohortID, week: week)
        async let practice = try? SupabaseService.shared.fetchSuggestedPractice(cohortID: cohortID, week: week)
        recentCheckIn = await checkIn
        weekTheme = await curriculum
        todayPractice = await practice
        isLoading = false
    }
}

struct GroundingPracticeView: View {
    var body: some View {
        ZStack {
            Color.powBackground.ignoresSafeArea()
            VStack(spacing: 24) {
                Image(systemName: "wind")
                    .font(.system(size: 64))
                    .foregroundStyle(Color.powSage)
                Text("5-4-3-2-1 Grounding")
                    .font(.powTitle)
                    .foregroundStyle(Color.powForeground)
                Text("Name 5 things you can see, 4 you can touch, 3 you can hear, 2 you can smell, 1 you can taste. Breathe slowly between each one.")
                    .font(.powBody)
                    .foregroundStyle(Color.powMuted)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 8)
                Text("This app is not therapy or medical care. If you are in crisis, please contact 988.")
                    .font(.powCaption)
                    .foregroundStyle(Color.powMuted)
                    .multilineTextAlignment(.center)
            }
            .padding(28)
        }
        .navigationTitle("Return to Regulation")
        .navigationBarTitleDisplayMode(.inline)
    }
}

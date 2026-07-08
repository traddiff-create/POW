import SwiftUI

struct WhyIHereView: View {
    @Environment(AppState.self) private var appState
    @State private var application: CohortApplication?
    @State private var sharedExcerpt: SharedReflectionExcerpt?
    @State private var excerptText = ""
    @State private var isLoading = true
    @State private var isSaving = false
    @State private var error: String?
    @State private var savedMessage: String?

    var body: some View {
        ZStack {
            Color.hereBackground.ignoresSafeArea()

            if isLoading {
                ProgressView()
            } else {
                ScrollView {
                    VStack(spacing: 18) {
                        intro

                        if let application {
                            applicationAnswers(application)
                            anonymousShareCard
                        } else {
                            emptyState
                        }
                    }
                    .padding(24)
                }
            }
        }
        .navigationTitle("Why I'm Here")
        .navigationBarTitleDisplayMode(.inline)
        .task { await load() }
    }

    private var intro: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Why I'm Here")
                .font(.hereTitle)
                .foregroundStyle(Color.hereForeground)
            Text(HerePhilosophy.whyHereCopy)
                .font(.hereBody)
                .foregroundStyle(Color.hereMuted)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func applicationAnswers(_ application: CohortApplication) -> some View {
        VStack(spacing: 12) {
            if let motivation = application.motivation, !motivation.isEmpty {
                WhyHereAnswerCard(title: "What motivated me to join", detail: motivation)
            }
            if let hopedChange = application.hopedChange, !hopedChange.isEmpty {
                WhyHereAnswerCard(title: "What change I hoped for", detail: hopedChange)
            }
            if let howHeard = application.howHeard, !howHeard.isEmpty {
                WhyHereAnswerCard(title: "How I heard about Here", detail: howHeard)
            }

            HereCard {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Original capacity check")
                        .font(.hereLabel)
                        .foregroundStyle(Color.hereMuted)
                    if let hours = application.weeklyCapacityHours {
                        Label("\(hours) hour\(hours == 1 ? "" : "s") per week", systemImage: "clock")
                            .font(.hereCallout)
                            .foregroundStyle(Color.hereForeground)
                    }
                    if let comfort = application.groupComfortLevel {
                        Label("Group comfort \(comfort) of 5", systemImage: "person.3")
                            .font(.hereCallout)
                            .foregroundStyle(Color.hereForeground)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(16)
            }
        }
    }

    private var anonymousShareCard: some View {
        HereCard {
            VStack(alignment: .leading, spacing: 14) {
                VStack(alignment: .leading, spacing: 6) {
                    Label("Optional anonymous sharing", systemImage: "eye.slash")
                        .font(.hereLabel)
                        .foregroundStyle(Color.hereMuted)
                    Text("Help others know why people find Here")
                        .font(.hereTitle2)
                        .foregroundStyle(Color.hereForeground)
                    Text("Only this excerpt is shared. Your name, email, application, capacity, and comfort answers stay private.")
                        .font(.hereCallout)
                        .foregroundStyle(Color.hereMuted)
                        .fixedSize(horizontal: false, vertical: true)
                }

                HereTextField(
                    label: "Anonymous excerpt",
                    text: $excerptText,
                    placeholder: "A short reason you came to this practice...",
                    axis: .vertical,
                    accessibilityID: "whyHere.excerptField"
                )

                if let savedMessage {
                    Text(savedMessage)
                        .font(.hereCaption)
                        .foregroundStyle(Color.hereSage)
                }

                if let error {
                    Text(error)
                        .font(.hereCaption)
                        .foregroundStyle(Color.hereError)
                        .fixedSize(horizontal: false, vertical: true)
                }

                HereButton(
                    title: sharedExcerpt?.isActive == true ? "Update Anonymous Excerpt" : "Share Anonymous Excerpt",
                    isLoading: isSaving
                ) {
                    Task { await saveExcerpt() }
                }
                .disabled(excerptText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isSaving)
                .opacity(excerptText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.5 : 1)
                .accessibilityIdentifier("whyHere.shareButton")

                if sharedExcerpt?.isActive == true {
                    HereButton(title: "Unshare Excerpt", style: .destructive, isLoading: isSaving) {
                        Task { await unshareExcerpt() }
                    }
                    .accessibilityIdentifier("whyHere.unshareButton")
                }
            }
            .padding(20)
        }
    }

    private var emptyState: some View {
        HereCard {
            VStack(alignment: .leading, spacing: 10) {
                Label("No application yet", systemImage: "doc.text")
                    .font(.hereLabel)
                    .foregroundStyle(Color.hereMuted)
                Text("Once you apply, your answers will appear here so you can return to why you began.")
                    .font(.hereBody)
                    .foregroundStyle(Color.hereMuted)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(20)
        }
    }

    private func load() async {
        isLoading = true
        error = nil

        do {
            let applications = try await appState.fetchApplicationsForCurrentUser()
            application = applications.first
        } catch {
            self.error = AppPublicError.message(for: error, context: .application)
        }

        if let userID = appState.session?.user.id.uuidString {
            sharedExcerpt = try? await SupabaseService.shared.fetchMyApplicationReflectionExcerpt(userID: userID)
            if let sharedExcerpt {
                excerptText = sharedExcerpt.excerpt
            } else {
                excerptText = application?.motivation ?? ""
            }
        }

        isLoading = false
    }

    private func saveExcerpt() async {
        guard let userID = appState.session?.user.id.uuidString else { return }
        let trimmed = excerptText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        isSaving = true
        error = nil
        savedMessage = nil

        do {
            let submission = SharedReflectionExcerptSubmission(
                userID: userID,
                sourceType: .application,
                leg: .community,
                excerpt: String(trimmed.prefix(500)),
                isActive: true
            )
            sharedExcerpt = try await SupabaseService.shared.saveApplicationReflectionExcerpt(submission)
            excerptText = sharedExcerpt?.excerpt ?? trimmed
            savedMessage = "Shared anonymously."
        } catch {
            self.error = AppPublicError.message(for: error, context: .here)
        }

        isSaving = false
    }

    private func unshareExcerpt() async {
        guard let id = sharedExcerpt?.id else { return }
        isSaving = true
        error = nil
        savedMessage = nil

        do {
            sharedExcerpt = try await SupabaseService.shared.unshareApplicationReflectionExcerpt(id: id)
            savedMessage = "Excerpt unshared."
        } catch {
            self.error = AppPublicError.message(for: error, context: .here)
        }

        isSaving = false
    }
}

private struct WhyHereAnswerCard: View {
    let title: String
    let detail: String

    var body: some View {
        HereCard {
            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .font(.hereLabel)
                    .foregroundStyle(Color.hereMuted)
                Text(detail)
                    .font(.hereBody)
                    .foregroundStyle(Color.hereForeground)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(16)
        }
    }
}

struct WhyWereHereView: View {
    @State private var excerpts: [PublicSharedReflectionExcerpt] = []
    @State private var isLoading = true
    @State private var error: String?

    var body: some View {
        ZStack {
            Color.hereBackground.ignoresSafeArea()

            if isLoading {
                ProgressView()
            } else if let error {
                VStack(spacing: 16) {
                    Text(error)
                        .font(.hereBody)
                        .foregroundStyle(Color.hereMuted)
                        .multilineTextAlignment(.center)
                    HereButton(title: "Retry") { Task { await load() } }
                }
                .padding(24)
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: 18) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Why We're Here")
                                .font(.hereTitle)
                                .foregroundStyle(Color.hereForeground)
                            Text("Anonymous excerpts from people who chose to share why they came to this practice.")
                                .font(.hereBody)
                                .foregroundStyle(Color.hereMuted)
                        }

                        if excerpts.isEmpty {
                            HereCard {
                                Text("No anonymous reflections have been shared yet.")
                                    .font(.hereBody)
                                    .foregroundStyle(Color.hereMuted)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(20)
                            }
                        } else {
                            ForEach(excerpts) { excerpt in
                                PublicExcerptCard(excerpt: excerpt)
                            }
                        }
                    }
                    .padding(24)
                }
            }
        }
        .navigationTitle("Why We're Here")
        .navigationBarTitleDisplayMode(.inline)
        .task { await load() }
    }

    private func load() async {
        isLoading = true
        error = nil

        do {
            excerpts = try await SupabaseService.shared.fetchPublicSharedReflectionExcerpts()
        } catch {
            self.error = AppPublicError.message(for: error, context: .here)
        }

        isLoading = false
    }
}

private struct PublicExcerptCard: View {
    let excerpt: PublicSharedReflectionExcerpt

    var body: some View {
        HereCard {
            VStack(alignment: .leading, spacing: 10) {
                Label(excerpt.leg.title, systemImage: excerpt.leg.systemImage)
                    .font(.hereLabel)
                    .foregroundStyle(Color.hereMuted)
                Text(excerpt.excerpt)
                    .font(.hereBody)
                    .foregroundStyle(Color.hereForeground)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(18)
        }
    }
}

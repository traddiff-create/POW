import SwiftUI

struct CircleView: View {
    @Environment(AppState.self) var appState
    @State private var posts: [CirclePost] = []
    @State private var isLoading = true
    @State private var showNewPost = false
    @State private var error: String?

    var body: some View {
        NavigationStack {
            ZStack {
                Color.hereBackground.ignoresSafeArea()

                if isLoading {
                    ProgressView()
                } else if let error {
                    errorView(error)
                } else if appState.activeMembership?.cohortID == nil {
                    noCohortView
                } else if posts.isEmpty {
                    emptyView
                } else {
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(posts) { post in
                                NavigationLink(destination: CirclePostDetailView(post: post)) {
                                    CirclePostCard(post: post)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(24)
                    }
                }
            }
            .navigationTitle("Circle")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    if appState.activeMembership?.cohortID != nil {
                        Button {
                            showNewPost = true
                        } label: {
                            Image(systemName: "plus.circle")
                                .foregroundStyle(Color.hereSage)
                        }
                    }
                }
            }
            .task { await load() }
            .sheet(isPresented: $showNewPost) {
                NewCirclePostView { await load() }
            }
        }
    }

    private var emptyView: some View {
        VStack(spacing: 16) {
            Image(systemName: "person.3")
                .font(.system(size: 48))
                .foregroundStyle(Color.hereMuted)
            Text("Your circle is quiet")
                .font(.hereTitle2)
                .foregroundStyle(Color.hereForeground)
            Text("Be the first to share something with your group.")
                .font(.hereBody)
                .foregroundStyle(Color.hereMuted)
                .multilineTextAlignment(.center)
            HereButton(title: "Share to Circle") { showNewPost = true }
                .padding(.top, 8)
        }
        .padding(28)
    }

    private var noCohortView: some View {
        VStack(spacing: 16) {
            Image(systemName: "person.3")
                .font(.system(size: 48))
                .foregroundStyle(Color.hereMuted)
            Text("Circle opens with a cohort")
                .font(.hereTitle2)
                .foregroundStyle(Color.hereForeground)
            Text("Guest mode keeps your personal practice private. Join a cohort to share, comment, and participate in Circle.")
                .font(.hereBody)
                .foregroundStyle(Color.hereMuted)
                .multilineTextAlignment(.center)
        }
        .padding(28)
    }

    private func errorView(_ message: String) -> some View {
        VStack(spacing: 16) {
            Text(message).font(.hereBody).foregroundStyle(Color.hereMuted)
            HereButton(title: "Retry") { Task { await load() } }
        }
        .padding(24)
    }

    private func load() async {
        guard let cohortID = appState.activeMembership?.cohortID else {
            isLoading = false
            return
        }
        do {
            posts = try await SupabaseService.shared.fetchCirclePosts(cohortID: cohortID)
        } catch {
            self.error = AppPublicError.message(for: error, context: .circle)
        }
        isLoading = false
    }
}

struct CirclePostCard: View {
    let post: CirclePost

    var body: some View {
        HereCard {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Label(post.isAnonymous ? "Anonymous" : (post.authorName ?? "Member"),
                          systemImage: "person.circle")
                        .font(.hereCaption)
                        .foregroundStyle(Color.hereMuted)
                    Spacer()
                    Text(formatDate(post.createdAt))
                        .font(.hereCaption)
                        .foregroundStyle(Color.hereMuted)
                }

                Text(post.content)
                    .font(.hereBody)
                    .foregroundStyle(Color.hereForeground)
                    .lineLimit(4)

                if let count = post.commentCount, count > 0 {
                    Label("\(count) comment\(count == 1 ? "" : "s")", systemImage: "bubble.left")
                        .font(.hereCaption)
                        .foregroundStyle(Color.hereMuted)
                }
            }
            .padding(16)
        }
    }

    private func formatDate(_ iso: String) -> String {
        guard let date = ISO8601DateFormatter().date(from: iso) else { return "" }
        let f = RelativeDateTimeFormatter()
        f.unitsStyle = .abbreviated
        return f.localizedString(for: date, relativeTo: Date())
    }
}

struct NewCirclePostView: View {
    let onPost: () async -> Void
    @Environment(AppState.self) var appState
    @Environment(\.dismiss) var dismiss
    @State private var content = ""
    @State private var isAnonymous = false
    @State private var isLoading = false
    @State private var error: String?

    var body: some View {
        NavigationStack {
            ZStack {
                Color.hereBackground.ignoresSafeArea()
                VStack(spacing: 16) {
                    HereTextField(label: "Share with your circle", text: $content,
                                 placeholder: "What's on your mind?", axis: .vertical)
                        .frame(minHeight: 160, alignment: .top)

                    Toggle(isOn: $isAnonymous) {
                        Text("Post anonymously")
                            .font(.hereBody)
                            .foregroundStyle(Color.hereForeground)
                    }
                    .tint(Color.hereSage)

                    if let error {
                        Text(error)
                            .font(.hereCaption)
                            .foregroundStyle(Color.hereError)
                    }

                    Spacer()

                    HereButton(title: "Post to Circle", isLoading: isLoading) {
                        Task { await submit() }
                    }
                    .disabled(content.trimmingCharacters(in: .whitespaces).isEmpty)
                    .padding(.bottom, 32)
                }
                .padding(24)
            }
            .navigationTitle("New Post")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }

    private func submit() async {
        guard let userID = appState.session?.user.id.uuidString,
              let cohortID = appState.activeMembership?.cohortID else {
            error = "Join a cohort to post in Circle."
            return
        }
        isLoading = true
        error = nil
        do {
            _ = try await SupabaseService.shared.submitCirclePost(
                userID: userID, cohortID: cohortID,
                weekNumber: nil, content: content, isAnonymous: isAnonymous
            )
            await onPost()
            dismiss()
        } catch {
            self.error = AppPublicError.message(for: error, context: .circle)
        }
        isLoading = false
    }
}

import SwiftUI

struct CirclePostDetailView: View {
    let post: CirclePost
    @Environment(AppState.self) var appState
    @State private var comments: [CircleComment] = []
    @State private var newComment = ""
    @State private var isPosting = false
    @State private var showReport = false

    var body: some View {
        ZStack {
            Color.powBackground.ignoresSafeArea()
            VStack(spacing: 0) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        postBody
                        Divider()
                        commentsSection
                    }
                    .padding(24)
                }

                commentInput
            }
        }
        .navigationTitle("Circle Post")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showReport = true
                } label: {
                    Image(systemName: "flag")
                        .foregroundStyle(Color.powMuted)
                }
            }
        }
        .task { await loadComments() }
        .sheet(isPresented: $showReport) {
            ReportView(contentType: "post", contentID: post.id)
        }
    }

    private var postBody: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label(post.isAnonymous ? "Anonymous" : (post.authorName ?? "Member"),
                      systemImage: "person.circle")
                    .font(.powCaption)
                    .foregroundStyle(Color.powMuted)
                Spacer()
                Text(formatDate(post.createdAt))
                    .font(.powCaption)
                    .foregroundStyle(Color.powMuted)
            }
            Text(post.content)
                .font(.powBody)
                .foregroundStyle(Color.powForeground)
        }
    }

    private var commentsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Comments")
                .font(.powLabel)
                .foregroundStyle(Color.powForeground)

            if comments.isEmpty {
                Text("No comments yet. Be the first to respond.")
                    .font(.powBody)
                    .foregroundStyle(Color.powMuted)
            } else {
                ForEach(comments) { comment in
                    CommentRow(comment: comment)
                }
            }
        }
    }

    private var commentInput: some View {
        HStack(spacing: 12) {
            TextField("Add a comment…", text: $newComment, axis: .vertical)
                .font(.powBody)
                .padding(12)
                .background(Color.powSurface)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.powBorder, lineWidth: 1))
                .lineLimit(1...4)

            Button {
                Task { await postComment() }
            } label: {
                if isPosting {
                    ProgressView()
                        .frame(width: 44, height: 44)
                } else {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.system(size: 36))
                        .foregroundStyle(newComment.trimmingCharacters(in: .whitespaces).isEmpty ? Color.powMuted : Color.powSage)
                }
            }
            .disabled(newComment.trimmingCharacters(in: .whitespaces).isEmpty || isPosting)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color.powSurface)
        .overlay(Rectangle().frame(height: 1).foregroundStyle(Color.powBorder), alignment: .top)
    }

    private func formatDate(_ iso: String) -> String {
        guard let date = ISO8601DateFormatter().date(from: iso) else { return "" }
        let f = RelativeDateTimeFormatter()
        f.unitsStyle = .abbreviated
        return f.localizedString(for: date, relativeTo: Date())
    }

    private func loadComments() async {
        comments = (try? await SupabaseService.shared.fetchComments(postID: post.id)) ?? []
    }

    private func postComment() async {
        guard let userID = appState.session?.user.id.uuidString else { return }
        isPosting = true
        let text = newComment.trimmingCharacters(in: .whitespaces)
        try? await SupabaseService.shared.submitComment(postID: post.id, userID: userID, content: text)
        newComment = ""
        await loadComments()
        isPosting = false
    }
}

struct CommentRow: View {
    let comment: CircleComment

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Label("Member", systemImage: "person.circle")
                    .font(.powCaption)
                    .foregroundStyle(Color.powMuted)
                Spacer()
                Text(formatDate(comment.createdAt))
                    .font(.powCaption)
                    .foregroundStyle(Color.powMuted)
            }
            Text(comment.content)
                .font(.powCallout)
                .foregroundStyle(Color.powForeground)
        }
        .padding(.vertical, 4)
    }

    private func formatDate(_ iso: String) -> String {
        guard let date = ISO8601DateFormatter().date(from: iso) else { return "" }
        let f = RelativeDateTimeFormatter()
        f.unitsStyle = .abbreviated
        return f.localizedString(for: date, relativeTo: Date())
    }
}

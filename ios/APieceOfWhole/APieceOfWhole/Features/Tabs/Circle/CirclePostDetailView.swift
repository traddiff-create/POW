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
            Color.hereBackground.ignoresSafeArea()
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
                        .foregroundStyle(Color.hereMuted)
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
        }
    }

    private var commentsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Comments")
                .font(.hereLabel)
                .foregroundStyle(Color.hereForeground)

            if comments.isEmpty {
                Text("No comments yet. Be the first to respond.")
                    .font(.hereBody)
                    .foregroundStyle(Color.hereMuted)
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
                .font(.hereBody)
                .padding(12)
                .background(Color.hereSurface)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.hereBorder, lineWidth: 1))
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
                        .foregroundStyle(newComment.trimmingCharacters(in: .whitespaces).isEmpty ? Color.hereMuted : Color.hereSage)
                }
            }
            .disabled(newComment.trimmingCharacters(in: .whitespaces).isEmpty || isPosting)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color.hereSurface)
        .overlay(Rectangle().frame(height: 1).foregroundStyle(Color.hereBorder), alignment: .top)
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
                    .font(.hereCaption)
                    .foregroundStyle(Color.hereMuted)
                Spacer()
                Text(formatDate(comment.createdAt))
                    .font(.hereCaption)
                    .foregroundStyle(Color.hereMuted)
            }
            Text(comment.content)
                .font(.hereCallout)
                .foregroundStyle(Color.hereForeground)
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

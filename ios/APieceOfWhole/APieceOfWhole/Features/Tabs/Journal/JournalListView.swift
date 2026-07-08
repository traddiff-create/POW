import SwiftUI

struct JournalListView: View {
    @Environment(AppState.self) var appState
    @State private var entries: [JournalEntry] = []
    @State private var isLoading = true
    @State private var showNewEntry = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color.hereBackground.ignoresSafeArea()

                if isLoading {
                    ProgressView()
                } else if entries.isEmpty {
                    emptyView
                } else {
                    List {
                        ForEach(entries) { entry in
                            NavigationLink(destination: JournalEntryView(entry: entry) { await load() }) {
                                JournalEntryRow(entry: entry)
                            }
                            .listRowBackground(Color.hereSurface)
                        }
                    }
                    .listStyle(.plain)
                    .background(Color.hereBackground)
                    .scrollContentBackground(.hidden)
                }
            }
            .navigationTitle("Journal")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showNewEntry = true
                    } label: {
                        Image(systemName: "square.and.pencil")
                            .foregroundStyle(Color.hereSage)
                    }
                }
            }
            .task { await load() }
            .sheet(isPresented: $showNewEntry) {
                JournalEntryView(entry: nil) { await load() }
            }
        }
    }

    private var emptyView: some View {
        VStack(spacing: 16) {
            Image(systemName: "book.closed")
                .font(.system(size: 48))
                .foregroundStyle(Color.hereMuted)
            Text("Your journal is empty")
                .font(.hereTitle2)
                .foregroundStyle(Color.hereForeground)
            Text("Start writing to capture your reflections.")
                .font(.hereBody)
                .foregroundStyle(Color.hereMuted)
                .multilineTextAlignment(.center)
            HereButton(title: "New Entry") { showNewEntry = true }
                .padding(.top, 8)
        }
        .padding(28)
    }

    private func load() async {
        guard let userID = appState.session?.user.id.uuidString else { return }
        entries = (try? await SupabaseService.shared.fetchJournalEntries(userID: userID)) ?? []
        isLoading = false
    }
}

struct JournalEntryRow: View {
    let entry: JournalEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(entry.title ?? "Untitled")
                    .font(.hereBody)
                    .foregroundStyle(Color.hereForeground)
                    .lineLimit(1)
                Spacer()
                if entry.isShared {
                    Image(systemName: "person.2.circle")
                        .font(.hereCaption)
                        .foregroundStyle(Color.hereSage)
                } else {
                    Image(systemName: "lock")
                        .font(.hereCaption)
                        .foregroundStyle(Color.hereMuted)
                }
            }
            Text(entry.body ?? "")
                .font(.hereCallout)
                .foregroundStyle(Color.hereMuted)
                .lineLimit(2)
            Text(formatDate(entry.createdAt))
                .font(.hereCaption)
                .foregroundStyle(Color.hereMuted)
        }
        .padding(.vertical, 4)
    }

    private func formatDate(_ iso: String) -> String {
        guard let date = ISO8601DateFormatter().date(from: iso) else { return iso }
        let f = DateFormatter()
        f.dateStyle = .medium
        return f.string(from: date)
    }
}

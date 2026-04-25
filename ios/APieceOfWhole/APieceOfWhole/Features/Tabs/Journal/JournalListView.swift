import SwiftUI

struct JournalListView: View {
    @Environment(AppState.self) var appState
    @State private var entries: [JournalEntry] = []
    @State private var isLoading = true
    @State private var showNewEntry = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color.powBackground.ignoresSafeArea()

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
                            .listRowBackground(Color.powSurface)
                        }
                    }
                    .listStyle(.plain)
                    .background(Color.powBackground)
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
                            .foregroundStyle(Color.powSage)
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
                .foregroundStyle(Color.powMuted)
            Text("Your journal is empty")
                .font(.powTitle2)
                .foregroundStyle(Color.powForeground)
            Text("Start writing to capture your reflections.")
                .font(.powBody)
                .foregroundStyle(Color.powMuted)
                .multilineTextAlignment(.center)
            POWButton(title: "New Entry") { showNewEntry = true }
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
                    .font(.powBody)
                    .foregroundStyle(Color.powForeground)
                    .lineLimit(1)
                Spacer()
                if entry.isShared {
                    Image(systemName: "person.2.circle")
                        .font(.powCaption)
                        .foregroundStyle(Color.powSage)
                } else {
                    Image(systemName: "lock")
                        .font(.powCaption)
                        .foregroundStyle(Color.powMuted)
                }
            }
            Text(entry.body ?? "")
                .font(.powCallout)
                .foregroundStyle(Color.powMuted)
                .lineLimit(2)
            Text(formatDate(entry.createdAt))
                .font(.powCaption)
                .foregroundStyle(Color.powMuted)
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

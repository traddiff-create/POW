import SwiftUI

struct JournalEntryView: View {
    let entry: JournalEntry?
    let onSave: () async -> Void
    @Environment(AppState.self) var appState
    @Environment(\.dismiss) var dismiss
    @State private var title = ""
    @State private var body_text = ""
    @State private var isLoading = false
    @State private var showShareConfirm = false
    @State private var error: String?

    init(entry: JournalEntry?, onSave: @escaping () async -> Void) {
        self.entry = entry
        self.onSave = onSave
        _title = State(initialValue: entry?.title ?? "")
        _body_text = State(initialValue: entry?.body ?? "")
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.powBackground.ignoresSafeArea()
                VStack(spacing: 0) {
                    ScrollView {
                        VStack(spacing: 16) {
                            POWTextField(label: "Title (optional)", text: $title, placeholder: "Give this entry a title...")
                            POWTextField(label: "Your reflection", text: $body_text,
                                         placeholder: "What's present for you right now?", axis: .vertical)
                                .frame(minHeight: 200, alignment: .top)

                            if let error {
                                Text(error)
                                    .font(.powCaption)
                                    .foregroundStyle(Color.powError)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                        }
                        .padding(24)
                    }

                    VStack(spacing: 12) {
                        POWButton(title: entry == nil ? "Save Entry" : "Update Entry", isLoading: isLoading) {
                            Task { await save() }
                        }
                        .disabled(body_text.trimmingCharacters(in: .whitespaces).isEmpty)

                        if entry != nil && !(entry?.isShared ?? false) && appState.circleID != nil {
                            Button("Share to Circle") {
                                showShareConfirm = true
                            }
                            .font(.powCallout)
                            .foregroundStyle(Color.powSage)
                        } else if entry?.isShared == true {
                            Label("Shared to Circle", systemImage: "checkmark.circle.fill")
                                .font(.powCallout)
                                .foregroundStyle(Color.powSage)
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 32)
                    .padding(.top, 8)
                }
            }
            .navigationTitle(entry == nil ? "New Entry" : "Edit Entry")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
            .sheet(isPresented: $showShareConfirm) {
                if let entry {
                    ShareConfirmationView(entry: entry) {
                        await onSave()
                        dismiss()
                    }
                }
            }
        }
    }

    private func save() async {
        guard let userID = appState.session?.user.id.uuidString else { return }
        isLoading = true
        error = nil
        do {
            if let existing = entry {
                try await SupabaseService.shared.updateJournalEntry(
                    id: existing.id,
                    title: title.isEmpty ? nil : title,
                    body: body_text
                )
            } else {
                try await SupabaseService.shared.createJournalEntry(
                    userID: userID,
                    cohortID: appState.activeMembership?.cohortID,
                    title: title.isEmpty ? nil : title,
                    body: body_text
                )
            }
            await onSave()
            dismiss()
        } catch {
            self.error = AppPublicError.message(for: error, context: .journal)
        }
        isLoading = false
    }
}

import SwiftUI

struct MyPieceView: View {
    @Environment(AppState.self) var appState
    @State private var values = ""
    @State private var giftsSkills = ""
    @State private var currentCapacity = ""
    @State private var boundaries = ""
    @State private var currentContribution = ""
    @State private var smallAction = ""
    @State private var isSaving = false
    @State private var saveError: String?
    @State private var savedAt: Date?

    var body: some View {
        NavigationStack {
            ZStack {
                Color.powBackground.ignoresSafeArea()
                ScrollView {
                    VStack(spacing: 20) {
                        introCard
                        fieldsSection
                        saveButton
                    }
                    .padding(24)
                }
            }
            .navigationTitle("My Piece")
            .navigationBarTitleDisplayMode(.large)
            .onAppear { populateFromProfile() }
        }
    }

    private var introCard: some View {
        POWCard {
            VStack(alignment: .leading, spacing: 8) {
                Label("Your contribution to the whole", systemImage: "puzzle.piece")
                    .font(.powCaption)
                    .foregroundStyle(Color.powMuted)
                Text("These reflections are private and help you stay grounded in your unique gifts and edges.")
                    .font(.powBody)
                    .foregroundStyle(Color.powForeground)
            }
            .padding(20)
        }
    }

    private var fieldsSection: some View {
        VStack(spacing: 16) {
            POWTextField(
                label: "My Values",
                text: $values,
                placeholder: "What do you stand for?",
                axis: .vertical
            )

            POWTextField(
                label: "Gifts & Skills",
                text: $giftsSkills,
                placeholder: "What do you bring to this space?",
                axis: .vertical
            )

            POWTextField(
                label: "Current Capacity",
                text: $currentCapacity,
                placeholder: "How much can you give right now?",
                axis: .vertical
            )

            POWTextField(
                label: "My Edges & Boundaries",
                text: $boundaries,
                placeholder: "What needs protecting right now?",
                axis: .vertical
            )

            POWTextField(
                label: "Current Contribution",
                text: $currentContribution,
                placeholder: "What are you actively contributing?",
                axis: .vertical
            )

            POWTextField(
                label: "One Small Action",
                text: $smallAction,
                placeholder: "What's one thing you can do this week?",
                axis: .vertical
            )
        }
    }

    private var saveButton: some View {
        VStack(spacing: 8) {
            if let error = saveError {
                Text(error)
                    .font(.powCaption)
                    .foregroundStyle(Color.powError)
            }
            if let saved = savedAt {
                Text("Saved \(saved.formatted(date: .omitted, time: .shortened))")
                    .font(.powCaption)
                    .foregroundStyle(Color.powMuted)
            }
            POWButton(title: "Save My Piece", isLoading: isSaving) {
                Task { await save() }
            }
        }
    }

    private func populateFromProfile() {
        guard let profile = appState.profile else { return }
        values = profile.values ?? ""
        giftsSkills = profile.giftsSkills ?? ""
        currentCapacity = profile.currentCapacity ?? ""
        boundaries = profile.boundaries ?? ""
        currentContribution = profile.currentContribution ?? ""
        smallAction = profile.smallAction ?? ""
    }

    private func save() async {
        guard let userID = appState.session?.user.id.uuidString else { return }
        isSaving = true
        saveError = nil
        do {
            try await SupabaseService.shared.updateMyPiece(
                userID: userID,
                values: values.isEmpty ? nil : values,
                giftsSkills: giftsSkills.isEmpty ? nil : giftsSkills,
                currentCapacity: currentCapacity.isEmpty ? nil : currentCapacity,
                boundaries: boundaries.isEmpty ? nil : boundaries,
                currentContribution: currentContribution.isEmpty ? nil : currentContribution,
                smallAction: smallAction.isEmpty ? nil : smallAction
            )
            savedAt = Date()
            await appState.refreshProfile()
        } catch {
            saveError = error.localizedDescription
        }
        isSaving = false
    }
}

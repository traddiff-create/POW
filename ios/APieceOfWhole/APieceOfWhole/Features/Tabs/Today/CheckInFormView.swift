import SwiftUI

struct CheckInFormView: View {
    let onComplete: () async -> Void
    @Environment(AppState.self) var appState
    @Environment(\.dismiss) var dismiss
    @State private var body_sensation = ""
    @State private var mood = 3
    @State private var stressLevel = 3
    @State private var capacityLevel = 3
    @State private var privateNote = ""
    @State private var isLoading = false
    @State private var error: String?

    var body: some View {
        NavigationStack {
            ZStack {
                Color.powBackground.ignoresSafeArea()
                ScrollView {
                    VStack(spacing: 24) {
                        VStack(spacing: 8) {
                            Text("How are you arriving?")
                                .font(.powTitle2)
                                .foregroundStyle(Color.powForeground)
                            Text("This is private — only you can see your check-ins.")
                                .font(.powCallout)
                                .foregroundStyle(Color.powMuted)
                                .multilineTextAlignment(.center)
                        }
                        .padding(.top, 8)

                        POWTextField(label: "Body sensation (optional)", text: $body_sensation,
                                     placeholder: "What do you notice in your body right now?", axis: .vertical)

                        ratingRow(label: "Mood", value: $mood)
                        ratingRow(label: "Stress level", value: $stressLevel)
                        ratingRow(label: "Capacity", value: $capacityLevel)

                        POWTextField(label: "Private note (optional)", text: $privateNote,
                                     placeholder: "Anything else you want to note...", axis: .vertical)

                        if let error {
                            Text(error)
                                .font(.powCaption)
                                .foregroundStyle(Color.powError)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }

                        POWButton(title: "Save Check-In", isLoading: isLoading) {
                            Task { await submit() }
                        }
                        .padding(.bottom, 32)
                    }
                    .padding(.horizontal, 24)
                }
            }
            .navigationTitle("Daily Check-In")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }

    private func ratingRow(label: String, value: Binding<Int>) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(.powCaption)
                .foregroundStyle(Color.powMuted)
            HStack(spacing: 8) {
                ForEach(1...5, id: \.self) { n in
                    Button {
                        value.wrappedValue = n
                    } label: {
                        Text("\(n)")
                            .font(.powBody)
                            .frame(width: 44, height: 44)
                            .background(value.wrappedValue == n ? Color.powSage : Color.powSurface)
                            .foregroundStyle(value.wrappedValue == n ? Color.white : Color.powForeground)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.powBorder, lineWidth: 1))
                    }
                }
            }
        }
    }

    private func submit() async {
        guard let userID = appState.session?.user.id.uuidString else { return }
        isLoading = true
        error = nil
        do {
            let week = currentWeek ?? 1
            let submission = CheckInSubmission(
                userID: userID,
                weekNumber: week,
                moodScore: nil,
                bodySensation: body_sensation.isEmpty ? nil : body_sensation,
                oneWord: nil,
                freeNote: privateNote.isEmpty ? nil : privateNote,
                mood: mood,
                stressLevel: stressLevel,
                capacityLevel: capacityLevel
            )
            try await SupabaseService.shared.submitCheckIn(submission)
            await onComplete()
            dismiss()
        } catch {
            self.error = AppPublicError.message(for: error, context: .checkIn)
        }
        isLoading = false
    }

    private var currentWeek: Int? {
        guard let membership = appState.activeMembership,
              let enrolled = ISO8601DateFormatter().date(from: membership.enrolledAt) else { return nil }
        let days = Calendar.current.dateComponents([.day], from: enrolled, to: Date()).day ?? 0
        return min(max(days / 7 + 1, 1), 8)
    }
}

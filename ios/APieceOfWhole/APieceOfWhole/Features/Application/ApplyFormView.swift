import SwiftUI

extension CohortApplication: Hashable {
    static func == (lhs: CohortApplication, rhs: CohortApplication) -> Bool { lhs.id == rhs.id }
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
}

struct ApplyFormView: View {
    let cohort: Cohort
    @Binding var path: NavigationPath
    @Environment(AppState.self) var appState
    @State private var motivation = ""
    @State private var howHeard = ""
    @State private var hopedChange = ""
    @State private var weeklyCapacity = 3
    @State private var groupComfort = 3
    @State private var agreementsAccepted = false
    @State private var safetyAcknowledged = false
    @State private var isLoading = false
    @State private var error: String?

    private var isValid: Bool {
        !motivation.isEmpty && !hopedChange.isEmpty && agreementsAccepted && safetyAcknowledged
    }

    var body: some View {
        ZStack {
            Color.powBackground.ignoresSafeArea()
            ScrollView {
                VStack(spacing: 24) {
                    VStack(spacing: 8) {
                        Text("Apply to \(cohort.name)")
                            .font(.powTitle2)
                            .foregroundStyle(Color.powForeground)
                        Text("Tell us about yourself and what brings you here.")
                            .font(.powBody)
                            .foregroundStyle(Color.powMuted)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 8)

                    POWTextField(label: "What motivates you to join? *", text: $motivation, placeholder: "Share what's calling you to this work...", axis: .vertical)
                    POWTextField(label: "What change do you hope for? *", text: $hopedChange, placeholder: "What does growth look like for you...", axis: .vertical)
                    POWTextField(label: "How did you hear about us?", text: $howHeard)

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Hours per week you can commit (1-10)")
                            .font(.powCaption)
                            .foregroundStyle(Color.powMuted)
                        Stepper("\(weeklyCapacity) hours", value: $weeklyCapacity, in: 1...10)
                            .font(.powBody)
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Comfort level in group settings (1–5)")
                            .font(.powCaption)
                            .foregroundStyle(Color.powMuted)
                        HStack(spacing: 8) {
                            ForEach(1...5, id: \.self) { n in
                                Button {
                                    groupComfort = n
                                } label: {
                                    Text("\(n)")
                                        .font(.powBody)
                                        .frame(width: 44, height: 44)
                                        .background(groupComfort == n ? Color.powSage : Color.powSurface)
                                        .foregroundStyle(groupComfort == n ? Color.white : Color.powForeground)
                                        .clipShape(Circle())
                                        .overlay(Circle().stroke(Color.powBorder, lineWidth: 1))
                                }
                            }
                        }
                    }

                    Toggle(isOn: $agreementsAccepted) {
                        Text("I acknowledge the program agreements and community standards")
                            .font(.powCallout)
                            .foregroundStyle(Color.powForeground)
                    }
                    .tint(Color.powSage)

                    Toggle(isOn: $safetyAcknowledged) {
                        Text("I understand this is not therapy, not medical care, and not a crisis service")
                            .font(.powCallout)
                            .foregroundStyle(Color.powForeground)
                    }
                    .tint(Color.powSage)

                    if let error {
                        Text(error)
                            .font(.powCaption)
                            .foregroundStyle(Color.powError)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    POWButton(title: "Submit Application", isLoading: isLoading) {
                        Task { await submit() }
                    }
                    .disabled(!isValid)
                    .opacity(isValid ? 1 : 0.5)
                    .padding(.bottom, 32)
                }
                .padding(.horizontal, 24)
            }
        }
        .navigationTitle("Application")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func submit() async {
        guard let email = appState.session?.user.email,
              let name = appState.profile?.displayName else { return }
        isLoading = true
        error = nil
        do {
            let submission = ApplicationSubmission(
                cohortID: cohort.id,
                applicantName: name,
                applicantEmail: email,
                motivation: motivation,
                howHeard: howHeard,
                hopedChange: hopedChange,
                weeklyCapacityHours: weeklyCapacity,
                groupComfortLevel: groupComfort,
                agreementsAccepted: agreementsAccepted,
                safetyAcknowledged: safetyAcknowledged
            )
            let application = try await SupabaseService.shared.submitApplication(submission)
            path.append(application)
        } catch {
            self.error = error.localizedDescription
        }
        isLoading = false
    }
}

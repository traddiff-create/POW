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
        !motivation.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && !hopedChange.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && agreementsAccepted
            && safetyAcknowledged
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
                        Text(POWPhilosophy.applicationCopy)
                            .font(.powBody)
                            .foregroundStyle(Color.powMuted)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 8)

                    POWTextField(label: "What motivates you to join? *", text: $motivation, placeholder: "Share what's calling you to this work...", axis: .vertical, accessibilityID: "application.motivationField")
                    POWTextField(label: "What change do you hope for? *", text: $hopedChange, placeholder: "What does growth look like for you...", axis: .vertical, accessibilityID: "application.hopedChangeField")
                    POWTextField(label: "How did you hear about us?", text: $howHeard, accessibilityID: "application.howHeardField")

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Hours per week you can commit (1-10)")
                            .font(.powCaption)
                            .foregroundStyle(Color.powMuted)
                        Stepper("\(weeklyCapacity) hours", value: $weeklyCapacity, in: 1...10)
                            .font(.powBody)
                            .accessibilityIdentifier("application.weeklyCapacityStepper")
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
                                .accessibilityIdentifier("application.groupComfort.\(n)")
                            }
                        }
                    }

                    Toggle(isOn: $agreementsAccepted) {
                        Text("I acknowledge the program agreements and community standards")
                            .font(.powCallout)
                            .foregroundStyle(Color.powForeground)
                    }
                    .tint(Color.powSage)
                    .accessibilityIdentifier("application.agreementsToggle")

                    Toggle(isOn: $safetyAcknowledged) {
                        Text("I understand this is not therapy, not medical care, and not a crisis service")
                            .font(.powCallout)
                            .foregroundStyle(Color.powForeground)
                    }
                    .tint(Color.powSage)
                    .accessibilityIdentifier("application.safetyToggle")

                    if let error {
                        Text(error)
                            .font(.powCaption)
                            .foregroundStyle(Color.powError)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .accessibilityIdentifier("application.errorText")
                    }

                    POWButton(title: "Submit Application", isLoading: isLoading) {
                        Task { await submit() }
                    }
                    .disabled(!isValid || isLoading)
                    .opacity(isValid ? 1 : 0.5)
                    .accessibilityIdentifier("application.submitButton")
                    .padding(.bottom, 32)
                }
                .padding(.horizontal, 24)
            }
        }
        .navigationTitle("Application")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                ApplicantAccountMenu()
            }
        }
    }

    private func submit() async {
        isLoading = true
        error = nil
        do {
            let application = try await appState.submitApplication(
                cohort: cohort,
                motivation: motivation,
                howHeard: howHeard,
                hopedChange: hopedChange,
                weeklyCapacity: weeklyCapacity,
                groupComfort: groupComfort,
                agreementsAccepted: agreementsAccepted,
                safetyAcknowledged: safetyAcknowledged
            )
            path.append(application)
        } catch {
            self.error = error.localizedDescription
        }
        isLoading = false
    }
}

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
            Color.hereBackground.ignoresSafeArea()
            ScrollView {
                VStack(spacing: 24) {
                    VStack(spacing: 8) {
                        Text("Apply to \(cohort.name)")
                            .font(.hereTitle2)
                            .foregroundStyle(Color.hereForeground)
                        Text(HerePhilosophy.applicationCopy)
                            .font(.hereBody)
                            .foregroundStyle(Color.hereMuted)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 8)

                    HereTextField(label: "What motivates you to join? *", text: $motivation, placeholder: "Share what's calling you to this work...", axis: .vertical, accessibilityID: "application.motivationField")
                    HereTextField(label: "What change do you hope for? *", text: $hopedChange, placeholder: "What does growth look like for you...", axis: .vertical, accessibilityID: "application.hopedChangeField")
                    HereTextField(label: "How did you hear about us?", text: $howHeard, accessibilityID: "application.howHeardField")

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Hours per week you can commit (1-10)")
                            .font(.hereCaption)
                            .foregroundStyle(Color.hereMuted)
                        Stepper("\(weeklyCapacity) hours", value: $weeklyCapacity, in: 1...10)
                            .font(.hereBody)
                            .accessibilityIdentifier("application.weeklyCapacityStepper")
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Comfort level in group settings (1–5)")
                            .font(.hereCaption)
                            .foregroundStyle(Color.hereMuted)
                        HStack(spacing: 8) {
                            ForEach(1...5, id: \.self) { n in
                                Button {
                                    groupComfort = n
                                } label: {
                                    Text("\(n)")
                                        .font(.hereBody)
                                        .frame(width: 44, height: 44)
                                        .background(groupComfort == n ? Color.hereSage : Color.hereSurface)
                                        .foregroundStyle(groupComfort == n ? Color.white : Color.hereForeground)
                                        .clipShape(Circle())
                                        .overlay(Circle().stroke(Color.hereBorder, lineWidth: 1))
                                }
                                .accessibilityIdentifier("application.groupComfort.\(n)")
                            }
                        }
                    }

                    Toggle(isOn: $agreementsAccepted) {
                        Text("I acknowledge the program agreements and community standards")
                            .font(.hereCallout)
                            .foregroundStyle(Color.hereForeground)
                    }
                    .tint(Color.hereSage)
                    .accessibilityIdentifier("application.agreementsToggle")

                    Toggle(isOn: $safetyAcknowledged) {
                        Text("I understand this is not therapy, not medical care, and not a crisis service")
                            .font(.hereCallout)
                            .foregroundStyle(Color.hereForeground)
                    }
                    .tint(Color.hereSage)
                    .accessibilityIdentifier("application.safetyToggle")

                    if let error {
                        Text(error)
                            .font(.hereCaption)
                            .foregroundStyle(Color.hereError)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .accessibilityIdentifier("application.errorText")
                    }

                    HereButton(title: "Submit Application", isLoading: isLoading) {
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
            self.error = AppPublicError.message(for: error, context: .application)
        }
        isLoading = false
    }
}

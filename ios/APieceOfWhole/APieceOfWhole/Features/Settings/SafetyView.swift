import SwiftUI

struct SafetyView: View {
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                Color.powBackground.ignoresSafeArea()
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        disclaimerCard
                        crisisCard
                        resourcesCard
                    }
                    .padding(24)
                }
            }
            .navigationTitle("Safety Information")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }

    private var disclaimerCard: some View {
        POWCard {
            VStack(alignment: .leading, spacing: 12) {
                Label("Important Notice", systemImage: "exclamationmark.triangle")
                    .font(.powLabel)
                    .foregroundStyle(Color.powForeground)
                Text("Here is a community support app, not a clinical service.")
                    .font(.powBody)
                    .foregroundStyle(Color.powForeground)
                Text("This app is not therapy, not medical care, not crisis intervention, and not a substitute for professional mental health treatment. Participation in this program does not create a therapeutic relationship.")
                    .font(.powBody)
                    .foregroundStyle(Color.powMuted)
            }
            .padding(20)
        }
    }

    private var crisisCard: some View {
        POWCard {
            VStack(alignment: .leading, spacing: 12) {
                Label("If You Are in Crisis", systemImage: "phone.fill")
                    .font(.powLabel)
                    .foregroundStyle(Color.powError)
                Text("If you or someone you know is in immediate danger or experiencing a mental health crisis, please reach out for help right away.")
                    .font(.powBody)
                    .foregroundStyle(Color.powForeground)
                Divider()
                VStack(alignment: .leading, spacing: 8) {
                    crisisLine(name: "988 Suicide & Crisis Lifeline", detail: "Call or text 988")
                    crisisLine(name: "Crisis Text Line", detail: "Text HOME to 741741")
                    crisisLine(name: "Emergency Services", detail: "Call 911")
                }
            }
            .padding(20)
        }
    }

    private var resourcesCard: some View {
        POWCard {
            VStack(alignment: .leading, spacing: 8) {
                Label("Community Guidelines", systemImage: "person.3")
                    .font(.powLabel)
                    .foregroundStyle(Color.powForeground)
                Text("All participants agree to engage with care, honesty, and respect. Harmful content or behavior should be reported using the flag icon on any post.")
                    .font(.powBody)
                    .foregroundStyle(Color.powMuted)
            }
            .padding(20)
        }
    }

    private func crisisLine(name: String, detail: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(name).font(.powCallout).foregroundStyle(Color.powForeground)
            Text(detail).font(.powCaption).foregroundStyle(Color.powMuted)
        }
    }
}

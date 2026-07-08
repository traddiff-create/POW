import SwiftUI

struct SafetyView: View {
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                Color.hereBackground.ignoresSafeArea()
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
        HereCard {
            VStack(alignment: .leading, spacing: 12) {
                Label("Important Notice", systemImage: "exclamationmark.triangle")
                    .font(.hereLabel)
                    .foregroundStyle(Color.hereForeground)
                Text("Here is a community support app, not a clinical service.")
                    .font(.hereBody)
                    .foregroundStyle(Color.hereForeground)
                Text("This app is not therapy, not medical care, not crisis intervention, and not a substitute for professional mental health treatment. Participation in this program does not create a therapeutic relationship.")
                    .font(.hereBody)
                    .foregroundStyle(Color.hereMuted)
            }
            .padding(20)
        }
    }

    private var crisisCard: some View {
        HereCard {
            VStack(alignment: .leading, spacing: 12) {
                Label("If You Are in Crisis", systemImage: "phone.fill")
                    .font(.hereLabel)
                    .foregroundStyle(Color.hereError)
                Text("If you or someone you know is in immediate danger or experiencing a mental health crisis, please reach out for help right away.")
                    .font(.hereBody)
                    .foregroundStyle(Color.hereForeground)
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
        HereCard {
            VStack(alignment: .leading, spacing: 8) {
                Label("Community Guidelines", systemImage: "person.3")
                    .font(.hereLabel)
                    .foregroundStyle(Color.hereForeground)
                Text("All participants agree to engage with care, honesty, and respect. Harmful content or behavior should be reported using the flag icon on any post.")
                    .font(.hereBody)
                    .foregroundStyle(Color.hereMuted)
            }
            .padding(20)
        }
    }

    private func crisisLine(name: String, detail: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(name).font(.hereCallout).foregroundStyle(Color.hereForeground)
            Text(detail).font(.hereCaption).foregroundStyle(Color.hereMuted)
        }
    }
}

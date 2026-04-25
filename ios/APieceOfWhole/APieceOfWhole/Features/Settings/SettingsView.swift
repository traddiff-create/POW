import SwiftUI

struct SettingsView: View {
    @Environment(AppState.self) var appState
    @State private var showSafety = false
    @State private var showSupport = false
    @State private var showLegal = false
    @State private var showDeleteAccount = false
    @State private var isSigningOut = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color.powBackground.ignoresSafeArea()
                List {
                    Section("Profile") {
                        NavigationLink(destination: ProfileEditView()) {
                            Label("Edit Profile", systemImage: "person.circle")
                        }
                    }

                    Section("Support & Safety") {
                        Button {
                            showSafety = true
                        } label: {
                            Label("Safety Information", systemImage: "heart.circle")
                                .foregroundStyle(Color.powForeground)
                        }
                        Button {
                            showSupport = true
                        } label: {
                            Label("Contact Support", systemImage: "envelope")
                                .foregroundStyle(Color.powForeground)
                        }
                    }

                    Section("Legal") {
                        Button {
                            showLegal = true
                        } label: {
                            Label("Terms & Privacy", systemImage: "doc.text")
                                .foregroundStyle(Color.powForeground)
                        }
                    }

                    Section {
                        Button(role: .destructive) {
                            Task { await signOut() }
                        } label: {
                            HStack {
                                Label("Sign Out", systemImage: "rectangle.portrait.and.arrow.right")
                                if isSigningOut { Spacer(); ProgressView() }
                            }
                        }
                        .disabled(isSigningOut)

                        Button(role: .destructive) {
                            showDeleteAccount = true
                        } label: {
                            Label("Delete Account", systemImage: "trash")
                        }
                    }
                }
                .scrollContentBackground(.hidden)
                .background(Color.powBackground)
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showSafety) { SafetyView() }
            .sheet(isPresented: $showSupport) { SupportView() }
            .sheet(isPresented: $showLegal) { LegalView() }
            .sheet(isPresented: $showDeleteAccount) { DeleteAccountView() }
        }
    }

    private func signOut() async {
        isSigningOut = true
        try? await appState.signOut()
        isSigningOut = false
    }
}

struct ProfileEditView: View {
    @Environment(AppState.self) var appState
    @Environment(\.dismiss) var dismiss
    @State private var displayName = ""
    @State private var isSaving = false
    @State private var error: String?

    var body: some View {
        ZStack {
            Color.powBackground.ignoresSafeArea()
            VStack(spacing: 20) {
                POWTextField(label: "Display Name", text: $displayName, placeholder: "Your name")
                if let error {
                    Text(error).font(.powCaption).foregroundStyle(Color.powError)
                }
                Spacer()
                POWButton(title: "Save", isLoading: isSaving) {
                    Task { await save() }
                }
                .disabled(displayName.trimmingCharacters(in: .whitespaces).isEmpty)
            }
            .padding(24)
        }
        .navigationTitle("Edit Profile")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            displayName = appState.profile?.displayName ?? ""
        }
    }

    private func save() async {
        guard let userID = appState.session?.user.id.uuidString else { return }
        isSaving = true
        error = nil
        do {
            try await SupabaseService.shared.updateOnboardingProfile(
                userID: userID,
                displayName: displayName.trimmingCharacters(in: .whitespaces),
                timestamp: ISO8601DateFormatter().string(from: Date())
            )
            await appState.refreshProfile()
            dismiss()
        } catch {
            self.error = error.localizedDescription
        }
        isSaving = false
    }
}

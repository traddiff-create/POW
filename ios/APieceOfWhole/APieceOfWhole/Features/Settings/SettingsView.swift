import SwiftUI

struct SettingsView: View {
    @Environment(AppState.self) var appState
    @State private var showSafety = false
    @State private var showSupport = false
    @State private var showLegal = false
    @State private var showDeleteAccount = false
    @State private var showUpgradeGuest = false
    @State private var isSigningOut = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color.hereBackground.ignoresSafeArea()
                List {
                    Section("Profile") {
                        if appState.isGuest {
                            Label("Guest Mode", systemImage: "person.crop.circle.badge.questionmark")
                                .foregroundStyle(Color.hereMuted)
                        }
                        NavigationLink(destination: ProfileEditView()) {
                            Label("Edit Profile", systemImage: "person.circle")
                        }
                    }

                    Section("Support & Safety") {
                        Button {
                            showSafety = true
                        } label: {
                            Label("Safety Information", systemImage: "heart.circle")
                                .foregroundStyle(Color.hereForeground)
                        }
                        Button {
                            showSupport = true
                        } label: {
                            Label("Contact Support", systemImage: "envelope")
                                .foregroundStyle(Color.hereForeground)
                        }
                    }

                    Section("About") {
                        NavigationLink(destination: PhilosophyView()) {
                            Label("Working Philosophy", systemImage: "circle.hexagongrid")
                        }
                    }

                    Section("Legal") {
                        Button {
                            showLegal = true
                        } label: {
                            Label("Terms & Privacy", systemImage: "doc.text")
                                .foregroundStyle(Color.hereForeground)
                        }
                    }

                    Section {
                        if appState.isGuest {
                            Button {
                                showUpgradeGuest = true
                            } label: {
                                Label("Create Account to Keep Access", systemImage: "person.badge.plus")
                                    .foregroundStyle(Color.hereForeground)
                            }

                            Button(role: .destructive) {
                                Task { await signOut() }
                            } label: {
                                HStack {
                                    Label("Exit Guest Mode", systemImage: "rectangle.portrait.and.arrow.right")
                                    if isSigningOut { Spacer(); ProgressView() }
                                }
                            }
                            .disabled(isSigningOut)
                        } else {
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
                }
                .scrollContentBackground(.hidden)
                .background(Color.hereBackground)
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showSafety) { SafetyView() }
            .sheet(isPresented: $showSupport) { SupportView() }
            .sheet(isPresented: $showLegal) { LegalView() }
            .sheet(isPresented: $showDeleteAccount) { DeleteAccountView() }
            .sheet(isPresented: $showUpgradeGuest) { GuestAccountUpgradeView() }
        }
    }

    private func signOut() async {
        isSigningOut = true
        try? await appState.signOut()
        isSigningOut = false
    }
}

struct GuestAccountUpgradeView: View {
    @Environment(AppState.self) var appState
    @Environment(\.dismiss) var dismiss
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var isSaving = false
    @State private var error: String?

    var body: some View {
        NavigationStack {
            ZStack {
                Color.hereBackground.ignoresSafeArea()
                ScrollView {
                    VStack(spacing: 24) {
                        VStack(spacing: 8) {
                            Text("Keep your guest access")
                                .font(.hereTitle2)
                                .foregroundStyle(Color.hereForeground)
                            Text("Add email and password sign-in to preserve this guest profile, check-ins, journal entries, and My Piece reflections.")
                                .font(.hereBody)
                                .foregroundStyle(Color.hereMuted)
                                .multilineTextAlignment(.center)
                        }
                        .padding(.top, 8)

                        VStack(spacing: 16) {
                            HereTextField(label: "Email", text: $email, keyboardType: .emailAddress)
                            HereTextField(label: "Password", text: $password, isSecure: true)
                            HereTextField(label: "Confirm Password", text: $confirmPassword, isSecure: true)
                        }

                        if let error {
                            Text(error)
                                .font(.hereCaption)
                                .foregroundStyle(Color.hereError)
                                .frame(maxWidth: .infinity, alignment: .leading)

                            if error == (AuthInputError.emailAlreadyExists.errorDescription ?? "") {
                                NavigationLink(destination: SignInView()) {
                                    Label("Sign In Instead", systemImage: "rectangle.portrait.and.arrow.right")
                                        .font(.hereCallout)
                                        .foregroundStyle(Color.hereSage)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                            }
                        }

                        HereButton(title: "Create Account", isLoading: isSaving) {
                            Task { await upgrade() }
                        }
                        .disabled(email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || password.isEmpty)
                        .accessibilityIdentifier("guestUpgrade.submitButton")
                    }
                    .padding(24)
                }
            }
            .navigationTitle("Create Account")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }

    private func upgrade() async {
        isSaving = true
        error = nil
        do {
            try await appState.upgradeGuestAccount(email: email, password: password, confirmPassword: confirmPassword)
            dismiss()
        } catch {
            self.error = AppPublicError.message(for: error, context: .settings)
        }
        isSaving = false
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
            Color.hereBackground.ignoresSafeArea()
            VStack(spacing: 20) {
                HereTextField(label: "Display Name", text: $displayName, placeholder: "Your name")
                if let error {
                    Text(error).font(.hereCaption).foregroundStyle(Color.hereError)
                }
                Spacer()
                HereButton(title: "Save", isLoading: isSaving) {
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
        isSaving = true
        error = nil
        do {
            try await appState.updateDisplayName(displayName)
            dismiss()
        } catch {
            self.error = AppPublicError.message(for: error, context: .settings)
        }
        isSaving = false
    }
}

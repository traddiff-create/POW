import SwiftUI

struct AdminUsersView: View {
    @Environment(AppState.self) var appState
    @State private var profiles: [Profile] = []
    @State private var isLoading = true
    @State private var searchText = ""

    var filtered: [Profile] {
        guard !searchText.isEmpty else { return profiles }
        return profiles.filter {
            ($0.displayName ?? "").localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        ZStack {
            Color.powBackground.ignoresSafeArea()
            if isLoading {
                ProgressView()
            } else {
                List(filtered) { profile in
                    NavigationLink(destination: UserDetailView(profile: profile) {
                        Task { await load() }
                    }) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(profile.displayName ?? "No name")
                                .font(.powLabel)
                                .foregroundStyle(Color.powForeground)
                            Text(profile.role.rawValue.capitalized)
                                .font(.powCaption)
                                .foregroundStyle(Color.powMuted)
                        }
                    }
                }
                .searchable(text: $searchText, prompt: "Search by name")
                .scrollContentBackground(.hidden)
                .background(Color.powBackground)
            }
        }
        .navigationTitle("Users")
        .navigationBarTitleDisplayMode(.inline)
        .task { await load() }
    }

    private func load() async {
        isLoading = true
        profiles = (try? await SupabaseService.shared.fetchAllProfiles()) ?? []
        isLoading = false
    }
}

struct UserDetailView: View {
    let profile: Profile
    let onUpdate: () async -> Void
    @Environment(AppState.self) var appState
    @State private var selectedRole: UserRole
    @State private var isUpdating = false
    @State private var error: String?

    init(profile: Profile, onUpdate: @escaping () async -> Void) {
        self.profile = profile
        self.onUpdate = onUpdate
        _selectedRole = State(initialValue: profile.role)
    }

    var body: some View {
        ZStack {
            Color.powBackground.ignoresSafeArea()
            VStack(spacing: 20) {
                POWCard {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(profile.displayName ?? "No name")
                            .font(.powTitle2)
                            .foregroundStyle(Color.powForeground)
                        Text("ID: \(profile.id)")
                            .font(.powCaption)
                            .foregroundStyle(Color.powMuted)
                    }
                    .padding(16)
                }

                POWCard {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Role").font(.powLabel).foregroundStyle(Color.powForeground)
                        Picker("Role", selection: $selectedRole) {
                            ForEach([UserRole.participant, .facilitator, .admin], id: \.self) { role in
                                Text(role.rawValue.capitalized).tag(role)
                            }
                        }
                        .pickerStyle(.segmented)
                    }
                    .padding(16)
                }

                if let error {
                    Text(error).font(.powCaption).foregroundStyle(Color.powError)
                }

                POWButton(title: "Update Role", isLoading: isUpdating) {
                    Task { await updateRole() }
                }

                Spacer()
            }
            .padding(24)
        }
        .navigationTitle("User")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func updateRole() async {
        isUpdating = true
        error = nil
        do {
            try await SupabaseService.shared.updateUserRole(userID: profile.id, role: selectedRole)
            await onUpdate()
        } catch {
            self.error = AppPublicError.message(for: error, context: .management)
        }
        isUpdating = false
    }
}

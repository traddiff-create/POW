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
            Color.hereBackground.ignoresSafeArea()
            if isLoading {
                ProgressView()
            } else {
                List(filtered) { profile in
                    NavigationLink(destination: UserDetailView(profile: profile) {
                        Task { await load() }
                    }) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(profile.displayName ?? "No name")
                                .font(.hereLabel)
                                .foregroundStyle(Color.hereForeground)
                            Text(profile.role.rawValue.capitalized)
                                .font(.hereCaption)
                                .foregroundStyle(Color.hereMuted)
                        }
                    }
                }
                .searchable(text: $searchText, prompt: "Search by name")
                .scrollContentBackground(.hidden)
                .background(Color.hereBackground)
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
            Color.hereBackground.ignoresSafeArea()
            VStack(spacing: 20) {
                HereCard {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(profile.displayName ?? "No name")
                            .font(.hereTitle2)
                            .foregroundStyle(Color.hereForeground)
                        Text("ID: \(profile.id)")
                            .font(.hereCaption)
                            .foregroundStyle(Color.hereMuted)
                    }
                    .padding(16)
                }

                HereCard {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Role").font(.hereLabel).foregroundStyle(Color.hereForeground)
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
                    Text(error).font(.hereCaption).foregroundStyle(Color.hereError)
                }

                HereButton(title: "Update Role", isLoading: isUpdating) {
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

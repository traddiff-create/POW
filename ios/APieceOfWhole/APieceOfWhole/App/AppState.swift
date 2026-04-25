import Foundation
import Supabase

@Observable
@MainActor
final class AppState {
    var session: Session?
    var profile: Profile?
    var activeMembership: CohortMembership?
    var circleID: String?
    var isLoadingSession = true

    var isSignedIn: Bool { session != nil }
    var role: UserRole { profile?.role ?? .participant }
    var hasActiveCohort: Bool { activeMembership != nil }
    var isOnboarded: Bool { profile?.isOnboardingComplete == true }

    func load() async {
        session = try? await SupabaseClient.shared.auth.session
        if let userID = session?.user.id.uuidString {
            profile = try? await SupabaseService.shared.fetchProfile(userID: userID)
            activeMembership = try? await SupabaseService.shared.fetchMembership(userID: userID)
            if let cohortID = activeMembership?.cohortID {
                circleID = try? await SupabaseService.shared.fetchCircleID(userID: userID, cohortID: cohortID)
            }
        }
        isLoadingSession = false
    }

    func signOut() async throws {
        try await AuthService.shared.signOut()
        session = nil
        profile = nil
        activeMembership = nil
    }

    func refreshProfile() async {
        guard let userID = session?.user.id.uuidString else { return }
        profile = try? await SupabaseService.shared.fetchProfile(userID: userID)
    }

    func refreshMembership() async {
        guard let userID = session?.user.id.uuidString else { return }
        activeMembership = try? await SupabaseService.shared.fetchMembership(userID: userID)
    }
}

import Foundation
import Testing
@testable import APieceOfWhole

@Suite("Profile Roles")
@MainActor
struct ProfileRoleTests {
    @Test
    func GivenAdminProfile_WhenLoaded_ThenRoleIsAdminAndCanAccessManagement() async {
        let state = await makeLoadedState(role: .admin)

        #expect(state.role == .admin)
        #expect(state.canAccessManagement)
    }

    @Test
    func GivenFacilitatorProfile_WhenLoaded_ThenCanAccessManagement() async {
        let state = await makeLoadedState(role: .facilitator)

        #expect(state.role == .facilitator)
        #expect(state.canAccessManagement)
    }

    @Test
    func GivenParticipantProfile_WhenLoaded_ThenCannotAccessManagement() async {
        let state = await makeLoadedState(role: .participant)

        #expect(state.role == .participant)
        #expect(state.canAccessManagement == false)
    }

    @Test
    func GivenMissingProfile_WhenLoaded_ThenRoleFallsBackToParticipant() async {
        let auth = MockAuthService()
        let data = MockSupabaseService()
        auth.restoreSessionHandler = { TestData.session() }
        auth.signOutHandler = {}
        data.fetchProfileHandler = { _ in throw MockServiceError.failure }
        data.fetchMembershipHandler = { _ in nil }
        let state = AppState(
            authProvider: auth,
            dataProvider: data,
            profileRetrySleep: { _ in }
        )

        await state.load()

        #expect(data.fetchProfileCallCount == 10)
        #expect(state.session == nil)
        #expect(state.profile == nil)
        #expect(state.role == .participant)
        #expect(state.canAccessManagement == false)
        #expect(state.isLoadingSession == false)
    }

    @Test
    func GivenProfileJSONWithRole_WhenDecoded_ThenRoleParsesCorrectly() throws {
        let json = """
        {
          "id": "\(TestData.userID)",
          "display_name": "Rory Stone",
          "role": "admin",
          "onboarding_completed_at": "\(TestData.timestamp)",
          "created_at": "\(TestData.timestamp)",
          "updated_at": "\(TestData.timestamp)",
          "adult_confirmed_at": "\(TestData.timestamp)",
          "agreements_accepted_at": "\(TestData.timestamp)",
          "onboarding_step": "complete",
          "values": null,
          "gifts_skills": null,
          "current_capacity": null,
          "boundaries": null,
          "current_contribution": null,
          "small_action": null
        }
        """

        let profile = try JSONDecoder().decode(Profile.self, from: Data(json.utf8))

        #expect(profile.role == .admin)
        #expect(profile.isOnboardingComplete)
    }

    private func makeLoadedState(role: UserRole) async -> AppState {
        let auth = MockAuthService()
        let data = MockSupabaseService()
        auth.restoreSessionHandler = { TestData.session() }
        data.fetchProfileHandler = { _ in TestData.profile(role: role) }
        data.fetchMembershipHandler = { _ in nil }

        let state = AppState(authProvider: auth, dataProvider: data)
        await state.load()
        return state
    }
}

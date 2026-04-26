import Clocks
import Testing
@testable import APieceOfWhole

@Suite("AppState")
@MainActor
struct AppStateTests {
    @Test
    func GivenRestorableSession_WhenLoadRuns_ThenSessionProfileMembershipAndCircleAreLoaded() async {
        let session = TestData.session()
        let profile = TestData.profile(role: .facilitator)
        let membership = TestData.membership()
        let auth = MockAuthService()
        let data = MockSupabaseService()
        auth.restoreSessionHandler = { session }
        data.fetchProfileHandler = { userID in
            #expect(userID == TestData.userID)
            return profile
        }
        data.fetchMembershipHandler = { userID in
            #expect(userID == TestData.userID)
            return membership
        }
        data.fetchCircleIDHandler = { userID, cohortID in
            #expect(userID == TestData.userID)
            #expect(cohortID == TestData.cohortID)
            return "circle-1"
        }

        let state = AppState(authProvider: auth, dataProvider: data)
        await state.load()

        #expect(state.isLoadingSession == false)
        #expect(state.session?.user.id == session.user.id)
        #expect(state.profile?.id == profile.id)
        #expect(state.activeMembership?.id == membership.id)
        #expect(state.circleID == "circle-1")
        #expect(state.role == .facilitator)
        #expect(state.canAccessManagement)
    }

    @Test
    func GivenNoSession_WhenLoadRuns_ThenSignedOutStateIsCleared() async {
        let auth = MockAuthService()
        let data = MockSupabaseService()
        auth.restoreSessionHandler = { nil }

        let state = AppState(authProvider: auth, dataProvider: data)
        state.session = TestData.session()
        state.profile = TestData.profile()
        state.activeMembership = TestData.membership()
        state.circleID = "circle-1"

        await state.load()

        #expect(state.isLoadingSession == false)
        #expect(state.session == nil)
        #expect(state.profile == nil)
        #expect(state.activeMembership == nil)
        #expect(state.circleID == nil)
        #expect(state.loadError == nil)
        #expect(state.role == .participant)
        #expect(state.canAccessManagement == false)
    }

    @Test
    func GivenRestoreSessionFails_WhenLoadRuns_ThenAppDoesNotCrashAndClearsLoading() async {
        let auth = MockAuthService()
        let data = MockSupabaseService()
        auth.restoreSessionHandler = { throw MockServiceError.failure }

        let state = AppState(authProvider: auth, dataProvider: data)
        await state.load()

        #expect(state.isLoadingSession == false)
        #expect(state.session == nil)
        #expect(state.profile == nil)
        #expect(state.activeMembership == nil)
        #expect(state.circleID == nil)
        #expect(state.loadError != nil)
    }

    @Test
    func GivenProfileFetchInitiallyFails_WhenClockAdvances_ThenProfileRetryEventuallyLoads() async {
        let clock = TestClock()
        let session = TestData.session()
        let profile = TestData.profile()
        let auth = MockAuthService()
        let data = MockSupabaseService()
        var attempts = 0
        var retryDelays: [Duration] = []
        auth.restoreSessionHandler = { session }
        data.fetchProfileHandler = { _ in
            attempts += 1
            if attempts < 3 {
                throw MockServiceError.failure
            }
            return profile
        }
        data.fetchMembershipHandler = { _ in nil }

        let state = AppState(
            authProvider: auth,
            dataProvider: data,
            profileRetrySleep: { duration in
                retryDelays.append(duration)
                await clock.advance(by: duration)
            }
        )

        await state.load()

        #expect(attempts == 3)
        #expect(data.fetchProfileCallCount == 3)
        #expect(retryDelays == [.milliseconds(100), .milliseconds(200)])
        #expect(clock.now.duration(to: .init(offset: .milliseconds(300))) == .zero)
        #expect(state.profile?.id == profile.id)
        #expect(state.isLoadingSession == false)
    }

    @Test
    func GivenCreateAccountRequiresEmailConfirmation_WhenCreateAccountRuns_ThenSessionAndProfileAreCleared() async throws {
        let existingSession = TestData.session(email: "old@example.test")
        let pendingSession = TestData.session(email: "new@example.test")
        let auth = MockAuthService()
        let data = MockSupabaseService()
        auth.createAccountHandler = { email, password in
            #expect(email == "new@example.test")
            #expect(password == "CorrectHorseBattery1!")
            return SignUpOutcome(user: pendingSession.user, session: nil)
        }

        let state = AppState(authProvider: auth, dataProvider: data)
        state.session = existingSession
        state.profile = TestData.profile()
        state.activeMembership = TestData.membership()
        state.circleID = "circle-1"

        let result = try await state.createAccount(
            email: "  NEW@example.test  ",
            password: "CorrectHorseBattery1!",
            confirmPassword: "CorrectHorseBattery1!"
        )

        #expect(result == .emailConfirmationRequired("new@example.test"))
        #expect(state.session == nil)
        #expect(state.profile == nil)
        #expect(state.activeMembership == nil)
        #expect(state.circleID == nil)
        #expect(state.isLoadingSession == false)
    }

    @Test
    func GivenInvalidSignIn_WhenSignInRuns_ThenAuthErrorIsThrown() async {
        let auth = MockAuthService()
        let data = MockSupabaseService()
        auth.signInHandler = { email, password in
            #expect(email == "rory@example.test")
            #expect(password == "bad-password")
            throw AuthInputError.invalidCredentials
        }

        let state = AppState(authProvider: auth, dataProvider: data)

        do {
            try await state.signIn(email: " RORY@example.test ", password: "bad-password")
            #expect(Bool(false), "Expected invalid credentials to be thrown.")
        } catch let error as AuthInputError {
            #expect(error == .invalidCredentials)
        } catch {
            #expect(Bool(false), "Expected AuthInputError.invalidCredentials, got \(error).")
        }
    }
}

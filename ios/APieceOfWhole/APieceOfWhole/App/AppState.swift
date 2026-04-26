import Foundation
import Observation
import OSLog
import Supabase

@Observable
@MainActor
final class AppState {
    @ObservationIgnored private let authProvider: any AuthProviding
    @ObservationIgnored private let dataProvider: any AppDataProviding
    @ObservationIgnored private let profileRetrySleep: @MainActor (Duration) async throws -> Void
    @ObservationIgnored private let logger = Logger(subsystem: "com.traddifftech.apieceofwhole", category: "AppState")

    var session: Session?
    var profile: Profile?
    var activeMembership: CohortMembership?
    var circleID: String?
    var isLoadingSession = true
    var loadError: String?

    /// One-shot suggestion for ProfileSetupView, populated from Apple's first-sign-in fullName.
    /// Apple only returns this on the first sign-in for a given Apple ID, so we capture it
    /// in memory immediately and let onboarding pre-fill the display name field.
    var pendingDisplayName: String?

    var isSignedIn: Bool { session != nil }
    var isAnonymous: Bool { session?.user.isAnonymous == true }
    var isGuest: Bool { isSignedIn && isAnonymous }
    var role: UserRole { profile?.role ?? .participant }
    var canAccessManagement: Bool { role != .participant }
    var hasActiveCohort: Bool { activeMembership != nil }
    var isOnboarded: Bool { profile?.isOnboardingComplete == true }

    init(
        authProvider: (any AuthProviding)? = nil,
        dataProvider: (any AppDataProviding)? = nil,
        profileRetrySleep: @escaping @MainActor (Duration) async throws -> Void = { duration in
            try await Task.sleep(for: duration)
        }
    ) {
        self.profileRetrySleep = profileRetrySleep

        if let authProvider, let dataProvider {
            self.authProvider = authProvider
            self.dataProvider = dataProvider
            return
        }

        #if DEBUG
        if ProcessInfo.processInfo.arguments.contains(SimulatedAppBackend.launchArgument) {
            let simulated = SimulatedAppBackend.shared
            self.authProvider = simulated
            self.dataProvider = simulated
            return
        }
        #endif

        self.authProvider = AuthService.shared
        self.dataProvider = SupabaseService.shared
    }

    func load() async {
        isLoadingSession = true
        loadError = nil
        profile = nil
        activeMembership = nil
        circleID = nil

        if let configurationError = Config.supabaseConfigurationError {
            loadError = configurationError.localizedDescription
            session = nil
            isLoadingSession = false
            return
        }

        do {
            session = try await authProvider.restoreSession()
        } catch {
            loadError = "Couldn't reach the server. Please check your connection and try again."
            session = nil
            isLoadingSession = false
            return
        }

        if let userID = session?.user.id.uuidString {
            do {
                profile = try await fetchProfileWithRetryOrThrow(userID: userID)
            } catch {
                logger.error("Profile restore failed: \(error.localizedDescription, privacy: .private)")
                loadError = "Couldn't load your profile. Please sign in again."
                try? await authProvider.signOut()
                session = nil
                isLoadingSession = false
                return
            }

            do {
                activeMembership = try await dataProvider.fetchMembership(userID: userID)
            } catch {
                logger.error("Membership restore failed: \(error.localizedDescription, privacy: .private)")
            }

            if let cohortID = activeMembership?.cohortID {
                do {
                    circleID = try await dataProvider.fetchCircleID(userID: userID, cohortID: cohortID)
                } catch {
                    logger.error("Circle restore failed: \(error.localizedDescription, privacy: .private)")
                }
            }
        }
        isLoadingSession = false
    }

    @discardableResult
    func createAccount(email rawEmail: String, password: String, confirmPassword: String) async throws -> AccountCreationResult {
        let email = AuthInputNormalizer.normalizedEmail(rawEmail)
        guard !email.isEmpty else { throw AuthInputError.emailRequired }
        guard !password.isEmpty else { throw AuthInputError.passwordRequired }
        guard password == confirmPassword else { throw AuthInputError.passwordMismatch }

        let outcome = try await authProvider.createAccount(email: email, password: password)
        guard outcome.session != nil else {
            session = nil
            profile = nil
            activeMembership = nil
            circleID = nil
            isLoadingSession = false
            return .emailConfirmationRequired(email)
        }

        await load()
        return .signedIn
    }

    func signIn(email rawEmail: String, password: String) async throws {
        let email = AuthInputNormalizer.normalizedEmail(rawEmail)
        guard !email.isEmpty else { throw AuthInputError.emailRequired }
        guard !password.isEmpty else { throw AuthInputError.passwordRequired }
        _ = try await authProvider.signIn(email: email, password: password)
        await load()
    }

    func upgradeGuestAccount(email rawEmail: String, password: String, confirmPassword: String) async throws {
        let email = AuthInputNormalizer.normalizedEmail(rawEmail)
        guard !email.isEmpty else { throw AuthInputError.emailRequired }
        guard !password.isEmpty else { throw AuthInputError.passwordRequired }
        guard password == confirmPassword else { throw AuthInputError.passwordMismatch }
        do {
            _ = try await authProvider.upgradeAnonymousAccount(email: email, password: password)
        } catch {
            if isExistingEmailError(error) {
                throw AuthInputError.emailAlreadyExists
            }
            throw error
        }
        await load()
    }

    func signInWithApple(credential: AppleIDCredentialPayload) async throws {
        _ = try await authProvider.signInWithApple(
            identityToken: credential.identityToken,
            rawNonce: credential.rawNonce
        )
        if let suggestedName = credential.displayName {
            pendingDisplayName = suggestedName
        }
        await load()
    }

    func consumePendingDisplayName() -> String? {
        let name = pendingDisplayName
        pendingDisplayName = nil
        return name
    }

    func continueAsGuest() async throws {
        _ = try await authProvider.signInAnonymously()
        await load()
        if let userID = session?.user.id.uuidString {
            profile = await fetchProfileWithRetry(userID: userID)
        }
        activeMembership = nil
        circleID = nil
        isLoadingSession = false
    }

    func signOut() async throws {
        try await authProvider.signOut()
        session = nil
        profile = nil
        activeMembership = nil
        circleID = nil
    }

    func refreshProfile() async {
        guard let userID = session?.user.id.uuidString else { return }
        profile = await fetchProfileWithRetry(userID: userID)
    }

    func refreshMembership() async {
        guard let userID = session?.user.id.uuidString else { return }
        activeMembership = try? await dataProvider.fetchMembership(userID: userID)
    }

    func confirmAdult() async throws {
        guard let userID = session?.user.id.uuidString else { throw AppDataError.missingSession }
        try await dataProvider.updateOnboardingAgeConfirm(userID: userID)
        await refreshProfile()
    }

    func acceptAgreements() async throws {
        guard let userID = session?.user.id.uuidString else { throw AppDataError.missingSession }
        try await dataProvider.updateOnboardingAgreements(userID: userID)
        await refreshProfile()
    }

    func completeOnboarding(displayName rawDisplayName: String) async throws {
        guard let userID = session?.user.id.uuidString else { throw AppDataError.missingSession }
        let displayName = rawDisplayName.trimmingCharacters(in: .whitespacesAndNewlines)
        try await dataProvider.updateOnboardingProfile(
            userID: userID,
            displayName: displayName.isEmpty ? "Guest" : displayName
        )
        await refreshProfile()
    }

    func updateDisplayName(_ rawDisplayName: String) async throws {
        guard let userID = session?.user.id.uuidString else { throw AppDataError.missingSession }
        let displayName = rawDisplayName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !displayName.isEmpty else { throw AppDataError.missingProfile }
        try await dataProvider.updateOnboardingProfile(userID: userID, displayName: displayName)
        await refreshProfile()
    }

    func fetchOpenCohorts() async throws -> [Cohort] {
        try await dataProvider.fetchOpenCohorts()
    }

    func fetchApplicationsForCurrentUser() async throws -> [CohortApplication] {
        guard let userID = session?.user.id.uuidString else { throw AppDataError.missingSession }
        return try await dataProvider.fetchApplications(userID: userID)
    }

    func submitApplication(
        cohort: Cohort,
        motivation: String,
        howHeard: String,
        hopedChange: String,
        weeklyCapacity: Int,
        groupComfort: Int,
        agreementsAccepted: Bool,
        safetyAcknowledged: Bool
    ) async throws -> CohortApplication {
        guard let email = session?.user.email else { throw AppDataError.missingSession }
        guard let userID = session?.user.id.uuidString else { throw AppDataError.missingSession }
        guard let displayName = profile?.displayName, !displayName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw AppDataError.missingProfile
        }

        let submission = ApplicationSubmission(
            userID: userID,
            cohortID: cohort.id,
            applicantName: displayName,
            applicantEmail: email,
            motivation: motivation.trimmingCharacters(in: .whitespacesAndNewlines),
            howHeard: howHeard.trimmingCharacters(in: .whitespacesAndNewlines),
            hopedChange: hopedChange.trimmingCharacters(in: .whitespacesAndNewlines),
            weeklyCapacityHours: weeklyCapacity,
            groupComfortLevel: groupComfort,
            agreementsAccepted: agreementsAccepted,
            safetyAcknowledged: safetyAcknowledged
        )
        return try await dataProvider.submitApplication(submission)
    }

    private func fetchProfileWithRetry(userID: String) async -> Profile? {
        try? await fetchProfileWithRetryOrThrow(userID: userID)
    }

    private func fetchProfileWithRetryOrThrow(userID: String) async throws -> Profile {
        var lastError: Error?

        for attempt in 0..<10 {
            do {
                let profile = try await dataProvider.fetchProfile(userID: userID)
                return profile
            } catch {
                lastError = error
            }

            if attempt < 9 {
                let delayMilliseconds = min(1_600, 100 * (1 << attempt))
                try? await profileRetrySleep(.milliseconds(delayMilliseconds))
            }
        }

        throw lastError ?? AppDataError.missingProfile
    }

    private func isExistingEmailError(_ error: Error) -> Bool {
        guard let authError = error as? AuthError else {
            return false
        }

        return authError.errorCode == .emailExists
            || authError.errorCode == .userAlreadyExists
            || authError.message.localizedCaseInsensitiveContains("already")
    }
}

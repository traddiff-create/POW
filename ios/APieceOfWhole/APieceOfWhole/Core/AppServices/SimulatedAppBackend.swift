#if DEBUG
import Foundation
import Supabase

@MainActor
final class SimulatedAppBackend: AuthProviding, AppDataProviding {
    static let shared = SimulatedAppBackend()

    static let launchArgument = "--simulate-auth-flow"
    static let onboardingFailureArgument = "--simulate-onboarding-failure"
    static let email = "qa+join@example.test"
    static let password = "CorrectHorseBattery1!"
    static let displayName = "QA Joiner"
    static let cohortName = "Here 8-Week Test Cohort"

    private static let userUUID = UUID(uuidString: "11111111-1111-4111-8111-111111111111") ?? UUID()
    private static let cohortID = "22222222-2222-4222-8222-222222222222"
    private static let applicationID = "33333333-3333-4333-8333-333333333333"

    private var session: Session?
    private var email = SimulatedAppBackend.email
    private var password = SimulatedAppBackend.password
    private var profile: Profile
    private var applications: [CohortApplication] = []
    private var shouldFailOnboarding: Bool {
        ProcessInfo.processInfo.arguments.contains(Self.onboardingFailureArgument)
    }

    private init() {
        let now = Self.timestamp()
        profile = Profile(
            id: Self.userUUID.uuidString,
            displayName: nil,
            role: .participant,
            onboardingCompletedAt: nil,
            createdAt: now,
            updatedAt: now,
            adultConfirmedAt: nil,
            agreementsAcceptedAt: nil,
            onboardingStep: OnboardingStep.ageConfirm.rawValue,
            values: nil,
            giftsSkills: nil,
            currentCapacity: nil,
            boundaries: nil,
            currentContribution: nil,
            smallAction: nil
        )
    }

    func restoreSession() async throws -> Session? {
        session
    }

    func createAccount(email: String, password: String) async throws -> SignUpOutcome {
        self.email = email
        self.password = password
        profile = makeProfile(displayName: nil, step: .ageConfirm)
        applications = []
        let session = makeSession(email: email)
        self.session = session
        return SignUpOutcome(user: session.user, session: session)
    }

    func signIn(email: String, password: String) async throws -> Session {
        guard email == self.email, password == self.password else {
            throw AuthInputError.invalidCredentials
        }
        let session = makeSession(email: email)
        self.session = session
        return session
    }

    func signInAnonymously() async throws -> Session {
        let session = makeSession(email: nil, isAnonymous: true)
        self.session = session
        profile = makeProfile(displayName: "Guest", step: .complete)
        return session
    }

    func upgradeAnonymousAccount(email: String, password: String) async throws -> User {
        self.email = email
        self.password = password
        let session = makeSession(email: email)
        self.session = session
        return session.user
    }

    func signInWithApple(identityToken: String, rawNonce: String) async throws -> Session {
        // Simulated Apple sign-in: ignore the token and produce a deterministic signed-in session.
        let appleEmail = "qa+apple@example.test"
        self.email = appleEmail
        self.password = "" // Apple-only accounts have no password locally.
        profile = makeProfile(displayName: nil, step: .ageConfirm)
        applications = []
        let session = makeSession(email: appleEmail)
        self.session = session
        return session
    }

    func signOut() async throws {
        session = nil
    }

    func fetchProfile(userID: String) async throws -> Profile {
        guard userID == profile.id else { throw AppDataError.missingProfile }
        return profile
    }

    func updateOnboardingAgeConfirm(userID: String) async throws {
        guard userID == profile.id else { throw AppDataError.missingProfile }
        if shouldFailOnboarding { throw AppDataError.simulatedFailure }
        let timestamp = Self.timestamp()
        profile.adultConfirmedAt = timestamp
        profile.onboardingStep = OnboardingStep.agreements.rawValue
        profile.updatedAt = timestamp
    }

    func updateOnboardingAgreements(userID: String) async throws {
        guard userID == profile.id else { throw AppDataError.missingProfile }
        let timestamp = Self.timestamp()
        profile.agreementsAcceptedAt = timestamp
        profile.onboardingStep = OnboardingStep.profileSetup.rawValue
        profile.updatedAt = timestamp
    }

    func updateOnboardingProfile(userID: String, displayName: String) async throws {
        guard userID == profile.id else { throw AppDataError.missingProfile }
        let timestamp = Self.timestamp()
        profile.displayName = displayName
        profile.onboardingStep = OnboardingStep.complete.rawValue
        profile.onboardingCompletedAt = timestamp
        profile.updatedAt = timestamp
    }

    func fetchOpenCohorts() async throws -> [Cohort] {
        [
            Cohort(
                id: Self.cohortID,
                name: Self.cohortName,
                slug: "here-8-week-test",
                description: "A safe simulated cohort for account setup and join flow testing.",
                startDate: "2026-05-01",
                endDate: "2026-06-26",
                maxParticipants: 12,
                priceCents: 19900,
                isOpen: true,
                storeKitProductID: Config.storeKitProductID,
                createdAt: Self.timestamp()
            )
        ]
    }

    func fetchApplications(userID: String) async throws -> [CohortApplication] {
        guard userID == profile.id else { return [] }
        return applications
    }

    func submitApplication(_ submission: ApplicationSubmission) async throws -> CohortApplication {
        let application = CohortApplication(
            id: Self.applicationID,
            cohortID: submission.cohortID,
            applicantName: submission.applicantName,
            applicantEmail: submission.applicantEmail,
            motivation: submission.motivation,
            howHeard: submission.howHeard,
            status: .pending,
            createdAt: Self.timestamp(),
            reviewedAt: nil,
            reviewedBy: nil,
            hopedChange: submission.hopedChange,
            weeklyCapacityHours: submission.weeklyCapacityHours,
            groupComfortLevel: submission.groupComfortLevel,
            agreementsAccepted: submission.agreementsAccepted,
            safetyAcknowledged: submission.safetyAcknowledged
        )
        applications.removeAll { $0.cohortID == submission.cohortID }
        applications.append(application)
        return application
    }

    func fetchMembership(userID: String) async throws -> CohortMembership? {
        nil
    }

    func fetchCircleID(userID: String, cohortID: String) async throws -> String? {
        nil
    }

    private func makeProfile(displayName: String?, step: OnboardingStep) -> Profile {
        let now = Self.timestamp()
        return Profile(
            id: Self.userUUID.uuidString,
            displayName: displayName,
            role: .participant,
            onboardingCompletedAt: step == .complete ? now : nil,
            createdAt: now,
            updatedAt: now,
            adultConfirmedAt: nil,
            agreementsAcceptedAt: nil,
            onboardingStep: step.rawValue,
            values: nil,
            giftsSkills: nil,
            currentCapacity: nil,
            boundaries: nil,
            currentContribution: nil,
            smallAction: nil
        )
    }

    private func makeSession(email: String?, isAnonymous: Bool = false) -> Session {
        let now = Date()
        let user = User(
            id: Self.userUUID,
            appMetadata: [:],
            userMetadata: [:],
            aud: "authenticated",
            email: email,
            createdAt: now,
            confirmedAt: now,
            emailConfirmedAt: email == nil ? nil : now,
            lastSignInAt: now,
            role: "authenticated",
            updatedAt: now,
            isAnonymous: isAnonymous
        )

        return Session(
            accessToken: "simulated-access-token",
            tokenType: "bearer",
            expiresIn: 3600,
            expiresAt: now.addingTimeInterval(3600).timeIntervalSince1970,
            refreshToken: "simulated-refresh-token",
            user: user
        )
    }

    private static func timestamp() -> String {
        ISO8601DateFormatter().string(from: Date())
    }
}
#endif

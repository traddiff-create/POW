import Foundation
import IssueReporting
import Supabase
@testable import APieceOfWhole

enum MockServiceError: Error, Equatable {
    case failure
}

@MainActor
final class MockAuthService: AuthProviding {
    var restoreSessionHandler: () async throws -> Session? = unimplemented("MockAuthService.restoreSession")
    var createAccountHandler: (String, String) async throws -> SignUpOutcome = unimplemented("MockAuthService.createAccount")
    var signInHandler: (String, String) async throws -> Session = unimplemented("MockAuthService.signIn")
    var signInAnonymouslyHandler: () async throws -> Session = unimplemented("MockAuthService.signInAnonymously")
    var upgradeAnonymousAccountHandler: (String, String) async throws -> User = unimplemented("MockAuthService.upgradeAnonymousAccount")
    var signInWithAppleHandler: (String, String) async throws -> Session = unimplemented("MockAuthService.signInWithApple")
    var signOutHandler: () async throws -> Void = unimplemented("MockAuthService.signOut")

    func restoreSession() async throws -> Session? {
        try await restoreSessionHandler()
    }

    func createAccount(email: String, password: String) async throws -> SignUpOutcome {
        try await createAccountHandler(email, password)
    }

    func signIn(email: String, password: String) async throws -> Session {
        try await signInHandler(email, password)
    }

    func signInAnonymously() async throws -> Session {
        try await signInAnonymouslyHandler()
    }

    func upgradeAnonymousAccount(email: String, password: String) async throws -> User {
        try await upgradeAnonymousAccountHandler(email, password)
    }

    func signInWithApple(identityToken: String, rawNonce: String) async throws -> Session {
        try await signInWithAppleHandler(identityToken, rawNonce)
    }

    func signOut() async throws {
        try await signOutHandler()
    }
}

@MainActor
final class MockSupabaseService: AppDataProviding {
    var fetchProfileHandler: (String) async throws -> Profile = unimplemented("MockSupabaseService.fetchProfile")
    var updateOnboardingAgeConfirmHandler: (String) async throws -> Void = unimplemented("MockSupabaseService.updateOnboardingAgeConfirm")
    var updateOnboardingAgreementsHandler: (String) async throws -> Void = unimplemented("MockSupabaseService.updateOnboardingAgreements")
    var updateOnboardingProfileHandler: (String, String) async throws -> Void = unimplemented("MockSupabaseService.updateOnboardingProfile")
    var fetchOpenCohortsHandler: () async throws -> [Cohort] = unimplemented("MockSupabaseService.fetchOpenCohorts")
    var fetchApplicationsHandler: (String) async throws -> [CohortApplication] = unimplemented("MockSupabaseService.fetchApplications")
    var submitApplicationHandler: (ApplicationSubmission) async throws -> CohortApplication = unimplemented("MockSupabaseService.submitApplication")
    var fetchMembershipHandler: (String) async throws -> CohortMembership? = unimplemented("MockSupabaseService.fetchMembership")
    var fetchCircleIDHandler: (String, String) async throws -> String? = unimplemented("MockSupabaseService.fetchCircleID")

    private(set) var fetchProfileCallCount = 0
    private(set) var submittedApplications: [ApplicationSubmission] = []

    func fetchProfile(userID: String) async throws -> Profile {
        fetchProfileCallCount += 1
        return try await fetchProfileHandler(userID)
    }

    func updateOnboardingAgeConfirm(userID: String) async throws {
        try await updateOnboardingAgeConfirmHandler(userID)
    }

    func updateOnboardingAgreements(userID: String) async throws {
        try await updateOnboardingAgreementsHandler(userID)
    }

    func updateOnboardingProfile(userID: String, displayName: String) async throws {
        try await updateOnboardingProfileHandler(userID, displayName)
    }

    func fetchOpenCohorts() async throws -> [Cohort] {
        try await fetchOpenCohortsHandler()
    }

    func fetchApplications(userID: String) async throws -> [CohortApplication] {
        try await fetchApplicationsHandler(userID)
    }

    func submitApplication(_ submission: ApplicationSubmission) async throws -> CohortApplication {
        submittedApplications.append(submission)
        return try await submitApplicationHandler(submission)
    }

    func fetchMembership(userID: String) async throws -> CohortMembership? {
        try await fetchMembershipHandler(userID)
    }

    func fetchCircleID(userID: String, cohortID: String) async throws -> String? {
        try await fetchCircleIDHandler(userID, cohortID)
    }
}

enum TestData {
    static let userID = "11111111-1111-4111-8111-111111111111"
    static let cohortID = "22222222-2222-4222-8222-222222222222"
    static let membershipID = "33333333-3333-4333-8333-333333333333"
    static let applicationID = "44444444-4444-4444-8444-444444444444"
    static let timestamp = "2026-04-25T12:00:00Z"

    static func session(
        userID: String = userID,
        email: String? = "rory@example.test",
        isAnonymous: Bool = false
    ) -> Session {
        let now = Date(timeIntervalSince1970: 1_777_116_800)
        let user = User(
            id: UUID(uuidString: userID) ?? UUID(),
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
            accessToken: "test-access-token",
            tokenType: "bearer",
            expiresIn: 3_600,
            expiresAt: now.addingTimeInterval(3_600).timeIntervalSince1970,
            refreshToken: "test-refresh-token",
            user: user
        )
    }

    static func profile(
        id: String = userID,
        displayName: String? = "Rory Stone",
        role: UserRole = .participant,
        onboardingCompletedAt: String? = timestamp,
        onboardingStep: String? = OnboardingStep.complete.rawValue
    ) -> Profile {
        Profile(
            id: id,
            displayName: displayName,
            role: role,
            onboardingCompletedAt: onboardingCompletedAt,
            createdAt: timestamp,
            updatedAt: timestamp,
            adultConfirmedAt: timestamp,
            agreementsAcceptedAt: timestamp,
            onboardingStep: onboardingStep,
            values: nil,
            giftsSkills: nil,
            currentCapacity: nil,
            boundaries: nil,
            currentContribution: nil,
            smallAction: nil
        )
    }

    static func membership(
        id: String = membershipID,
        userID: String = userID,
        cohortID: String = cohortID
    ) -> CohortMembership {
        CohortMembership(
            id: id,
            userID: userID,
            cohortID: cohortID,
            paymentID: nil,
            enrolledAt: timestamp
        )
    }

    static func cohort(id: String = cohortID, name: String = "Here Test Cohort") -> Cohort {
        Cohort(
            id: id,
            name: name,
            slug: "here-test-cohort",
            description: "A test cohort.",
            startDate: "2026-05-01",
            endDate: "2026-06-26",
            maxParticipants: 12,
            priceCents: 19_900,
            isOpen: true,
            storeKitProductID: "apow.cohort.8week",
            createdAt: timestamp
        )
    }

    static func application(from submission: ApplicationSubmission) -> CohortApplication {
        CohortApplication(
            id: applicationID,
            cohortID: submission.cohortID,
            applicantName: submission.applicantName,
            applicantEmail: submission.applicantEmail,
            motivation: submission.motivation,
            howHeard: submission.howHeard,
            status: .pending,
            createdAt: timestamp,
            reviewedAt: nil,
            reviewedBy: nil,
            hopedChange: submission.hopedChange,
            weeklyCapacityHours: submission.weeklyCapacityHours,
            groupComfortLevel: submission.groupComfortLevel,
            agreementsAccepted: submission.agreementsAccepted,
            safetyAcknowledged: submission.safetyAcknowledged
        )
    }
}

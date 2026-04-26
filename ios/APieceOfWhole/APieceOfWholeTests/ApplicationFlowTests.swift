import Testing
@testable import APieceOfWhole

@Suite("Application Flow")
@MainActor
struct ApplicationFlowTests {
    @Test
    func GivenOpenCohorts_WhenFetched_ThenMockCohortsAreReturned() async throws {
        let expected = [
            TestData.cohort(id: "22222222-2222-4222-8222-222222222222", name: "Spring Cohort"),
            TestData.cohort(id: "55555555-5555-4555-8555-555555555555", name: "Summer Cohort")
        ]
        let auth = MockAuthService()
        let data = MockSupabaseService()
        data.fetchOpenCohortsHandler = { expected }

        let state = AppState(authProvider: auth, dataProvider: data)
        let cohorts = try await state.fetchOpenCohorts()

        #expect(cohorts.count == 2)
        #expect(cohorts.map(\.name) == ["Spring Cohort", "Summer Cohort"])
    }

    @Test
    func GivenMissingSession_WhenSubmittingApplication_ThenMissingSessionErrorIsThrown() async {
        let auth = MockAuthService()
        let data = MockSupabaseService()
        let state = AppState(authProvider: auth, dataProvider: data)

        do {
            _ = try await state.submitApplication(
                cohort: TestData.cohort(),
                motivation: "I want steadier practice.",
                howHeard: "Newsletter",
                hopedChange: "More grounded participation.",
                weeklyCapacity: 3,
                groupComfort: 4,
                agreementsAccepted: true,
                safetyAcknowledged: true
            )
            #expect(Bool(false), "Expected missing session to be thrown.")
        } catch AppDataError.missingSession {
            #expect(true)
        } catch {
            #expect(Bool(false), "Expected AppDataError.missingSession, got \(error).")
        }
    }

    @Test
    func GivenMissingProfile_WhenSubmittingApplication_ThenMissingProfileErrorIsThrown() async {
        let auth = MockAuthService()
        let data = MockSupabaseService()
        let state = AppState(authProvider: auth, dataProvider: data)
        state.session = TestData.session()

        do {
            _ = try await state.submitApplication(
                cohort: TestData.cohort(),
                motivation: "I want steadier practice.",
                howHeard: "Newsletter",
                hopedChange: "More grounded participation.",
                weeklyCapacity: 3,
                groupComfort: 4,
                agreementsAccepted: true,
                safetyAcknowledged: true
            )
            #expect(Bool(false), "Expected missing profile to be thrown.")
        } catch AppDataError.missingProfile {
            #expect(true)
        } catch {
            #expect(Bool(false), "Expected AppDataError.missingProfile, got \(error).")
        }
    }

    @Test
    func GivenValidApplication_WhenSubmitting_ThenPayloadIsTrimmedAndStored() async throws {
        let auth = MockAuthService()
        let data = MockSupabaseService()
        data.submitApplicationHandler = { submission in
            TestData.application(from: submission)
        }

        let state = AppState(authProvider: auth, dataProvider: data)
        state.session = TestData.session(email: "rory@example.test")
        state.profile = TestData.profile(displayName: "Rory Stone")

        let application = try await state.submitApplication(
            cohort: TestData.cohort(),
            motivation: "  I want to practice steadier participation.  ",
            howHeard: "  A friend  ",
            hopedChange: "  More grounded contribution.  ",
            weeklyCapacity: 4,
            groupComfort: 5,
            agreementsAccepted: true,
            safetyAcknowledged: true
        )

        let submission = try #require(data.submittedApplications.first)
        #expect(data.submittedApplications.count == 1)
        #expect(submission.userID == TestData.userID)
        #expect(submission.cohortID == TestData.cohortID)
        #expect(submission.applicantName == "Rory Stone")
        #expect(submission.applicantEmail == "rory@example.test")
        #expect(submission.motivation == "I want to practice steadier participation.")
        #expect(submission.howHeard == "A friend")
        #expect(submission.hopedChange == "More grounded contribution.")
        #expect(submission.weeklyCapacityHours == 4)
        #expect(submission.groupComfortLevel == 5)
        #expect(submission.agreementsAccepted)
        #expect(submission.safetyAcknowledged)
        #expect(application.status == .pending)
        #expect(application.motivation == submission.motivation)
    }
}

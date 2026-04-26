import Foundation
import Testing
@testable import APieceOfWhole

@Suite("Here Practice Models")
struct HerePracticeTests {
    @Test
    func GivenHereLegs_WhenRead_ThenUseExpectedDatabaseValues() {
        #expect(HereLeg.selfFoundation.rawValue == "self")
        #expect(HereLeg.together.rawValue == "together")
        #expect(HereLeg.community.rawValue == "community")
        #expect(HereLeg.allCases.map(\.title) == ["Self", "Together", "Community"])
    }

    @Test
    func GivenDailyPracticeSubmission_WhenEncoded_ThenUsesSnakeCasePayload() throws {
        let submission = DailyPracticeSubmission(
            userID: TestData.userID,
            leg: .together,
            promptID: "together.daily.grounding-presence",
            promptTitle: "Be a grounding presence",
            privateReflection: "Listened before fixing.",
            practiceDate: "2026-04-26"
        )

        let payload = try encodedDictionary(submission)

        #expect(payload["user_id"] as? String == TestData.userID)
        #expect(payload["leg"] as? String == "together")
        #expect(payload["prompt_id"] as? String == "together.daily.grounding-presence")
        #expect(payload["prompt_title"] as? String == "Be a grounding presence")
        #expect(payload["private_reflection"] as? String == "Listened before fixing.")
        #expect(payload["practice_date"] as? String == "2026-04-26")
    }

    @Test
    func GivenSharedReflectionSubmission_WhenEncoded_ThenContainsOnlyOwnedExcerptFields() throws {
        let submission = SharedReflectionExcerptSubmission(
            userID: TestData.userID,
            sourceType: .application,
            leg: .community,
            excerpt: "I came here to practice steadier local care.",
            isActive: true
        )

        let payload = try encodedDictionary(submission)

        #expect(payload["user_id"] as? String == TestData.userID)
        #expect(payload["source_type"] as? String == "application")
        #expect(payload["leg"] as? String == "community")
        #expect(payload["excerpt"] as? String == "I came here to practice steadier local care.")
        #expect(payload["is_active"] as? Bool == true)
        #expect(payload["applicant_email"] == nil)
        #expect(payload["application_id"] == nil)
    }

    @Test
    func GivenPublicSharedReflectionExcerpt_WhenDecoded_ThenContainsNoDatabaseIdentity() throws {
        let data = """
        {
          "excerpt": "I came here to practice steadier local care.",
          "source_type": "application",
          "leg": "community",
          "created_at": "2026-04-26T18:00:00Z"
        }
        """.data(using: .utf8) ?? Data()

        let excerpt = try JSONDecoder().decode(PublicSharedReflectionExcerpt.self, from: data)

        #expect(excerpt.excerpt == "I came here to practice steadier local care.")
        #expect(excerpt.sourceType == .application)
        #expect(excerpt.leg == .community)
        #expect(excerpt.createdAt == "2026-04-26T18:00:00Z")
    }

    @Test
    func GivenDate_WhenFormattedForPractice_ThenUsesDatabaseDateFormat() {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0) ?? .gmt
        let date = Date(timeIntervalSince1970: 1_777_161_600)

        #expect(SupabaseService.practiceDateString(for: date, calendar: calendar) == "2026-04-26")
    }

    private func encodedDictionary<T: Encodable>(_ value: T) throws -> [String: Any] {
        let data = try JSONEncoder().encode(value)
        let object = try JSONSerialization.jsonObject(with: data)
        return try #require(object as? [String: Any])
    }
}

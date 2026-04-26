import Foundation

enum HereLeg: String, Codable, CaseIterable, Identifiable, Sendable {
    case selfFoundation = "self"
    case together
    case community

    var id: String { rawValue }

    var title: String {
        switch self {
        case .selfFoundation: return "Self"
        case .together: return "Together"
        case .community: return "Community"
        }
    }

    var subtitle: String {
        switch self {
        case .selfFoundation: return "The foundation"
        case .together: return "The soul"
        case .community: return "The invitation outward"
        }
    }

    var systemImage: String {
        switch self {
        case .selfFoundation: return "figure.mind.and.body"
        case .together: return "person.2"
        case .community: return "leaf"
        }
    }
}

struct HerePrompt: Identifiable, Equatable, Sendable {
    let id: String
    let leg: HereLeg
    let title: String
    let body: String
    let placeholder: String
}

enum HerePromptCatalog {
    static let dailyPrompts: [HereLeg: HerePrompt] = [
        .selfFoundation: HerePrompt(
            id: "self.daily.regulate",
            leg: .selfFoundation,
            title: "Return to yourself",
            body: "Pause for one breath, one body cue, and one honest sentence. Self-regulation is not self-control; it is knowing how to come back.",
            placeholder: "What helped you come back to yourself today?"
        ),
        .together: HerePrompt(
            id: "together.daily.grounding-presence",
            leg: .together,
            title: "Be a grounding presence",
            body: "Offer one person steadiness: softer shoulders, slower breath, clearer listening, or a kind check-in.",
            placeholder: "Who did you practice steadiness with?"
        ),
        .community: HerePrompt(
            id: "community.daily.local-intention",
            leg: .community,
            title: "Step outward locally",
            body: "Notice your neighborhood, the land, or one nearby person. Choose one small intention that can accumulate over time.",
            placeholder: "What local intention did you practice?"
        )
    ]

    static func dailyPrompt(for leg: HereLeg) -> HerePrompt {
        dailyPrompts[leg] ?? HerePrompt(
            id: "\(leg.rawValue).daily.default",
            leg: leg,
            title: leg.title,
            body: leg.subtitle,
            placeholder: "What did you notice?"
        )
    }
}

struct DailyPracticeEntry: Codable, Identifiable, Sendable {
    let id: String
    let userID: String
    let leg: HereLeg
    let promptID: String
    let promptTitle: String
    let privateReflection: String?
    let practiceDate: String
    let createdAt: String
    let updatedAt: String

    enum CodingKeys: String, CodingKey {
        case id
        case userID = "user_id"
        case leg
        case promptID = "prompt_id"
        case promptTitle = "prompt_title"
        case privateReflection = "private_reflection"
        case practiceDate = "practice_date"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

struct DailyPracticeSubmission: Encodable, Equatable, Sendable {
    let userID: String
    let leg: HereLeg
    let promptID: String
    let promptTitle: String
    let privateReflection: String?
    let practiceDate: String

    enum CodingKeys: String, CodingKey {
        case userID = "user_id"
        case leg
        case promptID = "prompt_id"
        case promptTitle = "prompt_title"
        case privateReflection = "private_reflection"
        case practiceDate = "practice_date"
    }
}

enum SharedReflectionSourceType: String, Codable, Sendable {
    case application
    case dailyPractice = "daily_practice"
    case communityIntention = "community_intention"
}

struct SharedReflectionExcerpt: Codable, Identifiable, Sendable {
    let id: String
    let userID: String
    let sourceType: SharedReflectionSourceType
    let leg: HereLeg
    var excerpt: String
    var isActive: Bool
    let createdAt: String
    let updatedAt: String

    enum CodingKeys: String, CodingKey {
        case id
        case userID = "user_id"
        case sourceType = "source_type"
        case leg
        case excerpt
        case isActive = "is_active"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

struct SharedReflectionExcerptSubmission: Encodable, Equatable, Sendable {
    let userID: String
    let sourceType: SharedReflectionSourceType
    let leg: HereLeg
    let excerpt: String
    let isActive: Bool

    enum CodingKeys: String, CodingKey {
        case userID = "user_id"
        case sourceType = "source_type"
        case leg
        case excerpt
        case isActive = "is_active"
    }
}

struct PublicSharedReflectionExcerpt: Codable, Identifiable, Sendable {
    let excerpt: String
    let sourceType: SharedReflectionSourceType
    let leg: HereLeg
    let createdAt: String

    var id: String { "\(sourceType.rawValue)-\(leg.rawValue)-\(createdAt)-\(excerpt)" }

    enum CodingKeys: String, CodingKey {
        case excerpt
        case sourceType = "source_type"
        case leg
        case createdAt = "created_at"
    }
}

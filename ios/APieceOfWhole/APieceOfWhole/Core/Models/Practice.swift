import Foundation

// Maps to `practices` table
struct Practice: Codable, Identifiable, Sendable {
    let id: String
    var title: String
    var subtitle: String?
    var category: String?
    var layers: [String]?
    var weekNumber: Int?
    var durationMinutes: Int?
    var hasAudio: Bool
    var audioPath: String?
    var audioSource: String?
    var bodyText: String?
    var sourceID: String?
    var sourceKind: String?
    var tags: [String]?
    var useCases: [String]?
    var evidenceLevel: String?
    var riskLevel: String?
    var riskNote: String?
    var iconName: String?
    var isAdvanced: Bool?
    var sortOrder: Int?
    var published: Bool?
    var createdAt: String

    enum CodingKeys: String, CodingKey {
        case id, title, subtitle, category, layers, tags
        case weekNumber = "week_number"
        case durationMinutes = "duration_minutes"
        case hasAudio = "has_audio"
        case audioPath = "audio_path"
        case audioSource = "audio_source"
        case bodyText = "body_text"
        case sourceID = "source_id"
        case sourceKind = "source_kind"
        case useCases = "use_cases"
        case evidenceLevel = "evidence_level"
        case riskLevel = "risk_level"
        case riskNote = "risk_note"
        case iconName = "icon_name"
        case isAdvanced = "is_advanced"
        case sortOrder = "sort_order"
        case published
        case createdAt = "created_at"
    }

    var layerValues: [String] {
        if let layers, !layers.isEmpty { return layers }
        return category.map { [$0] } ?? []
    }
}

// Maps to `civic_lessons` table
struct CivicLesson: Codable, Identifiable, Sendable {
    let id: String
    var title: String
    var category: String?
    var estimatedMinutes: Int?
    var bodyText: String?
    var reflectionPrompt: String?
    var orderIndex: Int?
    var createdAt: String

    enum CodingKeys: String, CodingKey {
        case id, title, category
        case estimatedMinutes = "estimated_minutes"
        case bodyText = "body_text"
        case reflectionPrompt = "reflection_prompt"
        case orderIndex = "order_index"
        case createdAt = "created_at"
    }
}

// Maps to `cohort_curriculum` table
struct CurriculumItem: Codable, Identifiable, Sendable {
    let id: String
    var cohortID: String?
    var weekNumber: Int
    var title: String
    var theme: String?
    var circlePrompt: String?

    enum CodingKeys: String, CodingKey {
        case id
        case cohortID = "cohort_id"
        case weekNumber = "week_number"
        case title, theme
        case circlePrompt = "circle_prompt"
    }
}

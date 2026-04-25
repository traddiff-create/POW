import Foundation

// Maps to `practices` table
struct Practice: Codable, Identifiable, Sendable {
    let id: String
    var title: String
    var category: String?
    var weekNumber: Int?
    var durationMinutes: Int?
    var hasAudio: Bool
    var audioPath: String?
    var bodyText: String?
    var createdAt: String

    enum CodingKeys: String, CodingKey {
        case id, title, category
        case weekNumber = "week_number"
        case durationMinutes = "duration_minutes"
        case hasAudio = "has_audio"
        case audioPath = "audio_path"
        case bodyText = "body_text"
        case createdAt = "created_at"
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

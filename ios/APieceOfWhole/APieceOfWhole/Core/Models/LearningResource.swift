import Foundation

struct LearningResource: Codable, Identifiable, Sendable {
    let id: String
    var sourceKind: String
    var sourceID: String
    var sourceUUID: String
    var title: String
    var subtitle: String?
    var summary: String?
    var bodyMarkdown: String?
    var contentStatus: String
    var fileType: String
    var layers: [String]
    var subjects: [String]
    var tags: [String]
    var readingMinutes: Int?
    var reflectionPrompt: String?
    var published: Bool
    var sortOrder: Int?
    var createdAt: String
    var updatedAt: String

    enum CodingKeys: String, CodingKey {
        case id, title, subtitle, summary, layers, subjects, tags, published
        case sourceKind = "source_kind"
        case sourceID = "source_id"
        case sourceUUID = "source_uuid"
        case bodyMarkdown = "body_markdown"
        case contentStatus = "content_status"
        case fileType = "file_type"
        case readingMinutes = "reading_minutes"
        case reflectionPrompt = "reflection_prompt"
        case sortOrder = "sort_order"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }

    var layerValues: [String] { layers }

    var hasFullText: Bool {
        contentStatus == "full_text" && !(bodyMarkdown?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true)
    }
}

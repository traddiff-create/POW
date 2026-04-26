import Foundation

struct JournalEntry: Codable, Identifiable, Sendable {
    let id: String
    let userID: String
    var weekNumber: Int?
    var title: String?
    var body: String?
    var createdAt: String
    var updatedAt: String

    // Extended fields (added by migration)
    var sharedPostID: String?
    var sourceResourceID: String?

    enum CodingKeys: String, CodingKey {
        case id
        case userID = "user_id"
        case weekNumber = "week_number"
        case title, body
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case sharedPostID = "shared_post_id"
        case sourceResourceID = "source_resource_id"
    }

    var isShared: Bool { sharedPostID != nil }
}

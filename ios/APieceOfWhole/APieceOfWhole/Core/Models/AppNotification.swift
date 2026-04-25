import Foundation

struct AppNotification: Codable, Identifiable, Sendable {
    let id: String
    let userID: String
    var type: String
    var title: String
    var body: String?
    var readAt: String?
    var actionTarget: String?
    var createdAt: String

    enum CodingKeys: String, CodingKey {
        case id
        case userID = "user_id"
        case type, title, body
        case readAt = "read_at"
        case actionTarget = "action_target"
        case createdAt = "created_at"
    }

    var isRead: Bool { readAt != nil }
}

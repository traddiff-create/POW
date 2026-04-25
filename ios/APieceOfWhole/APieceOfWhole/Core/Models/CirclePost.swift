import Foundation

// Maps to `circle_shares` table
struct CirclePost: Codable, Identifiable, Sendable {
    let id: String
    let userID: String
    let cohortID: String
    var weekNumber: Int?
    var content: String
    var isAnonymous: Bool
    var authorName: String?
    var commentCount: Int?
    var createdAt: String

    enum CodingKeys: String, CodingKey {
        case id
        case userID = "user_id"
        case cohortID = "cohort_id"
        case weekNumber = "week_number"
        case content
        case isAnonymous = "is_anonymous"
        case authorName = "author_name"
        case commentCount = "comment_count"
        case createdAt = "created_at"
    }
}

// Maps to `circle_comments` table
struct CircleComment: Codable, Identifiable, Sendable {
    let id: String
    // postId maps to share_id column in DB
    let postID: String
    let userID: String
    var content: String
    var createdAt: String

    enum CodingKeys: String, CodingKey {
        case id
        case postID = "share_id"
        case userID = "user_id"
        case content
        case createdAt = "created_at"
    }
}

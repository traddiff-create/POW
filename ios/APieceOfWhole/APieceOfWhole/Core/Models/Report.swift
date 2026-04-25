import Foundation

struct Report: Codable, Identifiable, Sendable {
    let id: String
    var reporterID: String?
    var reportedContentID: String?
    var reportedContentType: String?
    var reason: String?
    var status: String
    var resolvedBy: String?
    var createdAt: String
    var resolvedAt: String?

    enum CodingKeys: String, CodingKey {
        case id
        case reporterID = "reporter_id"
        case reportedContentID = "reported_content_id"
        case reportedContentType = "reported_content_type"
        case reason, status
        case resolvedBy = "resolved_by"
        case createdAt = "created_at"
        case resolvedAt = "resolved_at"
    }
}

struct ReportSubmission: Encodable, Sendable {
    let reporterID: String
    let reportedContentID: String
    let reportedContentType: String
    let reason: String

    enum CodingKeys: String, CodingKey {
        case reporterID = "reporter_id"
        case reportedContentID = "reported_content_id"
        case reportedContentType = "reported_content_type"
        case reason
    }
}

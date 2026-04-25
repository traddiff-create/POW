import Foundation

// Maps to the `enrollments` table in Supabase
struct CohortMembership: Codable, Identifiable, Sendable {
    let id: String
    let userID: String
    let cohortID: String
    var paymentID: String?
    var enrolledAt: String

    enum CodingKeys: String, CodingKey {
        case id
        case userID = "user_id"
        case cohortID = "cohort_id"
        case paymentID = "payment_id"
        case enrolledAt = "enrolled_at"
    }
}

import Foundation

struct CohortApplication: Codable, Identifiable, Sendable {
    let id: String
    var cohortID: String?
    var applicantName: String
    var applicantEmail: String
    var motivation: String?
    var howHeard: String?
    var status: ApplicationStatus
    var createdAt: String
    var reviewedAt: String?
    var reviewedBy: String?

    // Extended fields (added by migration)
    var hopedChange: String?
    var weeklyCapacityHours: Int?
    var groupComfortLevel: Int?
    var agreementsAccepted: Bool?
    var safetyAcknowledged: Bool?

    enum CodingKeys: String, CodingKey {
        case id
        case cohortID = "cohort_id"
        case applicantName = "applicant_name"
        case applicantEmail = "applicant_email"
        case motivation
        case howHeard = "how_heard"
        case status
        case createdAt = "created_at"
        case reviewedAt = "reviewed_at"
        case reviewedBy = "reviewed_by"
        case hopedChange = "hoped_change"
        case weeklyCapacityHours = "weekly_capacity_hours"
        case groupComfortLevel = "group_comfort_level"
        case agreementsAccepted = "agreements_accepted"
        case safetyAcknowledged = "safety_acknowledged"
    }
}

struct ApplicationSubmission: Encodable, Sendable {
    let cohortID: String
    let applicantName: String
    let applicantEmail: String
    let motivation: String
    let howHeard: String
    let hopedChange: String
    let weeklyCapacityHours: Int
    let groupComfortLevel: Int
    let agreementsAccepted: Bool
    let safetyAcknowledged: Bool

    enum CodingKeys: String, CodingKey {
        case cohortID = "cohort_id"
        case applicantName = "applicant_name"
        case applicantEmail = "applicant_email"
        case motivation
        case howHeard = "how_heard"
        case hopedChange = "hoped_change"
        case weeklyCapacityHours = "weekly_capacity_hours"
        case groupComfortLevel = "group_comfort_level"
        case agreementsAccepted = "agreements_accepted"
        case safetyAcknowledged = "safety_acknowledged"
    }
}

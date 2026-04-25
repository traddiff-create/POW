import Foundation

enum UserRole: String, Codable, Sendable {
    case participant
    case facilitator
    case admin
}

// Matches actual DB values in applications.status
enum ApplicationStatus: String, Codable, CaseIterable, Sendable {
    case pending
    case approved
    case rejected
    case waitlisted
}

// cohorts uses is_open boolean; CohortStatus is a computed view concept only
enum CohortStatus: String, Codable, Sendable {
    case open
    case closed
}

enum MembershipStatus: String, Codable, Sendable {
    case enrolled
    case removed
    case completed
}

enum ContentType: String, Codable, Sendable {
    case practice
    case prompt
    case lesson
    case circleGuide = "circle_guide"
    case civicAction = "civic_action"
    case integration
}

enum SpiralLayer: String, Codable, Sendable {
    case selfRegulation = "self_regulation"
    case coRegulation = "co_regulation"
    case community
    case agency
    case civicEngagement = "civic_engagement"
}

enum PurchaseStatus: String, Codable, Sendable {
    case pending
    case active
    case refunded
    case revoked
    case expired
}

enum ReportStatus: String, Codable, Sendable {
    case open
    case reviewing
    case resolved
    case dismissed
}

enum OnboardingStep: String, Codable, Sendable {
    case ageConfirm = "age_confirm"
    case agreements
    case profileSetup = "profile_setup"
    case complete
}

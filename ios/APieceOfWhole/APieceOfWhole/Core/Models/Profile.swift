import Foundation

struct Profile: Codable, Identifiable, Sendable {
    let id: String
    var displayName: String?
    var role: UserRole
    var onboardingCompletedAt: String?
    var createdAt: String
    var updatedAt: String

    // Extended onboarding fields (added by migration)
    var adultConfirmedAt: String?
    var agreementsAcceptedAt: String?
    var onboardingStep: String?

    // My Piece fields (added by migration)
    var values: String?
    var giftsSkills: String?
    var currentCapacity: String?
    var boundaries: String?
    var currentContribution: String?
    var smallAction: String?

    enum CodingKeys: String, CodingKey {
        case id
        case displayName = "display_name"
        case role
        case onboardingCompletedAt = "onboarding_completed_at"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case adultConfirmedAt = "adult_confirmed_at"
        case agreementsAcceptedAt = "agreements_accepted_at"
        case onboardingStep = "onboarding_step"
        case values
        case giftsSkills = "gifts_skills"
        case currentCapacity = "current_capacity"
        case boundaries
        case currentContribution = "current_contribution"
        case smallAction = "small_action"
    }

    var isOnboardingComplete: Bool {
        onboardingCompletedAt != nil || onboardingStep == OnboardingStep.complete.rawValue
    }
}

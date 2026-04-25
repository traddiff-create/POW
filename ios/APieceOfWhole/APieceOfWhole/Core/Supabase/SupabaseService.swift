import Foundation
import Supabase

@MainActor
final class SupabaseService {
    static let shared = SupabaseService()
    private let db = SupabaseClient.shared

    private init() {}

    // MARK: - Profile

    func fetchProfile(userID: String) async throws -> Profile {
        try await db.from("user_profiles")
            .select()
            .eq("id", value: userID)
            .single()
            .execute()
            .value
    }

    func updateOnboardingAgeConfirm(userID: String, timestamp: String) async throws {
        struct P: Encodable { let adult_confirmed_at: String; let onboarding_step: String }
        try await db.from("user_profiles").update(P(adult_confirmed_at: timestamp, onboarding_step: OnboardingStep.agreements.rawValue)).eq("id", value: userID).execute()
    }

    func updateOnboardingAgreements(userID: String, timestamp: String) async throws {
        struct P: Encodable { let agreements_accepted_at: String; let onboarding_step: String }
        try await db.from("user_profiles").update(P(agreements_accepted_at: timestamp, onboarding_step: OnboardingStep.profileSetup.rawValue)).eq("id", value: userID).execute()
    }

    func updateOnboardingProfile(userID: String, displayName: String, timestamp: String) async throws {
        struct P: Encodable { let display_name: String; let onboarding_step: String; let onboarding_completed_at: String }
        try await db.from("user_profiles").update(P(display_name: displayName, onboarding_step: OnboardingStep.complete.rawValue, onboarding_completed_at: timestamp)).eq("id", value: userID).execute()
    }

    func updateMyPiece(userID: String, values: String?, giftsSkills: String?, currentCapacity: String?, boundaries: String?, currentContribution: String?, smallAction: String?) async throws {
        struct P: Encodable {
            let values: String?; let gifts_skills: String?; let current_capacity: String?
            let boundaries: String?; let current_contribution: String?; let small_action: String?
        }
        try await db.from("user_profiles").update(P(values: values, gifts_skills: giftsSkills, current_capacity: currentCapacity, boundaries: boundaries, current_contribution: currentContribution, small_action: smallAction)).eq("id", value: userID).execute()
    }

    // MARK: - Cohorts

    func fetchOpenCohorts() async throws -> [Cohort] {
        try await db.from("cohorts")
            .select()
            .eq("is_open", value: true)
            .order("created_at")
            .execute()
            .value
    }

    func fetchCohort(id: String) async throws -> Cohort {
        try await db.from("cohorts")
            .select()
            .eq("id", value: id)
            .single()
            .execute()
            .value
    }

    func fetchAllCohorts() async throws -> [Cohort] {
        try await db.from("cohorts")
            .select()
            .order("created_at", ascending: false)
            .execute()
            .value
    }

    func upsertCohort(_ cohort: Cohort) async throws {
        try await db.from("cohorts").upsert(cohort).execute()
    }

    // MARK: - Applications

    func submitApplication(_ submission: ApplicationSubmission) async throws -> CohortApplication {
        try await db.from("applications")
            .insert(submission)
            .select()
            .single()
            .execute()
            .value
    }

    func fetchApplications(userEmail: String) async throws -> [CohortApplication] {
        try await db.from("applications")
            .select()
            .eq("applicant_email", value: userEmail)
            .order("created_at", ascending: false)
            .execute()
            .value
    }

    func fetchAllApplications() async throws -> [CohortApplication] {
        try await db.from("applications")
            .select()
            .order("created_at", ascending: false)
            .execute()
            .value
    }

    func updateApplicationStatus(id: String, status: ApplicationStatus, reviewerID: String) async throws {
        try await db.from("applications")
            .update(["status": status.rawValue, "reviewed_by": reviewerID, "reviewed_at": ISO8601DateFormatter().string(from: Date())])
            .eq("id", value: id)
            .execute()
    }

    // MARK: - Enrollments (CohortMembership)

    func fetchMembership(userID: String) async throws -> CohortMembership? {
        let results: [CohortMembership] = try await db.from("enrollments")
            .select()
            .eq("user_id", value: userID)
            .order("enrolled_at", ascending: false)
            .limit(1)
            .execute()
            .value
        return results.first
    }

    // MARK: - Circles

    func fetchCircleID(userID: String, cohortID: String) async throws -> String? {
        struct Row: Decodable { let circle_id: String }
        let rows: [Row] = try await db.from("circle_members")
            .select("circle_id")
            .eq("user_id", value: userID)
            .execute()
            .value
        return rows.first?.circle_id
    }

    // MARK: - Curriculum

    func fetchCurriculum(cohortID: String) async throws -> [CurriculumItem] {
        try await db.from("cohort_curriculum")
            .select()
            .eq("cohort_id", value: cohortID)
            .order("week_number")
            .execute()
            .value
    }

    func fetchCurriculumWeek(cohortID: String, week: Int) async throws -> CurriculumItem? {
        let results: [CurriculumItem] = try await db.from("cohort_curriculum")
            .select()
            .eq("cohort_id", value: cohortID)
            .eq("week_number", value: week)
            .limit(1)
            .execute()
            .value
        return results.first
    }

    // MARK: - Practices

    func fetchPractices(weekNumber: Int? = nil) async throws -> [Practice] {
        var query = db.from("practices").select()
        if let week = weekNumber {
            query = query.eq("week_number", value: week)
        }
        return try await query.order("week_number").execute().value
    }

    func fetchCurrentWeekTheme(cohortID: String, week: Int = 1) async throws -> CurriculumItem? {
        try await fetchCurriculumWeek(cohortID: cohortID, week: week)
    }

    func fetchSuggestedPractice(cohortID: String, week: Int = 1) async throws -> Practice? {
        let all = try await fetchPractices(weekNumber: week)
        return all.first
    }

    // MARK: - Check-ins

    func submitCheckIn(_ checkIn: CheckInSubmission) async throws {
        try await db.from("check_ins").insert(checkIn).execute()
    }

    func fetchCheckIns(userID: String) async throws -> [CheckIn] {
        try await db.from("check_ins")
            .select()
            .eq("user_id", value: userID)
            .order("created_at", ascending: false)
            .execute()
            .value
    }

    func fetchTodayCheckIn(userID: String) async throws -> CheckIn? {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: today)!
        let fmt = ISO8601DateFormatter()
        let results: [CheckIn] = try await db.from("check_ins")
            .select()
            .eq("user_id", value: userID)
            .gte("created_at", value: fmt.string(from: today))
            .lt("created_at", value: fmt.string(from: tomorrow))
            .limit(1)
            .execute()
            .value
        return results.first
    }

    func fetchAllCheckIns(userID: String) async throws -> [CheckIn] {
        try await db.from("check_ins")
            .select()
            .eq("user_id", value: userID)
            .order("created_at")
            .execute()
            .value
    }

    // MARK: - Journal

    func fetchJournalEntries(userID: String) async throws -> [JournalEntry] {
        try await db.from("journal_entries")
            .select()
            .eq("user_id", value: userID)
            .order("created_at", ascending: false)
            .execute()
            .value
    }

    func createJournalEntry(userID: String, cohortID: String, title: String?, body: String) async throws -> JournalEntry {
        struct Payload: Encodable {
            let user_id: String; let cohort_id: String; let title: String?; let body: String
        }
        return try await db.from("journal_entries")
            .insert(Payload(user_id: userID, cohort_id: cohortID, title: title, body: body))
            .select()
            .single()
            .execute()
            .value
    }

    func updateJournalEntry(id: String, title: String?, body: String) async throws {
        struct Payload: Encodable { let title: String?; let body: String }
        try await db.from("journal_entries")
            .update(Payload(title: title, body: body))
            .eq("id", value: id)
            .execute()
    }

    func upsertJournalEntry(id: String?, userID: String, weekNumber: Int?, title: String?, body: String?) async throws -> JournalEntry {
        struct Payload: Encodable {
            let id: String?
            let userID: String
            let weekNumber: Int?
            let title: String?
            let body: String?
            enum CodingKeys: String, CodingKey {
                case id; case userID = "user_id"; case weekNumber = "week_number"; case title; case body
            }
        }
        return try await db.from("journal_entries")
            .upsert(Payload(id: id, userID: userID, weekNumber: weekNumber, title: title, body: body))
            .select()
            .single()
            .execute()
            .value
    }

    func shareJournalEntry(entryID: String, userID: String, cohortID: String, circleID: String, body: String) async throws {
        let post = try await submitCirclePost(userID: userID, cohortID: cohortID, weekNumber: nil, content: body, isAnonymous: false)
        try await db.from("journal_entries")
            .update(["shared_post_id": post.id])
            .eq("id", value: entryID)
            .execute()
    }

    // MARK: - Circle (circle_shares)

    func fetchCirclePosts(cohortID: String, weekNumber: Int? = nil) async throws -> [CirclePost] {
        var query = db.from("circle_shares")
            .select()
            .eq("cohort_id", value: cohortID)
        if let week = weekNumber {
            query = query.eq("week_number", value: week)
        }
        return try await query.order("created_at", ascending: false).execute().value
    }

    func submitCirclePost(userID: String, cohortID: String, weekNumber: Int?, content: String, isAnonymous: Bool) async throws -> CirclePost {
        struct Payload: Encodable {
            let userID: String; let cohortID: String; let weekNumber: Int?; let content: String; let isAnonymous: Bool
            enum CodingKeys: String, CodingKey {
                case userID = "user_id"; case cohortID = "cohort_id"; case weekNumber = "week_number"; case content; case isAnonymous = "is_anonymous"
            }
        }
        return try await db.from("circle_shares")
            .insert(Payload(userID: userID, cohortID: cohortID, weekNumber: weekNumber, content: content, isAnonymous: isAnonymous))
            .select()
            .single()
            .execute()
            .value
    }

    // MARK: - Circle Comments

    func fetchComments(postID: String) async throws -> [CircleComment] {
        try await db.from("circle_comments")
            .select()
            .eq("share_id", value: postID)
            .order("created_at")
            .execute()
            .value
    }

    func submitComment(postID: String, userID: String, content: String) async throws {
        struct Payload: Encodable {
            let shareID: String; let userID: String; let content: String
            enum CodingKeys: String, CodingKey {
                case shareID = "share_id"; case userID = "user_id"; case content
            }
        }
        try await db.from("circle_comments")
            .insert(Payload(shareID: postID, userID: userID, content: content))
            .execute()
    }

    // MARK: - Reports

    func submitReport(_ submission: ReportSubmission) async throws {
        try await db.from("reports").insert(submission).execute()
    }

    func fetchReports() async throws -> [Report] {
        try await db.from("reports")
            .select()
            .order("created_at", ascending: false)
            .execute()
            .value
    }

    func updateReport(id: String, status: String, resolverID: String) async throws {
        try await db.from("reports")
            .update(["status": status, "resolved_by": resolverID, "resolved_at": ISO8601DateFormatter().string(from: Date())])
            .eq("id", value: id)
            .execute()
    }

    // MARK: - Civic Lessons

    func fetchCivicLessons() async throws -> [CivicLesson] {
        try await db.from("civic_lessons")
            .select()
            .order("order_index")
            .execute()
            .value
    }

    // MARK: - Admin

    func fetchAllProfiles() async throws -> [Profile] {
        try await db.from("user_profiles")
            .select()
            .order("created_at", ascending: false)
            .execute()
            .value
    }

    func updateUserRole(userID: String, role: UserRole) async throws {
        try await db.from("user_profiles")
            .update(["role": role.rawValue])
            .eq("id", value: userID)
            .execute()
    }

    func sendAdminNotification(targetUserID: String?, type: String, title: String, body: String?) async throws {
        if let targetUserID, !targetUserID.isEmpty {
            struct Payload: Encodable {
                let user_id: String; let type: String; let title: String; let body: String?
            }
            try await db.from("notifications")
                .insert(Payload(user_id: targetUserID, type: type, title: title, body: body))
                .execute()
        } else {
            let profiles: [Profile] = try await fetchAllProfiles()
            struct Payload: Encodable {
                let user_id: String; let type: String; let title: String; let body: String?
            }
            let payloads = profiles.map { Payload(user_id: $0.id, type: type, title: title, body: body) }
            try await db.from("notifications").insert(payloads).execute()
        }
    }

    // MARK: - Notifications

    func fetchNotifications(userID: String) async throws -> [AppNotification] {
        try await db.from("notifications")
            .select()
            .eq("user_id", value: userID)
            .order("created_at", ascending: false)
            .execute()
            .value
    }

    func markNotificationRead(id: String) async throws {
        try await db.from("notifications")
            .update(["read_at": ISO8601DateFormatter().string(from: Date())])
            .eq("id", value: id)
            .execute()
    }
}

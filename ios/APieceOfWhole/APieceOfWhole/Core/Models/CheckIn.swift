import Foundation

struct CheckIn: Codable, Identifiable, Sendable {
    let id: String
    let userID: String
    var weekNumber: Int
    var moodScore: Int?
    var bodySensation: String?
    var oneWord: String?
    var freeNote: String?
    var createdAt: String

    // Extended fields (added by migration)
    var mood: Int?
    var stressLevel: Int?
    var capacityLevel: Int?
    var privateNote: String?

    enum CodingKeys: String, CodingKey {
        case id
        case userID = "user_id"
        case weekNumber = "week_number"
        case moodScore = "mood_score"
        case bodySensation = "body_sensation"
        case oneWord = "one_word"
        case freeNote = "free_note"
        case createdAt = "created_at"
        case mood
        case stressLevel = "stress_level"
        case capacityLevel = "capacity_level"
        case privateNote = "private_note"
    }
}

struct CheckInSubmission: Encodable, Sendable {
    let userID: String
    let weekNumber: Int
    let moodScore: Int?
    let bodySensation: String?
    let oneWord: String?
    let freeNote: String?
    let mood: Int?
    let stressLevel: Int?
    let capacityLevel: Int?

    enum CodingKeys: String, CodingKey {
        case userID = "user_id"
        case weekNumber = "week_number"
        case moodScore = "mood_score"
        case bodySensation = "body_sensation"
        case oneWord = "one_word"
        case freeNote = "free_note"
        case mood
        case stressLevel = "stress_level"
        case capacityLevel = "capacity_level"
    }
}

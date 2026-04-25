import Foundation

struct Cohort: Codable, Identifiable, Sendable {
    let id: String
    var name: String
    var slug: String?
    var description: String?
    var startDate: String?
    var endDate: String?
    var maxParticipants: Int?
    var priceCents: Int
    var isOpen: Bool
    var storeKitProductID: String?
    var createdAt: String

    enum CodingKeys: String, CodingKey {
        case id, name, slug, description
        case startDate = "start_date"
        case endDate = "end_date"
        case maxParticipants = "max_participants"
        case priceCents = "price_cents"
        case isOpen = "is_open"
        case storeKitProductID = "storekit_product_id"
        case createdAt = "created_at"
    }

    var formattedPrice: String {
        let dollars = Double(priceCents) / 100.0
        return String(format: "$%.0f", dollars)
    }
}

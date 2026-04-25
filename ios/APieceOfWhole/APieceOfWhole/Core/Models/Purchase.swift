import Foundation

struct Purchase: Codable, Identifiable, Sendable {
    let id: String
    let userID: String
    var cohortID: String?
    var storeKitProductID: String
    var originalTransactionID: String
    var transactionID: String
    var appAccountToken: String?
    var purchaseDate: String
    var expirationDate: String?
    var status: PurchaseStatus
    var createdAt: String

    enum CodingKeys: String, CodingKey {
        case id
        case userID = "user_id"
        case cohortID = "cohort_id"
        case storeKitProductID = "storekit_product_id"
        case originalTransactionID = "original_transaction_id"
        case transactionID = "transaction_id"
        case appAccountToken = "app_account_token"
        case purchaseDate = "purchase_date"
        case expirationDate = "expiration_date"
        case status
        case createdAt = "created_at"
    }
}

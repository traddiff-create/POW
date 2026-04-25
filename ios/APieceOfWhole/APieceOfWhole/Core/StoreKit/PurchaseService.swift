import Foundation
import StoreKit
import Supabase

@Observable
@MainActor
final class PurchaseService {
    static let shared = PurchaseService()

    var product: Product?
    var isPurchasing = false
    var error: String?

    private init() {}

    func loadProduct(id: String = Config.storeKitProductID) async throws -> Product {
        let products = try await Product.products(for: [id])
        guard let p = products.first else {
            throw PurchaseError.productNotFound
        }
        product = p
        return p
    }

    func purchase(cohortID: String) async throws {
        guard let p = product else {
            throw PurchaseError.productNotFound
        }

        guard let userIDStr = AuthService.shared.userID,
              let userUUID = UUID(uuidString: userIDStr) else {
            throw PurchaseError.notAuthenticated
        }

        isPurchasing = true
        defer { isPurchasing = false }

        let token = UUID()
        let result = try await p.purchase(options: [.appAccountToken(token)])

        switch result {
        case .success(let verification):
            let transaction = try checkVerified(verification)
            try await recordEntitlement(transaction: transaction, cohortID: cohortID, userUUID: userUUID, appAccountToken: token)
            await transaction.finish()

        case .pending:
            break

        case .userCancelled:
            throw PurchaseError.cancelled

        @unknown default:
            throw PurchaseError.unknown
        }
    }

    func observeTransactionUpdates() {
        Task {
            for await result in Transaction.updates {
                guard let transaction = try? checkVerified(result) else { continue }
                await transaction.finish()
            }
        }
    }

    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw PurchaseError.verificationFailed
        case .verified(let value):
            return value
        }
    }

    private func recordEntitlement(transaction: Transaction, cohortID: String, userUUID: UUID, appAccountToken: UUID) async throws {
        struct VerifyPayload: Encodable {
            let transactionId: String
            let originalTransactionId: String
            let userId: String
            let cohortId: String
            let productId: String
            let appAccountToken: String
        }

        let payload = VerifyPayload(
            transactionId: String(transaction.id),
            originalTransactionId: String(transaction.originalID),
            userId: userUUID.uuidString,
            cohortId: cohortID,
            productId: transaction.productID,
            appAccountToken: appAccountToken.uuidString
        )

        _ = try await SupabaseClient.shared.functions.invoke(
            "record-entitlement",
            options: .init(body: payload)
        )
    }
}

enum PurchaseError: LocalizedError {
    case productNotFound
    case notAuthenticated
    case verificationFailed
    case cancelled
    case unknown

    var errorDescription: String? {
        switch self {
        case .productNotFound: return "The purchase product could not be loaded."
        case .notAuthenticated: return "You must be signed in to purchase."
        case .verificationFailed: return "Purchase verification failed."
        case .cancelled: return "Purchase was cancelled."
        case .unknown: return "An unexpected error occurred."
        }
    }
}

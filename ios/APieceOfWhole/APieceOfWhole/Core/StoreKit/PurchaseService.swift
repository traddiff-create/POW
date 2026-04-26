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
    private var isObservingTransactions = false

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

        let userUUID = try await currentUserUUID()

        isPurchasing = true
        defer { isPurchasing = false }

        let result = try await p.purchase(options: [.appAccountToken(userUUID)])

        switch result {
        case .success(let verification):
            let (transaction, signedTransactionInfo) = try checkVerifiedTransaction(verification)
            try await verifyPurchase(
                transaction: transaction,
                signedTransactionInfo: signedTransactionInfo,
                cohortID: cohortID,
                userUUID: userUUID
            )
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
        guard !isObservingTransactions else { return }
        isObservingTransactions = true

        Task {
            for await result in Transaction.updates {
                guard let (transaction, signedTransactionInfo) = try? checkVerifiedTransaction(result) else { continue }
                guard let userUUID = try? await currentUserUUID() else {
                    continue
                }
                guard let cohortID = await verificationCohortID(for: userUUID.uuidString) else {
                    continue
                }
                try? await verifyPurchase(
                    transaction: transaction,
                    signedTransactionInfo: signedTransactionInfo,
                    cohortID: cohortID,
                    userUUID: userUUID
                )
                await transaction.finish()
            }
        }
    }

    func restorePurchases(cohortID: String) async throws {
        let userUUID = try await currentUserUUID()

        try await AppStore.sync()

        var restored = false
        for await result in Transaction.currentEntitlements {
            let (transaction, signedTransactionInfo) = try checkVerifiedTransaction(result)
            guard transaction.revocationDate == nil else { continue }
            guard product == nil || transaction.productID == product?.id else { continue }

            try await verifyPurchase(
                transaction: transaction,
                signedTransactionInfo: signedTransactionInfo,
                cohortID: cohortID,
                userUUID: userUUID
            )
            await transaction.finish()
            restored = true
        }

        if !restored {
            throw PurchaseError.noRestorablePurchase
        }
    }

    private func currentUserUUID() async throws -> UUID {
        if let userIDStr = AuthService.shared.userID,
           let userUUID = UUID(uuidString: userIDStr) {
            return userUUID
        }

        throw PurchaseError.notAuthenticated
    }

    private func verificationCohortID(for userID: String) async -> String? {
        guard let applications = try? await SupabaseService.shared.fetchApplications(userID: userID) else {
            return nil
        }

        return applications
            .filter { $0.status == .approved && $0.cohortID != nil }
            .sorted { $0.createdAt > $1.createdAt }
            .first?
            .cohortID
    }

    private func verifyPurchase(
        transaction: Transaction,
        signedTransactionInfo: String,
        cohortID: String,
        userUUID: UUID
    ) async throws {
        struct VerifyPayload: Encodable {
            let transactionId: String
            let originalTransactionId: String
            let userId: String
            let cohortId: String
            let productId: String
            let appAccountToken: String?
            let purchaseDate: String
            let expiresDate: String?
            let signedTransactionInfo: String
        }

        let fmt = ISO8601DateFormatter()
        let payload = VerifyPayload(
            transactionId: String(transaction.id),
            originalTransactionId: String(transaction.originalID),
            userId: userUUID.uuidString,
            cohortId: cohortID,
            productId: transaction.productID,
            appAccountToken: transaction.appAccountToken?.uuidString,
            purchaseDate: fmt.string(from: transaction.purchaseDate),
            expiresDate: transaction.expirationDate.map { fmt.string(from: $0) },
            signedTransactionInfo: signedTransactionInfo
        )

        _ = try await SupabaseClient.shared.functions.invoke(
            "verify-purchase",
            options: .init(body: payload)
        )
    }

    private func checkVerifiedTransaction(_ result: VerificationResult<Transaction>) throws -> (Transaction, String) {
        switch result {
        case .unverified:
            throw PurchaseError.verificationFailed
        case .verified(let value):
            return (value, result.jwsRepresentation)
        }
    }

}

enum PurchaseError: LocalizedError {
    case productNotFound
    case notAuthenticated
    case verificationFailed
    case cancelled
    case noRestorablePurchase
    case unknown

    var errorDescription: String? {
        switch self {
        case .productNotFound: return "The purchase product could not be loaded."
        case .notAuthenticated: return "You must be signed in to purchase."
        case .verificationFailed: return "Purchase verification failed."
        case .cancelled: return "Purchase was cancelled."
        case .noRestorablePurchase: return "No previous purchase could be restored for this cohort."
        case .unknown: return "An unexpected error occurred."
        }
    }
}

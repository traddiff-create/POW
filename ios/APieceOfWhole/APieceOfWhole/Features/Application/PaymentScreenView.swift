import SwiftUI
import StoreKit

struct PaymentScreenView: View {
    let cohortID: String
    @Environment(AppState.self) var appState
    @Environment(\.dismiss) var dismiss
    @State private var purchaseService = PurchaseService.shared
    @State private var cohort: Cohort?
    @State private var isLoadingProduct = true
    @State private var error: String?

    var body: some View {
        NavigationStack {
            ZStack {
                Color.powBackground.ignoresSafeArea()

                VStack(spacing: 32) {
                    Spacer()

                    VStack(spacing: 16) {
                        Image(systemName: "sparkles")
                            .font(.system(size: 48))
                            .foregroundStyle(Color.powSage)

                        if let cohort {
                            Text("Join \(cohort.name)")
                                .font(.powTitle)
                                .foregroundStyle(Color.powForeground)
                                .multilineTextAlignment(.center)

                            if let product = purchaseService.product {
                                Text(product.displayPrice)
                                    .font(.powTitle2)
                                    .foregroundStyle(Color.powSage)
                                Text("One-time payment • 8-week cohort access")
                                    .font(.powCallout)
                                    .foregroundStyle(Color.powMuted)
                            }
                        }
                    }

                    if let error {
                        Text(error)
                            .font(.powCaption)
                            .foregroundStyle(Color.powError)
                            .multilineTextAlignment(.center)
                    }

                    VStack(spacing: 12) {
                        if isLoadingProduct {
                            ProgressView()
                                .frame(height: 50)
                        } else {
                            POWButton(title: "Complete Enrollment", isLoading: purchaseService.isPurchasing) {
                                Task { await purchase() }
                            }
                            .disabled(purchaseService.product == nil)

                            Button("Restore Previous Purchase") {
                                Task { await restore() }
                            }
                            .font(.powCallout)
                            .foregroundStyle(Color.powMuted)
                        }
                    }
                    .padding(.bottom, 32)
                }
                .padding(.horizontal, 28)
            }
            .navigationTitle("Enrollment")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Later") { dismiss() }
                }
            }
        }
        .task { await loadProduct() }
    }

    private func loadProduct() async {
        do {
            cohort = try await SupabaseService.shared.fetchCohort(id: cohortID)
            let productID = cohort?.storeKitProductID ?? Config.storeKitProductID
            _ = try await purchaseService.loadProduct(id: productID)
        } catch {
            self.error = error.localizedDescription
        }
        isLoadingProduct = false
    }

    private func purchase() async {
        error = nil
        do {
            try await purchaseService.purchase(cohortID: cohortID)
            await appState.refreshMembership()
            dismiss()
        } catch PurchaseError.cancelled {
            // user cancelled — no error shown
        } catch {
            self.error = error.localizedDescription
        }
    }

    private func restore() async {
        try? await AppStore.sync()
        await appState.refreshMembership()
    }
}

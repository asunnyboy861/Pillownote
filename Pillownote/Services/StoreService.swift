import Foundation
import StoreKit

enum Entitlement: String {
    case free, plus, byo
}

@MainActor
final class PurchaseManager: ObservableObject {
    static let shared = PurchaseManager()

    @Published var isPlus = false
    @Published var isBYO = false
    @Published var hasThemes = false
    @Published var products: [Product] = []
    @Published var isLoading = false
    @Published var loadError: String?

    static let plusMonthly = "com.zzoutuo.pillownote.plus.monthly"
    static let plusYearly = "com.zzoutuo.pillownote.plus.yearly"
    static let byoLifetime = "com.zzoutuo.pillownote.byo.lifetime"
    static let themesSeasons = "com.zzoutuo.pillownote.themes.seasons"
    static let allProductIDs = [plusMonthly, plusYearly, byoLifetime, themesSeasons]

    private var transactionListener: Task<Void, Never>?

    var isPremium: Bool { isPlus || isBYO }
    var entitlement: Entitlement { isPlus ? .plus : (isBYO ? .byo : .free) }

    private init() {
        transactionListener = listenForTransactions()
        Task {
            await loadProducts()
            await checkPurchased()
        }
    }

    deinit {
        transactionListener?.cancel()
    }

    func loadProducts() async {
        isLoading = true
        do {
            products = try await Product.products(for: Self.allProductIDs)
            products.sort { $0.price > $1.price }
            loadError = products.isEmpty ? "Purchase options are being set up. Check back soon." : nil
        } catch {
            loadError = "Unable to load purchase options."
        }
        isLoading = false
    }

    func purchase(_ product: Product) async -> Bool {
        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                if case .verified(let transaction) = verification {
                    await transaction.finish()
                    await checkPurchased()
                    return true
                } else {
                    loadError = "Purchase could not be verified."
                }
            case .userCancelled, .pending:
                break
            @unknown default:
                break
            }
        } catch {
            loadError = "Purchase failed: \(error.localizedDescription)"
        }
        return false
    }

    func restorePurchases() async {
        do {
            try await AppStore.sync()
            await checkPurchased()
        } catch {
            loadError = "Restore failed: \(error.localizedDescription)"
        }
    }

    func checkPurchased() async {
        func owned(_ productID: String) async -> Bool {
            guard let result = await Transaction.currentEntitlement(for: productID) else { return false }
            if case .verified(let transaction) = result {
                return transaction.revocationDate == nil
            }
            return false
        }
        let monthly = await owned(Self.plusMonthly)
        let yearly = await owned(Self.plusYearly)
        isPlus = monthly || yearly
        isBYO = await owned(Self.byoLifetime)
        hasThemes = await owned(Self.themesSeasons)
    }

    private func listenForTransactions() -> Task<Void, Never> {
        Task.detached { [weak self] in
            for await result in Transaction.updates {
                if case .verified(let transaction) = result {
                    await transaction.finish()
                    Task { @MainActor [weak self] in
                        await self?.checkPurchased()
                    }
                }
            }
        }
    }

    func product(for id: String) -> Product? {
        products.first { $0.id == id }
    }

    var yearlyProduct: Product? { product(for: Self.plusYearly) }
    var monthlyProduct: Product? { product(for: Self.plusMonthly) }
    var byoProduct: Product? { product(for: Self.byoLifetime) }
    var themesProduct: Product? { product(for: Self.themesSeasons) }
}

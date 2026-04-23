import StoreKit
import Foundation

enum ProductID {
    static let plusMonthly = "com.zzoutuo.SpoilAlert.plus.monthly"
    static let plusYearly = "com.zzoutuo.SpoilAlert.plus.yearly"
    static let proMonthly = "com.zzoutuo.SpoilAlert.pro.monthly"
    static let proYearly = "com.zzoutuo.SpoilAlert.pro.yearly"
    static let lifetime = "com.zzoutuo.SpoilAlert.pro.lifetime"
    static let all = [plusMonthly, plusYearly, proMonthly, proYearly, lifetime]
}

enum SubscriptionTier: String, CaseIterable {
    case free
    case plus
    case pro

    var maxProducts: Int {
        switch self {
        case .free: return 3
        case .plus, .pro: return .max
        }
    }

    var hasPAORecognition: Bool { self != .free }
    var hasBarcodeScanner: Bool { self != .free }
    var hasMultiReminder: Bool { self != .free }
    var hasSkinLog: Bool { self != .free }
    var hasICloudSync: Bool { self == .pro }
    var hasFamilySharing: Bool { self == .pro }
    var hasDataExport: Bool { self == .pro }
}

@MainActor
final class PurchaseManager: ObservableObject {

    @Published private(set) var products: [Product] = []
    @Published private(set) var purchasedProductIDs: Set<String> = []
    @Published private(set) var isPro = false
    @Published private(set) var isPlus = false
    @Published private(set) var isLoading = false
    @Published var errorMessage: String?

    var currentTier: SubscriptionTier {
        if isPro || purchasedProductIDs.contains(ProductID.lifetime) {
            return .pro
        } else if isPlus {
            return .plus
        }
        return .free
    }

    var plusMonthlyProduct: Product? {
        products.first { $0.id == ProductID.plusMonthly }
    }

    var plusYearlyProduct: Product? {
        products.first { $0.id == ProductID.plusYearly }
    }

    var proMonthlyProduct: Product? {
        products.first { $0.id == ProductID.proMonthly }
    }

    var proYearlyProduct: Product? {
        products.first { $0.id == ProductID.proYearly }
    }

    var lifetimeProduct: Product? {
        products.first { $0.id == ProductID.lifetime }
    }

    private var transactionListener: Task<Void, Never>?

    init() {
        transactionListener = listenForTransactions()
        Task {
            await loadProducts()
            await updatePurchaseStatus()
        }
    }

    deinit {
        transactionListener?.cancel()
    }

    func loadProducts() async {
        do {
            let storeProducts = try await Product.products(for: ProductID.all)
            products = storeProducts.sorted { $0.price < $1.price }
        } catch {
            errorMessage = "Failed to load products: \(error.localizedDescription)"
        }
    }

    func purchase(_ product: Product) async -> Bool {
        isLoading = true
        defer { isLoading = false }

        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                let transaction = try checkVerified(verification)
                await updatePurchaseStatus()
                await transaction.finish()
                return true
            case .userCancelled:
                return false
            case .pending:
                return false
            @unknown default:
                return false
            }
        } catch {
            errorMessage = "Purchase failed: \(error.localizedDescription)"
            return false
        }
    }

    func restorePurchases() async {
        isLoading = true
        defer { isLoading = false }

        do {
            try await AppStore.sync()
            await updatePurchaseStatus()
        } catch {
            errorMessage = "Restore failed: \(error.localizedDescription)"
        }
    }

    private func listenForTransactions() -> Task<Void, Never> {
        Task.detached { [weak self] in
            for await result in Transaction.updates {
                guard let self else { return }
                let transaction: Transaction
                switch result {
                case .verified(let safe):
                    transaction = safe
                case .unverified:
                    continue
                }
                await self.updatePurchaseStatus()
                await transaction.finish()
            }
        }
    }

    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw StoreError.failedVerification
        case .verified(let safe):
            return safe
        }
    }

    private func updatePurchaseStatus() async {
        var purchasedIDs: Set<String> = []
        for await result in Transaction.currentEntitlements {
            if let transaction = try? checkVerified(result) {
                purchasedIDs.insert(transaction.productID)
            }
        }
        purchasedProductIDs = purchasedIDs
        isPlus = purchasedProductIDs.contains(ProductID.plusMonthly)
            || purchasedProductIDs.contains(ProductID.plusYearly)
        isPro = purchasedProductIDs.contains(ProductID.proMonthly)
            || purchasedProductIDs.contains(ProductID.proYearly)
            || purchasedProductIDs.contains(ProductID.lifetime)
    }
}

enum StoreError: Error {
    case failedVerification
}

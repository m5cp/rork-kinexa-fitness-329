import Foundation
import Observation
import RevenueCat

@Observable
@MainActor
class StoreViewModel {
    var offerings: Offerings?
    private var _rcPremium = false
    var isLoading = false
    var isPurchasing = false
    var error: String?
    var tokenPurchaseSuccess = false

    var testBypassEnabled: Bool {
        get { UserDefaults.standard.bool(forKey: "kinexa_test_bypass") }
        set {
            UserDefaults.standard.set(newValue, forKey: "kinexa_test_bypass")
            if let group = UserDefaults(suiteName: "group.com.kinexafitness.shared") {
                group.set(newValue, forKey: "kinexa_test_bypass")
            }
        }
    }

    var isPremium: Bool {
        #if DEBUG
        return testBypassEnabled || _rcPremium
        #else
        return _rcPremium
        #endif
    }

    var tokenOffering: Offering? {
        offerings?.offering(identifier: "tokens")
    }

    var tokenPackages: [Package] {
        guard let offering = tokenOffering else { return [] }
        let order = ["tokens_50", "tokens_150", "tokens_500"]
        return offering.availablePackages.sorted { a, b in
            let aIdx = order.firstIndex(of: a.identifier) ?? 99
            let bIdx = order.firstIndex(of: b.identifier) ?? 99
            return aIdx < bIdx
        }
    }

    init() {
        Task { await listenForUpdates() }
        Task { await fetchOfferings() }
    }

    private func listenForUpdates() async {
        for await info in Purchases.shared.customerInfoStream {
            self._rcPremium = info.entitlements["premium"]?.isActive == true
        }
    }

    func fetchOfferings() async {
        isLoading = true
        do {
            offerings = try await Purchases.shared.offerings()
        } catch {
            self.error = error.localizedDescription
        }
        isLoading = false
    }

    func purchase(package: Package) async {
        isPurchasing = true
        do {
            let result = try await Purchases.shared.purchase(package: package)
            if !result.userCancelled {
                _rcPremium = result.customerInfo.entitlements["premium"]?.isActive == true
            }
        } catch ErrorCode.purchaseCancelledError {
        } catch ErrorCode.paymentPendingError {
        } catch {
            self.error = error.localizedDescription
        }
        isPurchasing = false
    }

    func purchaseTokens(package: Package) async {
        isPurchasing = true
        tokenPurchaseSuccess = false
        do {
            let result = try await Purchases.shared.purchase(package: package)
            if !result.userCancelled {
                let identifier = package.storeProduct.productIdentifier
                let count = AIUsageTracker.shared.tokenCountForProduct(identifier)
                if count > 0 {
                    AIUsageTracker.shared.addBonusTokens(count)
                    tokenPurchaseSuccess = true
                }
            }
        } catch ErrorCode.purchaseCancelledError {
        } catch ErrorCode.paymentPendingError {
        } catch {
            self.error = error.localizedDescription
        }
        isPurchasing = false
    }

    func restore() async {
        do {
            let info = try await Purchases.shared.restorePurchases()
            _rcPremium = info.entitlements["premium"]?.isActive == true
        } catch {
            self.error = error.localizedDescription
        }
    }

    func checkStatus() async {
        do {
            let info = try await Purchases.shared.customerInfo()
            _rcPremium = info.entitlements["premium"]?.isActive == true
        } catch {
            self.error = error.localizedDescription
        }
    }
}

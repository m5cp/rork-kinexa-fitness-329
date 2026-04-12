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

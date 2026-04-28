import Foundation
import CoreMotion
import Observation

@Observable
final class PedometerManager {
    private let pedometer = CMPedometer()
    private let optInKey = "motionAccessOptedIn"

    var todaySteps: Int = 0
    var isAvailable: Bool = CMPedometer.isStepCountingAvailable()
    var permissionDenied: Bool = false

    var hasOptedIn: Bool {
        UserDefaults.standard.bool(forKey: optInKey)
    }

    func enableAndRefresh() {
        UserDefaults.standard.set(true, forKey: optInKey)
        refreshTodaySteps()
    }

    func refreshTodaySteps() {
        guard hasOptedIn else { return }
        guard isAvailable else {
            permissionDenied = true
            return
        }

        let status = CMMotionActivityManager.authorizationStatus()
        if status == .denied || status == .restricted {
            permissionDenied = true
            return
        }

        permissionDenied = false
        let start = Calendar.current.startOfDay(for: .now)
        pedometer.queryPedometerData(from: start, to: .now) { [weak self] data, error in
            let value = data?.numberOfSteps.intValue ?? 0
            let denied = (error as? NSError)?.code == Int(CMErrorMotionActivityNotAuthorized.rawValue)
            DispatchQueue.main.async {
                self?.todaySteps = value
                if denied {
                    self?.permissionDenied = true
                }
            }
        }
    }
}

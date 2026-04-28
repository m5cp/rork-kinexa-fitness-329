import Foundation
import HealthKit
import Observation

@Observable
final class HealthKitService {
    static let shared = HealthKitService()

    private let store = HKHealthStore()

    var isAvailable: Bool { HKHealthStore.isHealthDataAvailable() }

    var todaySteps: Int = 0
    var todayActiveEnergyKcal: Double = 0
    var lastAuthorizationGranted: Bool = false

    private var readTypes: Set<HKObjectType> {
        var set: Set<HKObjectType> = []
        if let steps = HKObjectType.quantityType(forIdentifier: .stepCount) { set.insert(steps) }
        if let energy = HKObjectType.quantityType(forIdentifier: .activeEnergyBurned) { set.insert(energy) }
        set.insert(HKObjectType.workoutType())
        return set
    }

    private var writeTypes: Set<HKSampleType> {
        var set: Set<HKSampleType> = [HKObjectType.workoutType()]
        if let energy = HKObjectType.quantityType(forIdentifier: .activeEnergyBurned) { set.insert(energy) }
        return set
    }

    @discardableResult
    func requestAuthorization() async -> Bool {
        guard isAvailable else { return false }
        do {
            try await store.requestAuthorization(toShare: writeTypes, read: readTypes)
            lastAuthorizationGranted = true
            await refreshToday()
            return true
        } catch {
            lastAuthorizationGranted = false
            return false
        }
    }

    func refreshToday() async {
        async let steps = fetchTodayQuantity(.stepCount, unit: .count())
        async let energy = fetchTodayQuantity(.activeEnergyBurned, unit: .kilocalorie())
        let stepsValue = await steps
        let energyValue = await energy
        self.todaySteps = Int(stepsValue)
        self.todayActiveEnergyKcal = energyValue
    }

    private func fetchTodayQuantity(_ id: HKQuantityTypeIdentifier, unit: HKUnit) async -> Double {
        guard let type = HKObjectType.quantityType(forIdentifier: id) else { return 0 }
        let start = Calendar.current.startOfDay(for: .now)
        let predicate = HKQuery.predicateForSamples(withStart: start, end: .now, options: .strictStartDate)
        return await withCheckedContinuation { continuation in
            let query = HKStatisticsQuery(
                quantityType: type,
                quantitySamplePredicate: predicate,
                options: .cumulativeSum
            ) { _, stats, _ in
                let value = stats?.sumQuantity()?.doubleValue(for: unit) ?? 0
                continuation.resume(returning: value)
            }
            store.execute(query)
        }
    }

    func saveWorkout(
        title: String,
        start: Date,
        durationSeconds: Int,
        estimatedKcal: Double?,
        activityType: HKWorkoutActivityType = .traditionalStrengthTraining
    ) async {
        guard isAvailable else { return }
        let duration = max(TimeInterval(durationSeconds), 60)
        let end = start.addingTimeInterval(duration)

        let config = HKWorkoutConfiguration()
        config.activityType = activityType

        let builder = HKWorkoutBuilder(healthStore: store, configuration: config, device: .local())

        do {
            try await builder.beginCollection(at: start)

            if let kcal = estimatedKcal, kcal > 0,
               let energyType = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned) {
                let sample = HKQuantitySample(
                    type: energyType,
                    quantity: HKQuantity(unit: .kilocalorie(), doubleValue: kcal),
                    start: start,
                    end: end
                )
                try await builder.addSamples([sample])
            }

            try await builder.endCollection(at: end)
            _ = try await builder.finishWorkout()
        } catch {
            // Silently ignore — Health save failures shouldn't interrupt app flow
        }
    }
}

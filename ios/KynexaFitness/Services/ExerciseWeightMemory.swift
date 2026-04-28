import Foundation

enum ExerciseWeightMemory {
    private static let storageKey = "exerciseWeightMemory"
    private static let historyKey = "exerciseWeightHistory"

    static func lastWeight(for exerciseName: String) -> String? {
        let memory = loadMemory()
        return memory[exerciseName.lowercased().trimmingCharacters(in: .whitespaces)]
    }

    static func recordWeight(for exerciseName: String, weight: String) {
        guard !weight.isEmpty else { return }
        let key = exerciseName.lowercased().trimmingCharacters(in: .whitespaces)

        var memory = loadMemory()
        memory[key] = weight
        saveMemory(memory)

        var history = loadHistory()
        let entry = WeightEntry(exerciseName: key, weight: weight, date: Date())
        history.append(entry)
        if history.count > 500 { history = Array(history.suffix(500)) }
        saveHistory(history)
    }

    static func recordWorkout(_ exercises: [WorkoutExercise]) {
        for exercise in exercises {
            if !exercise.weight.isEmpty && exercise.category == .strength {
                recordWeight(for: exercise.name, weight: exercise.weight)
            }
        }
    }

    static func suggestedWeight(for exerciseName: String) -> String? {
        lastWeight(for: exerciseName)
    }

    static func weightHistory(for exerciseName: String, limit: Int = 10) -> [WeightEntry] {
        let key = exerciseName.lowercased().trimmingCharacters(in: .whitespaces)
        let history = loadHistory()
        return Array(history.filter { $0.exerciseName == key }.suffix(limit))
    }

    static func prefillExercises(_ exercises: [WorkoutExercise]) -> [WorkoutExercise] {
        exercises.map { exercise in
            var updated = exercise
            if updated.weight.isEmpty && updated.category == .strength {
                if let remembered = lastWeight(for: exercise.name) {
                    updated.weight = remembered
                }
            }
            return updated
        }
    }

    static func allTrackedExercises() -> [String: String] {
        loadMemory()
    }

    static func clearAll() {
        UserDefaults.standard.removeObject(forKey: storageKey)
        UserDefaults.standard.removeObject(forKey: historyKey)
    }

    private static func loadMemory() -> [String: String] {
        guard let data = UserDefaults.standard.data(forKey: storageKey),
              let dict = try? JSONDecoder().decode([String: String].self, from: data) else {
            return [:]
        }
        return dict
    }

    private static func saveMemory(_ memory: [String: String]) {
        if let data = try? JSONEncoder().encode(memory) {
            UserDefaults.standard.set(data, forKey: storageKey)
        }
    }

    private static func loadHistory() -> [WeightEntry] {
        guard let data = UserDefaults.standard.data(forKey: historyKey),
              let entries = try? JSONDecoder().decode([WeightEntry].self, from: data) else {
            return []
        }
        return entries
    }

    private static func saveHistory(_ history: [WeightEntry]) {
        if let data = try? JSONEncoder().encode(history) {
            UserDefaults.standard.set(data, forKey: historyKey)
        }
    }
}

nonisolated struct WeightEntry: Codable, Identifiable, Sendable {
    let id: UUID
    let exerciseName: String
    let weight: String
    let date: Date

    init(exerciseName: String, weight: String, date: Date) {
        self.id = UUID()
        self.exerciseName = exerciseName
        self.weight = weight
        self.date = date
    }
}

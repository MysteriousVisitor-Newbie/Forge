import Foundation
import SwiftData

enum TaskPriority: String, CaseIterable, Identifiable, Codable {
    case low
    case medium
    case high

    var id: String { rawValue }

    var label: String {
        switch self {
        case .low: "Low"
        case .medium: "Medium"
        case .high: "High"
        }
    }

    var systemImage: String {
        switch self {
        case .low: "arrow.down"
        case .medium: "minus"
        case .high: "arrow.up"
        }
    }
}

@Model
final class TaskItem {
    var title: String
    var notes: String
    var isCompleted: Bool
    var priorityRaw: String
    var dueDate: Date?
    var createdAt: Date
    var completedAt: Date?
    var project: Project?

    var priority: TaskPriority {
        get { TaskPriority(rawValue: priorityRaw) ?? .medium }
        set { priorityRaw = newValue.rawValue }
    }

    init(
        title: String,
        notes: String = "",
        priority: TaskPriority = .medium,
        dueDate: Date? = nil,
        project: Project? = nil
    ) {
        self.title = title
        self.notes = notes
        self.isCompleted = false
        self.priorityRaw = priority.rawValue
        self.dueDate = dueDate
        self.createdAt = .now
        self.completedAt = nil
        self.project = project
    }

    var isOverdue: Bool {
        guard let dueDate, !isCompleted else { return false }
        return dueDate < Calendar.current.startOfDay(for: .now)
    }

    var isDueToday: Bool {
        guard let dueDate, !isCompleted else { return false }
        return Calendar.current.isDateInToday(dueDate)
    }
}

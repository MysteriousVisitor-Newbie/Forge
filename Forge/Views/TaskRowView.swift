import SwiftUI

struct TaskRowView: View {
    let task: TaskItem
    var onToggle: () -> Void

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Button(action: onToggle) {
                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundStyle(task.isCompleted ? Color.green : Color.secondary)
            }
            .buttonStyle(.plain)
            .accessibilityLabel(task.isCompleted ? "Mark incomplete" : "Mark complete")

            VStack(alignment: .leading, spacing: 4) {
                Text(task.title)
                    .font(.body.weight(.medium))
                    .strikethrough(task.isCompleted, color: .secondary)
                    .foregroundStyle(task.isCompleted ? .secondary : .primary)
                    .lineLimit(2)

                HStack(spacing: 8) {
                    if let project = task.project {
                        HStack(spacing: 4) {
                            Circle()
                                .fill(project.color)
                                .frame(width: 7, height: 7)
                            Text(project.name)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }

                    if let due = task.dueDate {
                        Text(due, style: .date)
                            .font(.caption)
                            .foregroundStyle(task.isOverdue ? .red : .secondary)
                    }

                    if task.priority == .high && !task.isCompleted {
                        PriorityBadge(priority: .high)
                    }
                }
            }

            Spacer(minLength: 0)
        }
        .padding(.vertical, 4)
    }
}

import SwiftUI

struct PriorityBadge: View {
    let priority: TaskPriority

    var body: some View {
        Label(priority.label, systemImage: priority.systemImage)
            .font(.caption2.weight(.semibold))
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .foregroundStyle(foreground)
            .background(foreground.opacity(0.15), in: Capsule())
    }

    private var foreground: Color {
        switch priority {
        case .low: .blue
        case .medium: .orange
        case .high: .red
        }
    }
}

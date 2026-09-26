import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var tasks: [TaskItem]
    @Query private var projects: [Project]

    @State private var confirmReset = false
    @State private var confirmClearDone = false
    @State private var seeded = false

    private var openCount: Int { tasks.filter { !$0.isCompleted }.count }
    private var doneCount: Int { tasks.filter(\.isCompleted).count }

    var body: some View {
        NavigationStack {
            List {
                Section("This device") {
                    LabeledContent("Open tasks", value: "\(openCount)")
                    LabeledContent("Completed", value: "\(doneCount)")
                    LabeledContent("Projects", value: "\(projects.count)")
                }

                Section("Data") {
                    Button("Load sample workweek") {
                        SampleData.seed(into: modelContext)
                        seeded = true
                    }

                    Button("Clear completed tasks", role: .destructive) {
                        confirmClearDone = true
                    }

                    Button("Delete everything", role: .destructive) {
                        confirmReset = true
                    }
                }

                Section("About") {
                    LabeledContent("App", value: "Forge")
                    LabeledContent("Stack", value: "SwiftUI + SwiftData")
                    Text("A local-first work planner. Nothing leaves this phone unless you add iCloud later.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Settings")
            .alert("Sample data added", isPresented: $seeded) {
                Button("OK", role: .cancel) {}
            }
            .confirmationDialog(
                "Delete every completed task?",
                isPresented: $confirmClearDone,
                titleVisibility: .visible
            ) {
                Button("Clear completed", role: .destructive) {
                    SampleData.clearCompleted(in: modelContext, tasks: tasks)
                }
            }
            .confirmationDialog(
                "This removes every task and project on this phone.",
                isPresented: $confirmReset,
                titleVisibility: .visible
            ) {
                Button("Delete everything", role: .destructive) {
                    SampleData.wipe(in: modelContext, tasks: tasks, projects: projects)
                }
            }
        }
    }
}

enum SampleData {
    static func seed(into context: ModelContext) {
        let work = Project(name: "Work", colorHex: "3B82F6")
        let personal = Project(name: "Personal", colorHex: "22C55E")
        let deep = Project(name: "Deep work", colorHex: "8B5CF6")
        context.insert(work)
        context.insert(personal)
        context.insert(deep)

        let cal = Calendar.current
        let today = cal.startOfDay(for: .now)
        let yesterday = cal.date(byAdding: .day, value: -1, to: today)
        let tomorrow = cal.date(byAdding: .day, value: 1, to: today)

        let items: [TaskItem] = [
            TaskItem(title: "Write the weekly status note", notes: "Ship before standup. Keep it to five bullets.", priority: .high, dueDate: today, project: work),
            TaskItem(title: "Review pull requests", notes: "Focus on the auth refactor first.", priority: .medium, dueDate: today, project: work),
            TaskItem(title: "Blocked: waiting on design specs", notes: "Ping design if nothing lands by noon.", priority: .high, dueDate: yesterday, project: work),
            TaskItem(title: "Ninety-minute focus block", notes: "Phone in another room. One task only.", priority: .high, dueDate: today, project: deep),
            TaskItem(title: "Renew domain", notes: "", priority: .low, dueDate: tomorrow, project: personal),
            TaskItem(title: "Outline Q4 goals", notes: "Three outcomes, not a laundry list.", priority: .medium, dueDate: tomorrow, project: deep)
        ]

        items.forEach { context.insert($0) }
        try? context.save()
    }

    static func clearCompleted(in context: ModelContext, tasks: [TaskItem]) {
        tasks.filter(\.isCompleted).forEach { context.delete($0) }
        try? context.save()
    }

    static func wipe(in context: ModelContext, tasks: [TaskItem], projects: [Project]) {
        tasks.forEach { context.delete($0) }
        projects.forEach { context.delete($0) }
        try? context.save()
    }
}

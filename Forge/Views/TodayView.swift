import SwiftUI
import SwiftData

struct TodayView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \TaskItem.createdAt, order: .reverse) private var allTasks: [TaskItem]
    @State private var showEditor = false

    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: .now)
        switch hour {
        case 5..<12: return "Good morning"
        case 12..<17: return "Good afternoon"
        case 17..<22: return "Good evening"
        default: return "Still grinding"
        }
    }

    private var dueToday: [TaskItem] {
        allTasks.filter(\.isDueToday).sorted(by: priorityThenDate)
    }

    private var overdue: [TaskItem] {
        allTasks.filter(\.isOverdue).sorted(by: priorityThenDate)
    }

    private var openCount: Int {
        allTasks.filter { !$0.isCompleted }.count
    }

    private var completedToday: Int {
        allTasks.filter { task in
            guard let done = task.completedAt else { return false }
            return Calendar.current.isDateInToday(done)
        }.count
    }

    private var todayProgress: Double {
        let relevant = dueToday.count + overdue.count + completedToday
        guard relevant > 0 else { return completedToday > 0 ? 1 : 0 }
        return Double(completedToday) / Double(relevant)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    header
                    if !overdue.isEmpty {
                        section(title: "Overdue", tint: .red, tasks: overdue)
                    }
                    section(title: "Due today", tint: .orange, tasks: dueToday)
                    if overdue.isEmpty && dueToday.isEmpty {
                        emptyState
                    }
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Today")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showEditor = true
                    } label: {
                        Image(systemName: "plus")
                    }
                    .accessibilityLabel("New task")
                }
            }
            .sheet(isPresented: $showEditor) {
                TaskEditorView()
            }
        }
    }

    private var header: some View {
        HStack(alignment: .center, spacing: 16) {
            VStack(alignment: .leading, spacing: 6) {
                Text(greeting)
                    .font(.title2.weight(.semibold))
                Text(Date.now, format: .dateTime.weekday(.wide).month(.wide).day())
                    .foregroundStyle(.secondary)
                Text("\(openCount) open · \(completedToday) done today")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            ProgressRing(progress: todayProgress)
        }
        .padding(16)
        .background(.background, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
    }

    private func section(title: String, tint: Color, tasks: [TaskItem]) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(title)
                    .font(.headline)
                Spacer()
                Text("\(tasks.count)")
                    .font(.subheadline.monospacedDigit())
                    .foregroundStyle(.secondary)
            }
            .foregroundStyle(tint)

            if tasks.isEmpty {
                Text("Nothing here. Nice.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(.background, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            } else {
                VStack(spacing: 0) {
                    ForEach(tasks) { task in
                        NavigationLink {
                            TaskEditorView(existing: task)
                        } label: {
                            TaskRowView(task: task) {
                                toggle(task)
                            }
                        }
                        .buttonStyle(.plain)
                        if task.id != tasks.last?.id {
                            Divider().padding(.leading, 36)
                        }
                    }
                }
                .padding()
                .background(.background, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "sparkles")
                .font(.largeTitle)
                .foregroundStyle(.orange)
            Text("Clear day")
                .font(.headline)
            Text("No deadlines staring at you. Add work when you are ready.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            Button("Add a task") { showEditor = true }
                .buttonStyle(.borderedProminent)
                .tint(.orange)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 32)
    }

    private func toggle(_ task: TaskItem) {
        task.isCompleted.toggle()
        task.completedAt = task.isCompleted ? .now : nil
        try? modelContext.save()
    }

    private func priorityThenDate(_ lhs: TaskItem, _ rhs: TaskItem) -> Bool {
        let order: [TaskPriority] = [.high, .medium, .low]
        let l = order.firstIndex(of: lhs.priority) ?? 1
        let r = order.firstIndex(of: rhs.priority) ?? 1
        if l != r { return l < r }
        return (lhs.dueDate ?? .distantFuture) < (rhs.dueDate ?? .distantFuture)
    }
}

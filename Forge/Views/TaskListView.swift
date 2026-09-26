import SwiftUI
import SwiftData

struct TaskListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \TaskItem.createdAt, order: .reverse) private var tasks: [TaskItem]

    @State private var search = ""
    @State private var showCompleted = false
    @State private var showEditor = false
    @State private var editing: TaskItem?

    private var filtered: [TaskItem] {
        tasks.filter { task in
            if showCompleted != task.isCompleted { return false }
            if search.isEmpty { return true }
            let q = search.lowercased()
            return task.title.lowercased().contains(q)
                || task.notes.lowercased().contains(q)
                || (task.project?.name.lowercased().contains(q) ?? false)
        }
    }

    var body: some View {
        NavigationStack {
            Group {
                if filtered.isEmpty {
                    ContentUnavailableView {
                        Label(
                            showCompleted ? "No completed work" : "Inbox is clear",
                            systemImage: showCompleted ? "checkmark.circle" : "tray"
                        )
                    } description: {
                        Text(search.isEmpty
                             ? "Add a task to start the pile."
                             : "Nothing matches that search.")
                    }
                } else {
                    List {
                        ForEach(filtered) { task in
                            TaskRowView(task: task) {
                                toggle(task)
                            }
                            .contentShape(Rectangle())
                            .onTapGesture { editing = task }
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                Button(role: .destructive) {
                                    modelContext.delete(task)
                                    try? modelContext.save()
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                            .swipeActions(edge: .leading) {
                                Button {
                                    toggle(task)
                                } label: {
                                    Label(
                                        task.isCompleted ? "Reopen" : "Done",
                                        systemImage: task.isCompleted ? "arrow.uturn.left" : "checkmark"
                                    )
                                }
                                .tint(.green)
                            }
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Tasks")
            .searchable(text: $search, prompt: "Search tasks")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Picker("Filter", selection: $showCompleted) {
                        Text("Active").tag(false)
                        Text("Done").tag(true)
                    }
                    .pickerStyle(.segmented)
                    .frame(maxWidth: 180)
                }
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
            .sheet(item: $editing) { task in
                TaskEditorView(existing: task)
            }
        }
    }

    private func toggle(_ task: TaskItem) {
        withAnimation {
            task.isCompleted.toggle()
            task.completedAt = task.isCompleted ? .now : nil
            try? modelContext.save()
        }
    }
}

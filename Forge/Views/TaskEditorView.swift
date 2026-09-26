import SwiftUI
import SwiftData

struct TaskEditorView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \Project.name) private var projects: [Project]

    var existing: TaskItem?
    var initialProject: Project?

    @State private var title: String = ""
    @State private var notes: String = ""
    @State private var priority: TaskPriority = .medium
    @State private var hasDueDate = false
    @State private var dueDate: Date = .now
    @State private var project: Project?

    var body: some View {
        NavigationStack {
            Form {
                Section("Task") {
                    TextField("What needs to get done?", text: $title, axis: .vertical)
                        .lineLimit(1...3)
                    TextField("Notes", text: $notes, axis: .vertical)
                        .lineLimit(3...8)
                }

                Section("Details") {
                    Picker("Priority", selection: $priority) {
                        ForEach(TaskPriority.allCases) { value in
                            Text(value.label).tag(value)
                        }
                    }

                    Toggle("Due date", isOn: $hasDueDate)

                    if hasDueDate {
                        DatePicker(
                            "Due",
                            selection: $dueDate,
                            displayedComponents: [.date]
                        )
                    }

                    Picker("Project", selection: $project) {
                        Text("Inbox").tag(Optional<Project>.none)
                        ForEach(projects) { item in
                            Text(item.name).tag(Optional(item))
                        }
                    }
                }
            }
            .navigationTitle(existing == nil ? "New task" : "Edit task")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                        .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                        .fontWeight(.semibold)
                }
            }
            .onAppear(perform: populate)
        }
    }

    private func populate() {
        if let existing {
            title = existing.title
            notes = existing.notes
            priority = existing.priority
            if let due = existing.dueDate {
                hasDueDate = true
                dueDate = due
            }
            project = existing.project
        } else if project == nil {
            project = initialProject
        }
    }

    private func save() {
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        if let existing {
            existing.title = trimmed
            existing.notes = notes
            existing.priority = priority
            existing.dueDate = hasDueDate ? dueDate : nil
            existing.project = project
        } else {
            let task = TaskItem(
                title: trimmed,
                notes: notes,
                priority: priority,
                dueDate: hasDueDate ? dueDate : nil,
                project: project
            )
            modelContext.insert(task)
        }

        try? modelContext.save()
        dismiss()
    }
}

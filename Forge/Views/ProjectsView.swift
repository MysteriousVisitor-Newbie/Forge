import SwiftUI
import SwiftData

struct ProjectsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Project.name) private var projects: [Project]

    @State private var showNew = false
    @State private var draftName = ""
    @State private var draftColor = "F97316"

    private let palette = [
        "F97316", "EF4444", "EAB308", "22C55E",
        "3B82F6", "8B5CF6", "EC4899", "14B8A6"
    ]

    var body: some View {
        NavigationStack {
            List {
                if projects.isEmpty {
                    ContentUnavailableView(
                        "No projects",
                        systemImage: "square.stack.3d.up",
                        description: Text("Group related work so Today stays readable.")
                    )
                } else {
                    ForEach(projects) { project in
                        NavigationLink {
                            ProjectDetailView(project: project)
                        } label: {
                            HStack(spacing: 12) {
                                Circle()
                                    .fill(project.color)
                                    .frame(width: 12, height: 12)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(project.name)
                                        .font(.body.weight(.medium))
                                    Text("\(project.activeCount) open · \(project.completedCount) done")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                            }
                            .padding(.vertical, 4)
                        }
                        .swipeActions {
                            Button(role: .destructive) {
                                modelContext.delete(project)
                                try? modelContext.save()
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                    }
                }
            }
            .navigationTitle("Projects")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        draftName = ""
                        draftColor = palette.randomElement() ?? "F97316"
                        showNew = true
                    } label: {
                        Image(systemName: "plus")
                    }
                    .accessibilityLabel("New project")
                }
            }
            .alert("New project", isPresented: $showNew) {
                TextField("Name", text: $draftName)
                Button("Cancel", role: .cancel) {}
                Button("Create") { addProject() }
            } message: {
                Text("Give the list a short name. Color is assigned automatically.")
            }
        }
    }

    private func addProject() {
        let name = draftName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !name.isEmpty else { return }
        modelContext.insert(Project(name: name, colorHex: draftColor))
        try? modelContext.save()
    }
}

struct ProjectDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable var project: Project
    @State private var showEditor = false

    private var sortedTasks: [TaskItem] {
        project.tasks.sorted { lhs, rhs in
            if lhs.isCompleted != rhs.isCompleted { return !lhs.isCompleted }
            return lhs.createdAt > rhs.createdAt
        }
    }

    var body: some View {
        List {
            ForEach(sortedTasks) { task in
                TaskRowView(task: task) {
                    task.isCompleted.toggle()
                    task.completedAt = task.isCompleted ? .now : nil
                    try? modelContext.save()
                }
            }
            .onDelete { indexSet in
                for index in indexSet {
                    modelContext.delete(sortedTasks[index])
                }
                try? modelContext.save()
            }
        }
        .navigationTitle(project.name)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    showEditor = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showEditor) {
            TaskEditorView(initialProject: project)
        }
    }
}

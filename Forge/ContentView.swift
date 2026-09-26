import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var projects: [Project]
    @Query private var tasks: [TaskItem]

    var body: some View {
        TabView {
            TodayView()
                .tabItem {
                    Label("Today", systemImage: "sun.max.fill")
                }

            TaskListView()
                .tabItem {
                    Label("Tasks", systemImage: "checkmark.circle")
                }

            ProjectsView()
                .tabItem {
                    Label("Projects", systemImage: "square.stack.3d.up")
                }

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape")
                }
        }
        .tint(Color.orange)
        .onAppear {
            if projects.isEmpty && tasks.isEmpty {
                SampleData.seed(into: modelContext)
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [TaskItem.self, Project.self], inMemory: true)
}

import Foundation

enum ProjectListFiltering {
    nonisolated static func apply(
        _ projects: [Project],
        searchText: String,
        status: ProjectStatus?,
        priority: ProjectPriority?
    ) -> [Project] {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        return projects.filter { project in
            let matchesSearch = query.isEmpty
                || project.clientName.localizedCaseInsensitiveContains(query)
                || project.projectName.localizedCaseInsensitiveContains(query)
            let matchesStatus = status.map { project.status == $0 } ?? true
            let matchesPriority = priority.map { project.priority == $0 } ?? true
            return matchesSearch && matchesStatus && matchesPriority
        }
    }
}

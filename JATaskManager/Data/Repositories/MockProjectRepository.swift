import Foundation

actor MockProjectRepository: ProjectRepository {
    private let jsonLoader: JSONLoading
    private let store: ProjectPersisting
    private let resourceName: String
    private var projects: [Project]?

    init(
        jsonLoader: JSONLoading,
        store: ProjectPersisting,
        resourceName: String = "test_data"
    ) {
        self.jsonLoader = jsonLoader
        self.store = store
        self.resourceName = resourceName
    }

    func fetchProjects() async throws -> [Project] {
        if let projects {
            return projects
        }
        if let persisted = try await store.load() {
            projects = persisted
            return persisted
        }
        let dtos = try jsonLoader.load([ProjectDTO].self, fromResource: resourceName, withExtension: "json")
        let loaded = try dtos.map(ProjectMapper.toDomain)
        try await store.save(loaded)
        projects = loaded
        return loaded
    }

    func create(_ project: Project) async throws -> Project {
        var current = try await fetchProjects()
        let newID = (current.map(\.id).max() ?? 0) + 1
        let created = Project(
            id: newID,
            clientName: project.clientName,
            projectName: project.projectName,
            description: project.description,
            status: project.status,
            priority: project.priority,
            startDate: project.startDate,
            dueDate: project.dueDate
        )
        current.append(created)
        projects = current
        try await store.save(current)
        return created
    }

    func update(_ project: Project) async throws -> Project {
        var current = try await fetchProjects()
        guard let index = current.firstIndex(where: { $0.id == project.id }) else {
            throw AppError.notFound
        }
        current[index] = project
        projects = current
        try await store.save(current)
        return project
    }

    func delete(_ project: Project) async throws {
        var current = try await fetchProjects()
        guard let index = current.firstIndex(where: { $0.id == project.id }) else {
            throw AppError.notFound
        }
        current.remove(at: index)
        projects = current
        try await store.save(current)
    }
}

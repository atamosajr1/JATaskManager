protocol ProjectRepository: Sendable {
    func fetchProjects() async throws -> [Project]
    func create(_ project: Project) async throws -> Project
    func update(_ project: Project) async throws -> Project
    func delete(_ project: Project) async throws
}

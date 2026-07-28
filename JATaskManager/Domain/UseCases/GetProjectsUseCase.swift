final class GetProjectsUseCase {
    private let repository: ProjectRepository

    init(repository: ProjectRepository) {
        self.repository = repository
    }

    func execute() async throws -> [Project] {
        try await repository.fetchProjects()
    }
}

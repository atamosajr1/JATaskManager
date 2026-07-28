final class DeleteProjectUseCase {
    private let repository: ProjectRepository

    init(repository: ProjectRepository) {
        self.repository = repository
    }

    func execute(_ project: Project) async throws {
        try await repository.delete(project)
    }
}

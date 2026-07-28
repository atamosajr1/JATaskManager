final class CreateProjectUseCase {
    private let repository: ProjectRepository

    init(repository: ProjectRepository) {
        self.repository = repository
    }

    func execute(_ project: Project) async throws -> Project {
        let errors = ProjectValidator.validate(
            clientName: project.clientName,
            projectName: project.projectName,
            startDate: project.startDate,
            dueDate: project.dueDate
        )
        guard errors.isEmpty else {
            throw AppError.validation(errors)
        }
        return try await repository.create(project)
    }
}

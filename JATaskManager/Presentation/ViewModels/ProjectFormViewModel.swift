import Combine
import Foundation

@MainActor
final class ProjectFormViewModel: ObservableObject {
    enum Mode {
        case create
        case edit(Project)
    }

    @Published var clientName: String
    @Published var projectName: String
    @Published var projectDescription: String
    @Published var status: ProjectStatus
    @Published var priority: ProjectPriority
    @Published var startDate: Date
    @Published var dueDate: Date
    @Published private(set) var fieldErrors = ProjectFormFieldErrors()
    @Published private(set) var submissionError: String?
    @Published private(set) var isSaving = false

    let mode: Mode

    private let createProjectUseCase: CreateProjectUseCase
    private let updateProjectUseCase: UpdateProjectUseCase

    var navigationTitle: String {
        switch mode {
        case .create: return "New Project"
        case .edit: return "Edit Project"
        }
    }

    init(
        mode: Mode,
        createProjectUseCase: CreateProjectUseCase,
        updateProjectUseCase: UpdateProjectUseCase
    ) {
        self.mode = mode
        self.createProjectUseCase = createProjectUseCase
        self.updateProjectUseCase = updateProjectUseCase

        switch mode {
        case .create:
            let today = Date()
            clientName = ""
            projectName = ""
            projectDescription = ""
            status = .planning
            priority = .medium
            startDate = today
            dueDate = today
        case .edit(let project):
            clientName = project.clientName
            projectName = project.projectName
            projectDescription = project.description ?? ""
            status = project.status
            priority = project.priority
            startDate = project.startDate
            dueDate = project.dueDate
        }
    }
}

// MARK: - Actions

extension ProjectFormViewModel {
    func save() async -> Project? {
        guard !isSaving else { return nil }
        isSaving = true
        defer { isSaving = false }
        submissionError = nil

        let candidate = buildProject()
        let errors = ProjectValidator.validate(
            clientName: candidate.clientName,
            projectName: candidate.projectName,
            startDate: candidate.startDate,
            dueDate: candidate.dueDate
        )
        guard errors.isEmpty else {
            fieldErrors.apply(errors)
            return nil
        }
        fieldErrors = ProjectFormFieldErrors()

        do {
            switch mode {
            case .create:
                return try await createProjectUseCase.execute(candidate)
            case .edit:
                return try await updateProjectUseCase.execute(candidate)
            }
        } catch let AppError.validation(useCaseErrors) {
            fieldErrors.apply(useCaseErrors)
            return nil
        } catch {
            submissionError = "Couldn't save this project. Please try again."
            return nil
        }
    }

    func clearSubmissionError() {
        submissionError = nil
    }
}

// MARK: - Private helpers

private extension ProjectFormViewModel {
    func buildProject() -> Project {
        let trimmedClientName = clientName.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedProjectName = projectName.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedDescription = projectDescription.trimmingCharacters(in: .whitespacesAndNewlines)
        let existingID: Int
        switch mode {
        case .create: existingID = 0
        case .edit(let project): existingID = project.id
        }
        return Project(
            id: existingID,
            clientName: trimmedClientName,
            projectName: trimmedProjectName,
            description: trimmedDescription.isEmpty ? nil : trimmedDescription,
            status: status,
            priority: priority,
            startDate: startDate,
            dueDate: dueDate
        )
    }
}

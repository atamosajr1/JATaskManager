import Combine
import SwiftUI

enum ProjectRoute: Hashable {
    case detail(Project)
}

@MainActor
final class ProjectCoordinator: ObservableObject {
    @Published var path = NavigationPath()
    @Published var isShowingCreateSheet = false
    @Published var isShowingEditSheet = false
    @Published private(set) var projectPendingEdit: Project?

    private var onEditSaved: ((Project) -> Void)?

    private let getProjectsUseCase: GetProjectsUseCase
    private let createProjectUseCase: CreateProjectUseCase
    private let updateProjectUseCase: UpdateProjectUseCase
    private let deleteProjectUseCase: DeleteProjectUseCase
    let notificationService: ProjectNotifying

    init(
        getProjectsUseCase: GetProjectsUseCase,
        createProjectUseCase: CreateProjectUseCase,
        updateProjectUseCase: UpdateProjectUseCase,
        deleteProjectUseCase: DeleteProjectUseCase,
        notificationService: ProjectNotifying
    ) {
        self.getProjectsUseCase = getProjectsUseCase
        self.createProjectUseCase = createProjectUseCase
        self.updateProjectUseCase = updateProjectUseCase
        self.deleteProjectUseCase = deleteProjectUseCase
        self.notificationService = notificationService
    }
}

// MARK: - Screen factories

extension ProjectCoordinator {
    func makeListViewModel() -> ProjectListViewModel {
        ProjectListViewModel(getProjectsUseCase: getProjectsUseCase)
    }

    func makeDetailViewModel(for project: Project) -> ProjectDetailViewModel {
        ProjectDetailViewModel(project: project, deleteProjectUseCase: deleteProjectUseCase)
    }

    func makeFormViewModel(mode: ProjectFormViewModel.Mode) -> ProjectFormViewModel {
        ProjectFormViewModel(
            mode: mode,
            createProjectUseCase: createProjectUseCase,
            updateProjectUseCase: updateProjectUseCase
        )
    }
}

// MARK: - Navigation actions

extension ProjectCoordinator {
    func showDetail(for project: Project) {
        path.append(ProjectRoute.detail(project))
    }

    func showCreate() {
        isShowingCreateSheet = true
    }

    func dismissCreateSheet() {
        isShowingCreateSheet = false
    }

    func showEdit(for project: Project, onSaved: @escaping (Project) -> Void) {
        projectPendingEdit = project
        onEditSaved = onSaved
        isShowingEditSheet = true
    }

    func dismissEditSheet() {
        isShowingEditSheet = false
        projectPendingEdit = nil
        onEditSaved = nil
    }

    func handleEditSaved(_ project: Project) {
        onEditSaved?(project)
        dismissEditSheet()
    }
}

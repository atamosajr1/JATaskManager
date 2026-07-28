import Combine
import Foundation

@MainActor
final class ProjectDetailViewModel: ObservableObject {
    @Published private(set) var project: Project
    @Published private(set) var errorMessage: String?
    @Published private(set) var isDeleting = false

    private let deleteProjectUseCase: DeleteProjectUseCase

    init(project: Project, deleteProjectUseCase: DeleteProjectUseCase) {
        self.project = project
        self.deleteProjectUseCase = deleteProjectUseCase
    }

    func delete() async -> Bool {
        guard !isDeleting else { return false }
        isDeleting = true
        defer { isDeleting = false }
        do {
            try await deleteProjectUseCase.execute(project)
            return true
        } catch {
            errorMessage = "Couldn't delete this project. Please try again."
            return false
        }
    }

    /// Called after a successful edit so this screen reflects the saved
    /// values immediately, without waiting for the list to reload.
    func updateProject(_ project: Project) {
        self.project = project
    }

    func clearError() {
        errorMessage = nil
    }
}

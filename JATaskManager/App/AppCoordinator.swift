import Combine
import SwiftUI

@MainActor
final class AppCoordinator: ObservableObject {
    let projectCoordinator: ProjectCoordinator
    let notificationService: ProjectNotifying

    init(
        store: ProjectPersisting? = nil,
        notificationService: ProjectNotifying = ProjectNotificationService()
    ) {
        let resolvedStore: ProjectPersisting
        if let store {
            resolvedStore = store
        } else {
            do {
                resolvedStore = try FileProjectStore.applicationSupportStore()
            } catch {
                // Fall back to an ephemeral in-memory-only store path under tmp
                // so the app can still launch if Application Support is unavailable.
                let fallback = FileManager.default.temporaryDirectory
                    .appendingPathComponent("JATaskManager-fallback", isDirectory: true)
                try? FileManager.default.createDirectory(at: fallback, withIntermediateDirectories: true)
                resolvedStore = FileProjectStore(directoryURL: fallback)
            }
        }

        let repository = MockProjectRepository(jsonLoader: JSONLoader(), store: resolvedStore)
        self.notificationService = notificationService
        projectCoordinator = ProjectCoordinator(
            getProjectsUseCase: GetProjectsUseCase(repository: repository),
            createProjectUseCase: CreateProjectUseCase(repository: repository),
            updateProjectUseCase: UpdateProjectUseCase(repository: repository),
            deleteProjectUseCase: DeleteProjectUseCase(repository: repository),
            notificationService: notificationService
        )
    }
}

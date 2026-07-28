import Combine
import Foundation

@MainActor
final class ProjectListViewModel: ObservableObject {
    @Published private(set) var state: ProjectListViewState = .loading
    @Published var searchText = "" {
        didSet { recomputeStateIfReady() }
    }
    @Published var statusFilter: ProjectStatus? {
        didSet { recomputeStateIfReady() }
    }
    @Published var priorityFilter: ProjectPriority? {
        didSet { recomputeStateIfReady() }
    }

    private var allProjects: [Project] = []
    private var hasLoadedOnce = false
    private let getProjectsUseCase: GetProjectsUseCase

    var hasActiveFilters: Bool {
        !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            || statusFilter != nil
            || priorityFilter != nil
    }

    init(getProjectsUseCase: GetProjectsUseCase) {
        self.getProjectsUseCase = getProjectsUseCase
    }

    func load() async {
        state = .loading
        await refresh()
    }

    func refresh() async {
        do {
            allProjects = try await getProjectsUseCase.execute()
            hasLoadedOnce = true
            applyFiltersToState()
        } catch {
            state = .error(message: Self.message(for: error))
        }
    }

    func clearFilters() {
        searchText = ""
        statusFilter = nil
        priorityFilter = nil
    }

    private func recomputeStateIfReady() {
        guard hasLoadedOnce else { return }
        applyFiltersToState()
    }

    private func applyFiltersToState() {
        if allProjects.isEmpty {
            state = .empty
            return
        }
        let filtered = ProjectListFiltering.apply(
            allProjects,
            searchText: searchText,
            status: statusFilter,
            priority: priorityFilter
        )
        state = filtered.isEmpty ? .noMatches : .loaded(filtered)
    }

    private static func message(for error: Error) -> String {
        guard let appError = error as? AppError else {
            return "Something went wrong. Please try again."
        }
        switch appError {
        case .dataLoadFailure, .persistenceFailure:
            return "Couldn't load projects. Please try again."
        case .notFound, .validation, .unknown:
            return "Something went wrong. Please try again."
        }
    }
}

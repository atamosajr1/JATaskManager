import SwiftUI

struct ProjectListView: View {
    @StateObject var viewModel: ProjectListViewModel
    @EnvironmentObject private var coordinator: ProjectCoordinator
    @AppStorage("appAppearance") private var appearanceRaw = AppAppearance.system.rawValue

    var body: some View {
        NavigationStack(path: $coordinator.path) {
            content
                .navigationTitle("Client Projects")
                .searchable(text: $viewModel.searchText, prompt: "Search clients or projects")
                .toolbar {
                    ToolbarItem(placement: .primaryAction) {
                        Button {
                            coordinator.showCreate()
                        } label: {
                            Label("New Project", systemImage: "plus")
                        }
                    }
                    ToolbarItem(placement: .topBarLeading) {
                        filterMenu
                    }
                    ToolbarItem(placement: .topBarLeading) {
                        appearanceMenu
                    }
                }
                .navigationDestination(for: ProjectRoute.self) { route in
                    switch route {
                    case .detail(let project):
                        ProjectDetailView(
                            viewModel: coordinator.makeDetailViewModel(for: project)
                        )
                    }
                }
                .sheet(isPresented: $coordinator.isShowingCreateSheet) {
                    NavigationStack {
                        ProjectFormView(
                            viewModel: coordinator.makeFormViewModel(mode: .create),
                            onSaved: { saved in
                                coordinator.dismissCreateSheet()
                                Task {
                                    await coordinator.notificationService.scheduleDueSoonIfNeeded(for: saved)
                                    await viewModel.refresh()
                                }
                            }
                        )
                    }
                }
                .sheet(isPresented: $coordinator.isShowingEditSheet) {
                    if let project = coordinator.projectPendingEdit {
                        NavigationStack {
                            ProjectFormView(
                                viewModel: coordinator.makeFormViewModel(mode: .edit(project)),
                                onSaved: { saved in
                                    coordinator.handleEditSaved(saved)
                                    Task {
                                        await coordinator.notificationService.scheduleDueSoonIfNeeded(for: saved)
                                        await viewModel.refresh()
                                    }
                                }
                            )
                        }
                    }
                }
                .task {
                    await viewModel.load()
                    _ = await coordinator.notificationService.requestAuthorization()
                }
                .onAppear {
                    Task { await viewModel.refresh() }
                }
        }
    }

    private var filterMenu: some View {
        Menu {
            Section("Status") {
                Button("All Statuses") { viewModel.statusFilter = nil }
                ForEach(ProjectStatus.allCases, id: \.self) { status in
                    Button {
                        viewModel.statusFilter = status
                    } label: {
                        if viewModel.statusFilter == status {
                            Label(status.rawValue, systemImage: "checkmark")
                        } else {
                            Text(status.rawValue)
                        }
                    }
                }
            }
            Section("Priority") {
                Button("All Priorities") { viewModel.priorityFilter = nil }
                ForEach(ProjectPriority.allCases, id: \.self) { priority in
                    Button {
                        viewModel.priorityFilter = priority
                    } label: {
                        if viewModel.priorityFilter == priority {
                            Label(priority.rawValue, systemImage: "checkmark")
                        } else {
                            Text(priority.rawValue)
                        }
                    }
                }
            }
            if viewModel.hasActiveFilters {
                Divider()
                Button("Clear Filters", role: .destructive) {
                    viewModel.clearFilters()
                }
            }
        } label: {
            Label(
                "Filter",
                systemImage: viewModel.hasActiveFilters ? "line.3.horizontal.decrease.circle.fill" : "line.3.horizontal.decrease.circle"
            )
        }
    }

    private var appearanceMenu: some View {
        Menu {
            ForEach(AppAppearance.allCases) { appearance in
                Button {
                    appearanceRaw = appearance.rawValue
                } label: {
                    if appearanceRaw == appearance.rawValue {
                        Label(appearance.title, systemImage: "checkmark")
                    } else {
                        Text(appearance.title)
                    }
                }
            }
        } label: {
            Label("Appearance", systemImage: "circle.lefthalf.filled")
        }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .loading:
            ProgressView("Loading projects…")
        case .empty:
            ContentUnavailableView(
                "No Projects Yet",
                systemImage: "folder.badge.plus",
                description: Text("Create your first client project to get started.")
            )
        case .noMatches:
            ContentUnavailableView(
                "No Matching Projects",
                systemImage: "magnifyingglass",
                description: Text("Try a different search or clear your filters.")
            )
        case .error(let message):
            ContentUnavailableView {
                Label("Something Went Wrong", systemImage: "exclamationmark.triangle")
            } description: {
                Text(message)
            } actions: {
                Button("Try Again") {
                    Task { await viewModel.refresh() }
                }
            }
        case .loaded(let projects):
            List(projects) { project in
                Button {
                    coordinator.showDetail(for: project)
                } label: {
                    ProjectRow(project: project)
                }
                .buttonStyle(.plain)
            }
            .refreshable {
                await viewModel.refresh()
            }
        }
    }
}

private struct ProjectRow: View {
    let project: Project

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(project.clientName)
                .font(.headline)
            Text(project.projectName)
                .font(.subheadline)
            HStack {
                Label(project.status.rawValue, systemImage: "circle.fill")
                    .font(.caption)
                Spacer()
                Label(project.priority.rawValue, systemImage: "flag.fill")
                    .font(.caption)
                Spacer()
                Text(project.dueDate, format: .dateTime.month().day().year())
                    .font(.caption)
            }
            .foregroundStyle(.secondary)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    let store = FileProjectStore(directoryURL: FileManager.default.temporaryDirectory)
    let repository = MockProjectRepository(jsonLoader: JSONLoader(), store: store)
    let notifications = ProjectNotificationService()
    let coordinator = ProjectCoordinator(
        getProjectsUseCase: GetProjectsUseCase(repository: repository),
        createProjectUseCase: CreateProjectUseCase(repository: repository),
        updateProjectUseCase: UpdateProjectUseCase(repository: repository),
        deleteProjectUseCase: DeleteProjectUseCase(repository: repository),
        notificationService: notifications
    )
    return ProjectListView(viewModel: coordinator.makeListViewModel())
        .environmentObject(coordinator)
}

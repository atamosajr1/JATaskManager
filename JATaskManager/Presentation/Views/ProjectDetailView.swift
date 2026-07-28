import SwiftUI

struct ProjectDetailView: View {
    @StateObject var viewModel: ProjectDetailViewModel
    @EnvironmentObject private var coordinator: ProjectCoordinator
    @Environment(\.dismiss) private var dismiss
    @State private var isShowingDeleteConfirmation = false
    @State private var notificationErrorMessage: String?

    var body: some View {
        Form {
            Section("Client") {
                LabeledContent("ID", value: "\(viewModel.project.id)")
                LabeledContent("Client Name", value: viewModel.project.clientName)
                LabeledContent("Project Name", value: viewModel.project.projectName)
            }
            Section("Status") {
                LabeledContent("Status", value: viewModel.project.status.rawValue)
                LabeledContent("Priority", value: viewModel.project.priority.rawValue)
            }
            Section("Timeline") {
                LabeledContent(
                    "Start Date",
                    value: viewModel.project.startDate,
                    format: .dateTime.month().day().year()
                )
                LabeledContent(
                    "Due Date",
                    value: viewModel.project.dueDate,
                    format: .dateTime.month().day().year()
                )
            }
            if let description = viewModel.project.description, !description.isEmpty {
                Section("Description") {
                    Text(description)
                }
            }
        }
        .disabled(viewModel.isDeleting)
        .overlay {
            if viewModel.isDeleting {
                ProgressView("Deleting…")
                    .padding()
                    .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
            }
        }
        .navigationTitle(viewModel.project.projectName)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Edit") {
                    coordinator.showEdit(for: viewModel.project) { updated in
                        viewModel.updateProject(updated)
                    }
                }
                .disabled(viewModel.isDeleting)
            }
            ToolbarItem(placement: .primaryAction) {
                Button {
                    Task {
                        do {
                            try await coordinator.notificationService.sendDemoNotification(
                                for: viewModel.project
                            )
                        } catch {
                            notificationErrorMessage =
                                "Notifications are off. Enable them in Settings to try the demo."
                        }
                    }
                } label: {
                    Label("Demo Notification", systemImage: "bell")
                }
                .disabled(viewModel.isDeleting)
            }
            ToolbarItem(placement: .destructiveAction) {
                if viewModel.isDeleting {
                    ProgressView()
                } else {
                    Button("Delete", role: .destructive) {
                        isShowingDeleteConfirmation = true
                    }
                }
            }
        }
        .confirmationDialog(
            "Delete this project?",
            isPresented: $isShowingDeleteConfirmation,
            titleVisibility: .visible
        ) {
            Button("Delete", role: .destructive) {
                Task {
                    if await viewModel.delete() {
                        dismiss()
                    }
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This can't be undone.")
        }
        .alert(
            "Couldn't Delete Project",
            isPresented: Binding(
                get: { viewModel.errorMessage != nil },
                set: { isPresented in if !isPresented { viewModel.clearError() } }
            ),
            actions: { Button("OK") {} },
            message: { Text(viewModel.errorMessage ?? "") }
        )
        .alert(
            "Notification Unavailable",
            isPresented: Binding(
                get: { notificationErrorMessage != nil },
                set: { isPresented in if !isPresented { notificationErrorMessage = nil } }
            ),
            actions: { Button("OK") {} },
            message: { Text(notificationErrorMessage ?? "") }
        )
    }
}

#Preview {
    let store = FileProjectStore(directoryURL: FileManager.default.temporaryDirectory)
    let repository = MockProjectRepository(jsonLoader: JSONLoader(), store: store)
    let notifications = ProjectNotificationService()
    return NavigationStack {
        ProjectDetailView(
            viewModel: ProjectDetailViewModel(
                project: Project(
                    id: 1,
                    clientName: "Acme Corporation",
                    projectName: "Corporate Website Redesign",
                    description: "Redesign and modernize the company's corporate website.",
                    status: .inProgress,
                    priority: .high,
                    startDate: .now,
                    dueDate: .now.addingTimeInterval(60 * 60 * 24 * 30)
                ),
                deleteProjectUseCase: DeleteProjectUseCase(repository: repository)
            )
        )
    }
    .environmentObject(
        ProjectCoordinator(
            getProjectsUseCase: GetProjectsUseCase(repository: repository),
            createProjectUseCase: CreateProjectUseCase(repository: repository),
            updateProjectUseCase: UpdateProjectUseCase(repository: repository),
            deleteProjectUseCase: DeleteProjectUseCase(repository: repository),
            notificationService: notifications
        )
    )
}

import SwiftUI

struct ProjectFormView: View {
    @StateObject var viewModel: ProjectFormViewModel
    @Environment(\.dismiss) private var dismiss
    let onSaved: (Project) -> Void

    var body: some View {
        Form {
            Section("Client") {
                TextField("Client Name", text: $viewModel.clientName)
                if let error = viewModel.fieldErrors.clientName {
                    Text(error).font(.caption).foregroundStyle(.red)
                }
                TextField("Project Name", text: $viewModel.projectName)
                if let error = viewModel.fieldErrors.projectName {
                    Text(error).font(.caption).foregroundStyle(.red)
                }
            }

            Section("Details") {
                Picker("Status", selection: $viewModel.status) {
                    ForEach(ProjectStatus.allCases, id: \.self) { status in
                        Text(status.rawValue).tag(status)
                    }
                }
                Picker("Priority", selection: $viewModel.priority) {
                    ForEach(ProjectPriority.allCases, id: \.self) { priority in
                        Text(priority.rawValue).tag(priority)
                    }
                }
            }

            Section("Timeline") {
                PopoverDatePickerRow(label: "Start Date", date: $viewModel.startDate)
                PopoverDatePickerRow(label: "Due Date", date: $viewModel.dueDate)
                if let error = viewModel.fieldErrors.dueDate {
                    Text(error).font(.caption).foregroundStyle(.red)
                }
            }

            Section("Description") {
                TextField("Description (optional)", text: $viewModel.projectDescription, axis: .vertical)
                    .lineLimit(3...6)
            }
        }
        .disabled(viewModel.isSaving)
        .overlay {
            if viewModel.isSaving {
                ProgressView("Saving…")
                    .padding()
                    .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
            }
        }
        .navigationTitle(viewModel.navigationTitle)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") { dismiss() }
                    .disabled(viewModel.isSaving)
            }
            ToolbarItem(placement: .confirmationAction) {
                if viewModel.isSaving {
                    ProgressView()
                } else {
                    Button("Save") {
                        Task {
                            if let saved = await viewModel.save() {
                                onSaved(saved)
                            }
                        }
                    }
                }
            }
        }
        .alert(
            "Couldn't Save Project",
            isPresented: Binding(
                get: { viewModel.submissionError != nil },
                set: { isPresented in if !isPresented { viewModel.clearSubmissionError() } }
            ),
            actions: { Button("OK") {} },
            message: { Text(viewModel.submissionError ?? "") }
        )
    }
}

#Preview {
    let store = FileProjectStore(directoryURL: FileManager.default.temporaryDirectory)
    let repository = MockProjectRepository(jsonLoader: JSONLoader(), store: store)
    return NavigationStack {
        ProjectFormView(
            viewModel: ProjectFormViewModel(
                mode: .create,
                createProjectUseCase: CreateProjectUseCase(repository: repository),
                updateProjectUseCase: UpdateProjectUseCase(repository: repository)
            ),
            onSaved: { _ in }
        )
    }
}

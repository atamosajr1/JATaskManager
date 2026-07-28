struct ProjectFormFieldErrors: Equatable, Sendable {
    var clientName: String?
    var projectName: String?
    var dueDate: String?

    var isEmpty: Bool {
        clientName == nil && projectName == nil && dueDate == nil
    }

    mutating func apply(_ errors: [ProjectValidationError]) {
        clientName = nil
        projectName = nil
        dueDate = nil
        for error in errors {
            switch error {
            case .missingClientName:
                clientName = error.message
            case .missingProjectName:
                projectName = error.message
            case .dueDateBeforeStartDate:
                dueDate = error.message
            }
        }
    }
}

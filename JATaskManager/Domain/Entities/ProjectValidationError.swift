enum ProjectValidationError: Error, Equatable, Sendable {
    case missingClientName
    case missingProjectName
    case dueDateBeforeStartDate

    var message: String {
        switch self {
        case .missingClientName:
            return "Client name is required."
        case .missingProjectName:
            return "Project name is required."
        case .dueDateBeforeStartDate:
            return "Due date must be on or after the start date."
        }
    }
}

import Foundation

enum ProjectValidator {
    static func validate(clientName: String, projectName: String, startDate: Date, dueDate: Date) -> [ProjectValidationError] {
        var errors: [ProjectValidationError] = []

        if clientName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            errors.append(.missingClientName)
        }
        if projectName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            errors.append(.missingProjectName)
        }
        if dueDate < startDate {
            errors.append(.dueDateBeforeStartDate)
        }

        return errors
    }
}

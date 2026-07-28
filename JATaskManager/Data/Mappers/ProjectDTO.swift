import Foundation

/// Wire format for a project record in `test_data.json`. Kept separate from
/// `Project` so the on-disk shape can change independently of the domain entity.
struct ProjectDTO: Codable {
    let id: Int
    let clientName: String
    let projectName: String
    let description: String?
    let status: String
    let priority: String
    let startDate: Date
    let dueDate: Date
}

enum ProjectMapper {
    nonisolated static func toDomain(_ dto: ProjectDTO) throws -> Project {
        guard let status = ProjectStatus(rawValue: dto.status) else {
            throw AppError.dataLoadFailure
        }
        guard let priority = ProjectPriority(rawValue: dto.priority) else {
            throw AppError.dataLoadFailure
        }
        return Project(
            id: dto.id,
            clientName: dto.clientName,
            projectName: dto.projectName,
            description: dto.description,
            status: status,
            priority: priority,
            startDate: dto.startDate,
            dueDate: dto.dueDate
        )
    }

    nonisolated static func toDTO(_ project: Project) -> ProjectDTO {
        ProjectDTO(
            id: project.id,
            clientName: project.clientName,
            projectName: project.projectName,
            description: project.description,
            status: project.status.rawValue,
            priority: project.priority.rawValue,
            startDate: project.startDate,
            dueDate: project.dueDate
        )
    }
}

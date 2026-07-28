import Foundation

struct Project: Codable, Identifiable, Equatable, Hashable, Sendable {
    let id: Int
    var clientName: String
    var projectName: String
    var description: String?
    var status: ProjectStatus
    var priority: ProjectPriority
    var startDate: Date
    var dueDate: Date
}

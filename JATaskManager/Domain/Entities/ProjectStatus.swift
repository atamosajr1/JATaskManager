enum ProjectStatus: String, Codable, CaseIterable, Hashable, Sendable {
    case planning = "Planning"
    case inProgress = "In Progress"
    case onHold = "On Hold"
    case completed = "Completed"
}

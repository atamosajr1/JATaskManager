enum ProjectListViewState: Equatable, Sendable {
    case loading
    case loaded([Project])
    case empty
    case noMatches
    case error(message: String)
}

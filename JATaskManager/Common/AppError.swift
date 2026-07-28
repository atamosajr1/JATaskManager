enum AppError: Error, Equatable, Sendable {
    case dataLoadFailure
    case persistenceFailure
    case notFound
    case validation([ProjectValidationError])
    case unknown
}

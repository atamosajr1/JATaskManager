import Foundation

protocol ProjectPersisting: Sendable {
    func load() async throws -> [Project]?
    func save(_ projects: [Project]) async throws
}

actor FileProjectStore: ProjectPersisting {
    private let fileURL: URL

    init(directoryURL: URL, fileName: String = "projects.json") {
        self.fileURL = directoryURL.appendingPathComponent(fileName)
    }

    static func applicationSupportStore() throws -> FileProjectStore {
        let fileManager = FileManager.default
        let base = try fileManager.url(
            for: .applicationSupportDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        )
        let directory = base.appendingPathComponent("JATaskManager", isDirectory: true)
        try fileManager.createDirectory(at: directory, withIntermediateDirectories: true)
        return FileProjectStore(directoryURL: directory)
    }

    func load() async throws -> [Project]? {
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            return nil
        }
        do {
            let data = try Data(contentsOf: fileURL)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = Self.dateDecodingStrategy
            let dtos = try decoder.decode([ProjectDTO].self, from: data)
            return try dtos.map(ProjectMapper.toDomain)
        } catch is AppError {
            throw AppError.persistenceFailure
        } catch {
            throw AppError.persistenceFailure
        }
    }

    func save(_ projects: [Project]) async throws {
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
            encoder.dateEncodingStrategy = Self.dateEncodingStrategy
            let data = try encoder.encode(projects.map(ProjectMapper.toDTO))
            try data.write(to: fileURL, options: [.atomic])
        } catch {
            throw AppError.persistenceFailure
        }
    }

    nonisolated private static var dateDecodingStrategy: JSONDecoder.DateDecodingStrategy {
        .custom { decoder in
            let formatter = ISO8601DateFormatter()
            formatter.formatOptions = [.withFullDate]
            let container = try decoder.singleValueContainer()
            let string = try container.decode(String.self)
            guard let date = formatter.date(from: string) else {
                throw DecodingError.dataCorruptedError(
                    in: container,
                    debugDescription: "Expected ISO8601 full-date, got \(string)"
                )
            }
            return date
        }
    }

    nonisolated private static var dateEncodingStrategy: JSONEncoder.DateEncodingStrategy {
        .custom { date, encoder in
            let formatter = ISO8601DateFormatter()
            formatter.formatOptions = [.withFullDate]
            var container = encoder.singleValueContainer()
            try container.encode(formatter.string(from: date))
        }
    }
}

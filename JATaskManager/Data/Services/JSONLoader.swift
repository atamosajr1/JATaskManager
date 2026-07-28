import Foundation

protocol JSONLoading: Sendable {
    nonisolated func load<T: Decodable>(_ type: T.Type, fromResource name: String, withExtension ext: String) throws -> T
}

/// Dates are decoded as ISO8601 full-date strings (e.g. "2026-06-01") rather than
/// full timestamps, matching the shape of the bundled test data.
struct JSONLoader: JSONLoading {
    private let bundle: Bundle

    init(bundle: Bundle = .main) {
        self.bundle = bundle
    }

    nonisolated func load<T: Decodable>(_ type: T.Type, fromResource name: String, withExtension ext: String) throws -> T {
        guard let url = bundle.url(forResource: name, withExtension: ext) else {
            throw AppError.dataLoadFailure
        }

        let data: Data
        do {
            data = try Data(contentsOf: url)
        } catch {
            throw AppError.dataLoadFailure
        }

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .custom { valueDecoder in
            // Constructed locally (rather than captured from an outer scope) so the
            // `.custom` closure doesn't hold a reference to a non-Sendable
            // `ISO8601DateFormatter` instance across concurrency domains.
            let dateFormatter = ISO8601DateFormatter()
            dateFormatter.formatOptions = [.withFullDate]
            let container = try valueDecoder.singleValueContainer()
            let dateString = try container.decode(String.self)
            guard let date = dateFormatter.date(from: dateString) else {
                throw DecodingError.dataCorruptedError(
                    in: container,
                    debugDescription: "Expected ISO8601 full-date string, got \(dateString)"
                )
            }
            return date
        }

        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw AppError.dataLoadFailure
        }
    }
}

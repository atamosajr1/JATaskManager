import Foundation
import Testing
@testable import JATaskManager

@Suite
@MainActor
struct FileProjectStoreTests {
    @Test
    func saveThenLoadRoundTripsProjects() async throws {
        let directory = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: directory) }

        let store = FileProjectStore(directoryURL: directory)
        // Use a date-only value that round-trips through ISO8601 `.withFullDate`.
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withFullDate]
        let day = try #require(formatter.date(from: "2026-06-01"))
        let project = Project(
            id: 1,
            clientName: "Acme",
            projectName: "Site",
            description: "x",
            status: .planning,
            priority: .low,
            startDate: day,
            dueDate: day
        )
        try await store.save([project])
        let loaded = try await store.load()
        #expect(loaded == [project])
    }

    @Test
    func loadReturnsNilWhenFileMissing() async throws {
        let directory = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: directory) }

        let store = FileProjectStore(directoryURL: directory)
        let loaded = try await store.load()
        #expect(loaded == nil)
    }
}

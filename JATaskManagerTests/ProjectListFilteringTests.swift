import Foundation
import Testing
@testable import JATaskManager

@Suite
@MainActor
struct ProjectListFilteringTests {
    private let samples: [Project] = [
        Project(
            id: 1,
            clientName: "Acme",
            projectName: "Website",
            description: nil,
            status: .inProgress,
            priority: .high,
            startDate: .now,
            dueDate: .now
        ),
        Project(
            id: 2,
            clientName: "Beta Co",
            projectName: "App Redesign",
            description: nil,
            status: .planning,
            priority: .low,
            startDate: .now,
            dueDate: .now
        ),
        Project(
            id: 3,
            clientName: "Acme",
            projectName: "Brand Guide",
            description: nil,
            status: .completed,
            priority: .medium,
            startDate: .now,
            dueDate: .now
        ),
    ]

    @Test
    func searchMatchesClientOrProjectNameCaseInsensitive() {
        let result = ProjectListFiltering.apply(
            samples,
            searchText: "acme",
            status: nil,
            priority: nil
        )
        #expect(result.map(\.id) == [1, 3])
    }

    @Test
    func statusAndPriorityFiltersCombine() {
        let result = ProjectListFiltering.apply(
            samples,
            searchText: "",
            status: .inProgress,
            priority: .high
        )
        #expect(result.map(\.id) == [1])
    }

    @Test
    func emptySearchAndNilFiltersReturnsAll() {
        let result = ProjectListFiltering.apply(
            samples,
            searchText: "  ",
            status: nil,
            priority: nil
        )
        #expect(result.count == 3)
    }
}

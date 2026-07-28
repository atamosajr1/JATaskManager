import Foundation
import UserNotifications

protocol ProjectNotifying: Sendable {
    func requestAuthorization() async -> Bool
    func scheduleDueSoonIfNeeded(for project: Project) async
    func sendDemoNotification(for project: Project) async throws
}

struct ProjectNotificationService: ProjectNotifying {
    private let center: UNUserNotificationCenter

    init(center: UNUserNotificationCenter = .current()) {
        self.center = center
    }

    func requestAuthorization() async -> Bool {
        do {
            return try await center.requestAuthorization(options: [.alert, .sound, .badge])
        } catch {
            return false
        }
    }

    func scheduleDueSoonIfNeeded(for project: Project) async {
        guard project.status != .completed else { return }

        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let dueDay = calendar.startOfDay(for: project.dueDate)
        guard let days = calendar.dateComponents([.day], from: today, to: dueDay).day,
              days >= 0,
              days <= 3
        else {
            return
        }

        let content = UNMutableNotificationContent()
        content.title = "Project due soon"
        content.body = "\(project.projectName) for \(project.clientName) is due within \(days) day(s)."
        content.sound = .default

        let identifier = "due-soon-\(project.id)"
        center.removePendingNotificationRequests(withIdentifiers: [identifier])

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        try? await center.add(request)
    }

    func sendDemoNotification(for project: Project) async throws {
        let authorized = await requestAuthorization()
        guard authorized else {
            throw AppError.unknown
        }

        let content = UNMutableNotificationContent()
        content.title = "Project reminder"
        content.body = "\(project.projectName) — \(project.clientName)"
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(
            identifier: "demo-\(project.id)-\(UUID().uuidString)",
            content: content,
            trigger: trigger
        )
        try await center.add(request)
    }
}

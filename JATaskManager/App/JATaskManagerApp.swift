import SwiftUI

@main
struct JATaskManagerApp: App {
    @StateObject private var appCoordinator = AppCoordinator()
    @AppStorage("appAppearance") private var appearanceRaw = AppAppearance.system.rawValue

    private var appearance: AppAppearance {
        AppAppearance(rawValue: appearanceRaw) ?? .system
    }

    var body: some Scene {
        WindowGroup {
            ProjectListView(
                viewModel: appCoordinator.projectCoordinator.makeListViewModel()
            )
            .environmentObject(appCoordinator.projectCoordinator)
            .preferredColorScheme(appearance.colorScheme)
        }
    }
}

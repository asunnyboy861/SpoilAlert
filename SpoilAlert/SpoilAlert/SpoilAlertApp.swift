import SwiftUI
import SwiftData

@main
struct SpoilAlertApp: App {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @AppStorage("isDarkMode") private var isDarkMode = false

    var body: some Scene {
        WindowGroup {
            Group {
                if hasCompletedOnboarding {
                    ContentView()
                } else {
                    OnboardingView()
                }
            }
            .preferredColorScheme(isDarkMode ? .dark : .light)
            .task {
                _ = try? await NotificationService.shared.requestAuthorization()
            }
        }
        .modelContainer(for: [SkincareProduct.self, SkinLog.self])
    }
}

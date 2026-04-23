import SwiftUI

enum AppTab: String, CaseIterable {
    case dashboard = "Dashboard"
    case products = "Products"
    case checkIn = "Check-in"
    case journal = "Journal"
    case settings = "Settings"

    var icon: String {
        switch self {
        case .dashboard: return "gauge.with.dots.needle.33percent"
        case .products: return "bottle.fill"
        case .checkIn: return "checkmark.circle.fill"
        case .journal: return "book.fill"
        case .settings: return "gearshape.fill"
        }
    }
}

struct ContentView: View {
    @State private var selectedTab: AppTab = .dashboard

    var body: some View {
        TabView(selection: $selectedTab) {
            DashboardView()
                .tabItem {
                    Label(AppTab.dashboard.rawValue, systemImage: AppTab.dashboard.icon)
                }
                .tag(AppTab.dashboard)

            ProductListView()
                .tabItem {
                    Label(AppTab.products.rawValue, systemImage: AppTab.products.icon)
                }
                .tag(AppTab.products)

            DailyCheckInView()
                .tabItem {
                    Label(AppTab.checkIn.rawValue, systemImage: AppTab.checkIn.icon)
                }
                .tag(AppTab.checkIn)

            SkinJournalView()
                .tabItem {
                    Label(AppTab.journal.rawValue, systemImage: AppTab.journal.icon)
                }
                .tag(AppTab.journal)

            SettingsView()
                .tabItem {
                    Label(AppTab.settings.rawValue, systemImage: AppTab.settings.icon)
                }
                .tag(AppTab.settings)
        }
    }
}

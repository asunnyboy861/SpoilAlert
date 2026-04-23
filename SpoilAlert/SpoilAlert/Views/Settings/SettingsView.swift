import SwiftUI
import SwiftData

struct SettingsView: View {
    @AppStorage("isDarkMode") private var isDarkMode = false
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @EnvironmentObject private var purchaseManager: PurchaseManager
    @Environment(\.modelContext) private var modelContext
    @State private var showPaywall = false

    var body: some View {
        NavigationStack {
            Form {
                subscriptionSection
                appearanceSection
                notificationsSection
                dataSection
                aboutSection
            }
            .navigationTitle("Settings")
            .sheet(isPresented: $showPaywall) {
                PaywallView()
            }
        }
    }

    private var subscriptionSection: some View {
        Section("Subscription") {
            HStack {
                Image(systemName: purchaseManager.currentTier == .pro ? "crown.fill" : purchaseManager.currentTier == .plus ? "star.fill" : "person.fill")
                    .foregroundColor(purchaseManager.currentTier == .pro ? .yellow : .accentColor)

                VStack(alignment: .leading) {
                    Text(purchaseManager.currentTier.rawValue.capitalized)
                        .font(.subheadline.weight(.medium))
                    Text(purchaseManager.currentTier == .free ? "3 products limit" : "Unlimited products")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                if purchaseManager.currentTier == .free {
                    Button("Upgrade") {
                        showPaywall = true
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.small)
                }
            }

            if purchaseManager.currentTier != .free {
                Button("Manage Subscription") {
                    if let url = URL(string: "https://apps.apple.com/account/subscriptions") {
                        UIApplication.shared.open(url)
                    }
                }
            }
        }
    }

    private var appearanceSection: some View {
        Section("Appearance") {
            Toggle("Dark Mode", isOn: $isDarkMode)
        }
    }

    private var notificationsSection: some View {
        Section("Notifications") {
            Button("Notification Settings") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
        }
    }

    private var dataSection: some View {
        Section("Data") {
            Button("Export Data (Pro)") {
                // Export functionality for Pro users
            }
            .disabled(purchaseManager.currentTier != .pro)

            Button("Reset Onboarding") {
                hasCompletedOnboarding = false
            }
            .foregroundColor(.red)
        }
    }

    private var aboutSection: some View {
        Section("About") {
            HStack {
                Text("Version")
                Spacer()
                Text(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0")
                    .foregroundColor(.secondary)
            }
            Link("Privacy Policy", destination: URL(string: "https://zzoutuo.github.io/SpoilAlert/privacy")!)
            Link("Terms of Use", destination: URL(string: "https://zzoutuo.github.io/SpoilAlert/terms")!)
            Link("Support", destination: URL(string: "mailto:support@zzoutuo.com")!)
        }
    }
}

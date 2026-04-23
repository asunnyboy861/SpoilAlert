import SwiftUI
import StoreKit

struct PaywallView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var purchaseManager: PurchaseManager
    @State private var selectedPlan: PlanTier = .plusYearly

    enum PlanTier {
        case plusMonthly
        case plusYearly
        case proMonthly
        case proYearly
        case lifetime
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    headerSection
                    featureComparison
                    planSelector
                    purchaseButton
                    legalSection
                }
                .padding()
                .frame(maxWidth: 720)
                .frame(maxWidth: .infinity)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Close") { dismiss() }
                }
            }
        }
    }

    private var headerSection: some View {
        VStack(spacing: 12) {
            Image(systemName: "shield.checkered")
                .font(.system(size: 56))
                .foregroundColor(.accentColor)

            Text("Unlock Full Protection")
                .font(.title.weight(.bold))

            Text("Never use expired skincare again. Track, scan, and protect your beauty routine.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.top, 20)
    }

    private var featureComparison: some View {
        VStack(spacing: 8) {
            FeatureRow(icon: "infinity", title: "Unlimited Products", free: "3", plus: "∞", pro: "∞")
            FeatureRow(icon: "camera", title: "PAO Scan & Barcode", free: "✗", plus: "✓", pro: "✓")
            FeatureRow(icon: "bell.badge", title: "Multi-level Reminders", free: "1x", plus: "4x", pro: "4x")
            FeatureRow(icon: "book", title: "Skin Journal", free: "✗", plus: "✓", pro: "✓")
            FeatureRow(icon: "icloud", title: "iCloud Sync", free: "✗", plus: "✗", pro: "✓")
            FeatureRow(icon: "person.2", title: "Family Sharing", free: "✗", plus: "✗", pro: "✓")
            FeatureRow(icon: "square.and.arrow.up", title: "Data Export", free: "✗", plus: "✗", pro: "✓")
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.05), radius: 10)
    }

    private var planSelector: some View {
        VStack(spacing: 12) {
            Text("Choose Your Plan")
                .font(.headline)

            PlanCard(
                title: "Plus",
                subtitle: "PAO scan, journal, unlimited",
                monthlyPrice: purchaseManager.plusMonthlyProduct?.displayPrice ?? "$2.99",
                yearlyPrice: purchaseManager.plusYearlyProduct?.displayPrice ?? "$19.99",
                isSelected: selectedPlan == .plusMonthly || selectedPlan == .plusYearly,
                isPopular: true,
                onSelectMonthly: { selectedPlan = .plusMonthly },
                onSelectYearly: { selectedPlan = .plusYearly }
            )

            PlanCard(
                title: "Pro",
                subtitle: "Everything + iCloud & Family",
                monthlyPrice: purchaseManager.proMonthlyProduct?.displayPrice ?? "$4.99",
                yearlyPrice: purchaseManager.proYearlyProduct?.displayPrice ?? "$34.99",
                isSelected: selectedPlan == .proMonthly || selectedPlan == .proYearly,
                isPopular: false,
                onSelectMonthly: { selectedPlan = .proMonthly },
                onSelectYearly: { selectedPlan = .proYearly }
            )

            LifetimeCard(
                price: purchaseManager.lifetimeProduct?.displayPrice ?? "$49.99",
                isSelected: selectedPlan == .lifetime,
                onSelect: { selectedPlan = .lifetime }
            )
        }
    }

    private var purchaseButton: some View {
        Button {
            Task {
                let product: Product? = {
                    switch selectedPlan {
                    case .plusMonthly: return purchaseManager.plusMonthlyProduct
                    case .plusYearly: return purchaseManager.plusYearlyProduct
                    case .proMonthly: return purchaseManager.proMonthlyProduct
                    case .proYearly: return purchaseManager.proYearlyProduct
                    case .lifetime: return purchaseManager.lifetimeProduct
                    }
                }()
                if let product {
                    let success = await purchaseManager.purchase(product)
                    if success { dismiss() }
                }
            }
        } label: {
            if purchaseManager.isLoading {
                ProgressView()
                    .tint(.white)
            } else {
                Text("Subscribe Now")
                    .fontWeight(.semibold)
            }
        }
        .buttonStyle(.borderedProminent)
        .controlSize(.large)
        .frame(maxWidth: .infinity)
    }

    private var legalSection: some View {
        VStack(spacing: 8) {
            Button("Restore Purchases") {
                Task { await purchaseManager.restorePurchases() }
            }
            .font(.caption)

            Text("Payment will be charged to your Apple ID account at confirmation of purchase. Subscription automatically renews unless it is canceled at least 24 hours before the end of the current period. Your account will be charged for renewal within 24 hours prior to the end of the current period. You can manage and cancel your subscriptions by going to your account settings on the App Store after purchase.")
                .font(.caption2)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)

            HStack(spacing: 16) {
                Link("Privacy Policy", destination: URL(string: "https://zzoutuo.github.io/SpoilAlert/privacy")!)
                Link("Terms of Use", destination: URL(string: "https://zzoutuo.github.io/SpoilAlert/terms")!)
            }
            .font(.caption)
        }
        .padding(.top, 8)
    }
}

struct FeatureRow: View {
    let icon: String
    let title: String
    let free: String
    let plus: String
    let pro: String

    var body: some View {
        HStack {
            Image(systemName: icon)
                .frame(width: 24)
                .foregroundColor(.accentColor)
            Text(title)
                .font(.caption)
            Spacer()
            Text(free)
                .font(.caption.weight(.medium))
                .frame(width: 40)
            Text(plus)
                .font(.caption.weight(.medium))
                .frame(width: 40)
                .foregroundColor(.green)
            Text(pro)
                .font(.caption.weight(.medium))
                .frame(width: 40)
                .foregroundColor(.purple)
        }
    }
}

struct PlanCard: View {
    let title: String
    let subtitle: String
    let monthlyPrice: String
    let yearlyPrice: String
    let isSelected: Bool
    let isPopular: Bool
    let onSelectMonthly: () -> Void
    let onSelectYearly: () -> Void

    var body: some View {
        VStack(spacing: 8) {
            HStack {
                VStack(alignment: .leading) {
                    HStack {
                        Text(title)
                            .font(.headline)
                        if isPopular {
                            Text("POPULAR")
                                .font(.caption2.weight(.bold))
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.accentColor)
                                .foregroundColor(.white)
                                .clipShape(Capsule())
                        }
                    }
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Spacer()
            }

            HStack(spacing: 12) {
                PlanOptionButton(
                    label: "\(monthlyPrice)/mo",
                    isSelected: false,
                    action: onSelectMonthly
                )
                PlanOptionButton(
                    label: "\(yearlyPrice)/yr",
                    subtitle: "Save 40%",
                    isSelected: true,
                    action: onSelectYearly
                )
            }
        }
        .padding()
        .background(isSelected ? Color.accentColor.opacity(0.08) : Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(isSelected ? Color.accentColor : Color.gray.opacity(0.3), lineWidth: isSelected ? 2 : 1)
        )
    }
}

struct PlanOptionButton: View {
    let label: String
    var subtitle: String? = nil
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 2) {
                Text(label)
                    .font(.subheadline.weight(.semibold))
                if let subtitle {
                    Text(subtitle)
                        .font(.caption2)
                        .foregroundColor(.green)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .background(isSelected ? Color.accentColor.opacity(0.15) : Color.gray.opacity(0.08))
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .buttonStyle(.plain)
    }
}

struct LifetimeCard: View {
    let price: String
    let isSelected: Bool
    let onSelect: () -> Void

    var body: some View {
        Button(action: onSelect) {
            HStack {
                VStack(alignment: .leading) {
                    HStack {
                        Image(systemName: "crown.fill")
                            .foregroundColor(.yellow)
                        Text("Lifetime")
                            .font(.headline)
                    }
                    Text("One-time purchase, forever access")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Spacer()
                Text(price)
                    .font(.title3.weight(.bold))
                    .foregroundColor(.accentColor)
            }
            .padding()
            .background(isSelected ? Color.accentColor.opacity(0.08) : Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? Color.accentColor : Color.gray.opacity(0.3), lineWidth: isSelected ? 2 : 1)
            )
        }
        .buttonStyle(.plain)
    }
}

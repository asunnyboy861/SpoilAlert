import SwiftUI
import SwiftData

struct DashboardView: View {
    @Query(filter: #Predicate<SkincareProduct> { $0.usageStatus == "active" },
           sort: \SkincareProduct.expirationDate)
    private var activeProducts: [SkincareProduct]

    @Environment(\.modelContext) private var modelContext

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    overviewCards
                    expiryRingChart
                    expiringSoonList
                    dailyCheckInPreview
                }
                .padding()
                .frame(maxWidth: 720)
                .frame(maxWidth: .infinity)
            }
            .navigationTitle("SpoilAlert")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink {
                        AddProductView()
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                    }
                }
            }
        }
    }

    private var expiringCount: Int {
        activeProducts.filter { $0.expiryStatus == "warning" || $0.expiryStatus == "critical" }.count
    }

    private var expiredCount: Int {
        activeProducts.filter { $0.expiryStatus == "expired" }.count
    }

    private var overviewCards: some View {
        HStack(spacing: 12) {
            StatCardView(title: "Active", count: activeProducts.count, color: .green)
            StatCardView(title: "Expiring", count: expiringCount, color: .orange)
            StatCardView(title: "Expired", count: expiredCount, color: .red)
        }
    }

    private var expiryRingChart: some View {
        VStack(spacing: 8) {
            Text("Product Status")
                .font(.headline)

            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.2), lineWidth: 20)

                Circle()
                    .trim(from: 0, to: safeRatio)
                    .stroke(Color.green, style: StrokeStyle(lineWidth: 20, lineCap: .round))
                    .rotationEffect(.degrees(-90))

                Circle()
                    .trim(from: safeRatio, to: safeRatio + warningRatio)
                    .stroke(Color.orange, style: StrokeStyle(lineWidth: 20, lineCap: .round))
                    .rotationEffect(.degrees(-90))

                Circle()
                    .trim(from: safeRatio + warningRatio, to: 1.0)
                    .stroke(Color.red, style: StrokeStyle(lineWidth: 20, lineCap: .round))
                    .rotationEffect(.degrees(-90))

                VStack {
                    Text("\(expiredCount)")
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundColor(.red)
                    Text("expired")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .frame(width: 180, height: 180)
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.05), radius: 10)
    }

    private var safeRatio: CGFloat {
        guard !activeProducts.isEmpty else { return 0 }
        return CGFloat(activeProducts.filter { $0.expiryStatus == "safe" }.count) / CGFloat(activeProducts.count)
    }

    private var warningRatio: CGFloat {
        guard !activeProducts.isEmpty else { return 0 }
        return CGFloat(activeProducts.filter { $0.expiryStatus == "warning" || $0.expiryStatus == "critical" }.count) / CGFloat(activeProducts.count)
    }

    private var expiringSoonList: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Expiring Soon")
                .font(.headline)

            let expiringProducts = activeProducts
                .filter { $0.daysRemaining <= 30 }
                .prefix(5)

            if expiringProducts.isEmpty {
                Text("All products are fresh!")
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding()
            } else {
                ForEach(expiringProducts) { product in
                    ProductRowView(product: product)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.05), radius: 10)
    }

    private var dailyCheckInPreview: some View {
        VStack(spacing: 12) {
            Text("Today's Check-in")
                .font(.headline)

            let todayUsed = activeProducts.filter {
                Calendar.current.isDateInToday($0.lastUsedDate ?? .distantPast)
            }

            Text("\(todayUsed.count) / \(activeProducts.count) products used today")
                .font(.subheadline)
                .foregroundColor(.secondary)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                ForEach(activeProducts.prefix(8)) { product in
                    CheckInButton(product: product)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.05), radius: 10)
    }
}

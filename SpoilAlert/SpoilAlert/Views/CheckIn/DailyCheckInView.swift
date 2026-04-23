import SwiftUI
import SwiftData

struct DailyCheckInView: View {
    @Query(filter: #Predicate<SkincareProduct> { $0.usageStatus == "active" })
    private var activeProducts: [SkincareProduct]
    @Environment(\.modelContext) private var modelContext

    private var todayCheckedIn: [SkincareProduct] {
        activeProducts.filter {
            Calendar.current.isDateInToday($0.lastUsedDate ?? .distantPast)
        }
    }

    private var checkInPercentage: Double {
        guard !activeProducts.isEmpty else { return 0 }
        return Double(todayCheckedIn.count) / Double(activeProducts.count)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    progressSection
                    productCheckInList
                }
                .padding()
                .frame(maxWidth: 720)
                .frame(maxWidth: .infinity)
            }
            .navigationTitle("Daily Check-in")
        }
    }

    private var progressSection: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.2), lineWidth: 12)
                Circle()
                    .trim(from: 0, to: checkInPercentage)
                    .stroke(Color.accentColor, style: StrokeStyle(lineWidth: 12, lineCap: .round))
                    .rotationEffect(.degrees(-90))

                VStack {
                    Text("\(Int(checkInPercentage * 100))%")
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                    Text("\(todayCheckedIn.count)/\(activeProducts.count)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .frame(width: 150, height: 150)

            Text(checkInPercentage >= 1.0 ? "All done for today!" : "Keep going!")
                .font(.headline)
                .foregroundColor(checkInPercentage >= 1.0 ? .green : .secondary)
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.05), radius: 10)
    }

    private var productCheckInList: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Products")
                .font(.headline)

            ForEach(activeProducts) { product in
                CheckInButton(product: product)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.05), radius: 10)
    }
}

struct CheckInButton: View {
    let product: SkincareProduct
    @Environment(\.modelContext) private var modelContext

    private var isCheckedToday: Bool {
        Calendar.current.isDateInToday(product.lastUsedDate ?? .distantPast)
    }

    var body: some View {
        Button {
            product.lastUsedDate = Date()
            product.dailyUsageCount += 1
            product.updatedAt = Date()
            try? modelContext.save()
        } label: {
            HStack {
                Image(systemName: ProductCategory(rawValue: product.category)?.iconName ?? "circle.fill")
                    .foregroundColor(isCheckedToday ? .green : .secondary)

                VStack(alignment: .leading, spacing: 2) {
                    Text(product.name)
                        .font(.subheadline.weight(.medium))
                        .foregroundColor(.primary)
                    Text(product.brand)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                Image(systemName: isCheckedToday ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(isCheckedToday ? .green : .gray)
                    .font(.title3)
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .background(isCheckedToday ? Color.green.opacity(0.05) : Color.clear)
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
        .buttonStyle(.plain)
    }
}

import SwiftUI

struct ProductRowView: View {
    let product: SkincareProduct

    private var statusColor: Color {
        ExpiryStatus.from(daysRemaining: product.daysRemaining).color
    }

    var body: some View {
        HStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 4)
                .fill(statusColor)
                .frame(width: 4, height: 40)

            Image(systemName: ProductCategory(rawValue: product.category)?.iconName ?? "circle.fill")
                .foregroundColor(statusColor)
                .font(.title3)

            VStack(alignment: .leading, spacing: 2) {
                Text(product.name)
                    .font(.subheadline.weight(.medium))
                Text(product.brand)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            VStack(alignment: .trailing) {
                Text(product.daysRemaining >= 0 ? "\(product.daysRemaining)d" : "Expired")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(statusColor)
                Text(product.daysRemaining >= 0 ? "remaining" : "")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 8)
    }
}

import SwiftUI
import SwiftData

struct ProductListView: View {
    @Query(sort: \SkincareProduct.expirationDate) private var products: [SkincareProduct]
    @Environment(\.modelContext) private var modelContext
    @State private var searchText = ""
    @State private var filterCategory: String?
    @State private var filterStatus: String?

    private var filteredProducts: [SkincareProduct] {
        products.filter { product in
            let matchesSearch = searchText.isEmpty ||
                product.name.localizedCaseInsensitiveContains(searchText) ||
                product.brand.localizedCaseInsensitiveContains(searchText)
            let matchesCategory = filterCategory == nil || product.category == filterCategory
            let matchesStatus = filterStatus == nil || product.expiryStatus == filterStatus
            return matchesSearch && matchesCategory && matchesStatus
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    filterChips

                    if filteredProducts.isEmpty {
                        ContentUnavailableView(
                            "No Products",
                            systemImage: "bottle",
                            description: Text("Tap + to add your first skincare product")
                        )
                    } else {
                        ForEach(filteredProducts) { product in
                            NavigationLink {
                                ProductDetailView(product: product)
                            } label: {
                                ProductRowView(product: product)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .padding()
                .frame(maxWidth: 720)
                .frame(maxWidth: .infinity)
            }
            .navigationTitle("Products")
            .searchable(text: $searchText, prompt: "Search products...")
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

    private var filterChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                FilterChip(label: "All", isSelected: filterStatus == nil) {
                    filterStatus = nil
                }
                FilterChip(label: "Safe", isSelected: filterStatus == "safe", color: .green) {
                    filterStatus = "safe"
                }
                FilterChip(label: "Warning", isSelected: filterStatus == "warning", color: .orange) {
                    filterStatus = "warning"
                }
                FilterChip(label: "Critical", isSelected: filterStatus == "critical", color: Color(red: 1.0, green: 0.44, blue: 0.26)) {
                    filterStatus = "critical"
                }
                FilterChip(label: "Expired", isSelected: filterStatus == "expired", color: .red) {
                    filterStatus = "expired"
                }
            }
        }
    }
}

struct FilterChip: View {
    let label: String
    let isSelected: Bool
    var color: Color = .accentColor
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(label)
                .font(.caption)
                .fontWeight(.medium)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(isSelected ? color.opacity(0.2) : Color.gray.opacity(0.1))
                .foregroundColor(isSelected ? color : .secondary)
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}

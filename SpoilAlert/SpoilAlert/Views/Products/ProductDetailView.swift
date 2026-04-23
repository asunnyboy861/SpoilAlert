import SwiftUI
import SwiftData

struct ProductDetailView: View {
    @Bindable var product: SkincareProduct
    @Environment(\.modelContext) private var modelContext
    @State private var showDeleteConfirmation = false
    @State private var showEditSheet = false

    private var statusColor: Color {
        ExpiryStatus.from(daysRemaining: product.daysRemaining).color
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                statusHeader
                detailCards
                actionButtons
            }
            .padding()
            .frame(maxWidth: 720)
            .frame(maxWidth: .infinity)
        }
        .navigationTitle(product.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button {
                        showEditSheet = true
                    } label: {
                        Label("Edit", systemImage: "pencil")
                    }
                    Button(role: .destructive) {
                        showDeleteConfirmation = true
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .sheet(isPresented: $showEditSheet) {
            EditProductView(product: product)
        }
        .alert("Delete Product?", isPresented: $showDeleteConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                modelContext.delete(product)
                try? modelContext.save()
            }
        }
    }

    private var statusHeader: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .stroke(statusColor.opacity(0.2), lineWidth: 8)
                Circle()
                    .trim(from: 0, to: progressRatio)
                    .stroke(statusColor, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                    .rotationEffect(.degrees(-90))

                VStack {
                    Text(product.daysRemaining >= 0 ? "\(product.daysRemaining)" : "0")
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                        .foregroundColor(statusColor)
                    Text(product.daysRemaining >= 0 ? "days left" : "EXPIRED")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .frame(width: 160, height: 160)

            Text(product.name)
                .font(.title2.weight(.semibold))
            Text(product.brand)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.05), radius: 10)
    }

    private var progressRatio: CGFloat {
        guard product.paoMonths > 0 else { return 0 }
        let totalDays = product.paoMonths * 30
        let remaining = max(0, product.daysRemaining)
        return CGFloat(remaining) / CGFloat(totalDays)
    }

    private var detailCards: some View {
        VStack(spacing: 12) {
            DetailRow(icon: "calendar", title: "Opened", value: product.openDate.formatted(date: .abbreviated, time: .omitted))
            DetailRow(icon: "hourglass", title: "Expires", value: product.expirationDate.formatted(date: .abbreviated, time: .omitted))
            DetailRow(icon: "clock", title: "PAO Period", value: "\(product.paoMonths)M")
            DetailRow(icon: "tag", title: "Category", value: product.category)
            DetailRow(icon: "checkmark.circle", title: "Times Used", value: "\(product.dailyUsageCount)")
            if let notes = product.notes, !notes.isEmpty {
                DetailRow(icon: "note.text", title: "Notes", value: notes)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.05), radius: 10)
    }

    private var actionButtons: some View {
        HStack(spacing: 12) {
            Button {
                product.usageStatus = "finished"
                product.updatedAt = Date()
                try? modelContext.save()
            } label: {
                Label("Finished", systemImage: "checkmark.circle")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)

            Button {
                product.usageStatus = "discarded"
                product.updatedAt = Date()
                try? modelContext.save()
            } label: {
                Label("Discarded", systemImage: "trash.circle")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
        }
    }
}

struct DetailRow: View {
    let icon: String
    let title: String
    let value: String

    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.accentColor)
                .frame(width: 24)
            Text(title)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .fontWeight(.medium)
        }
        .font(.subheadline)
        .padding(.vertical, 4)
    }
}

struct EditProductView: View {
    @Bindable var product: SkincareProduct
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                TextField("Product Name", text: $product.name)
                TextField("Brand", text: $product.brand)
                Picker("Category", selection: $product.category) {
                    ForEach(ProductCategory.allCases, id: \.self) { cat in
                        Text(cat.rawValue).tag(cat.rawValue)
                    }
                }
                DatePicker("Opening Date", selection: $product.openDate, displayedComponents: .date)
                Picker("PAO Period", selection: $product.paoMonths) {
                    ForEach([3, 6, 12, 24], id: \.self) { months in
                        Text("\(months)M").tag(months)
                    }
                }
                TextField("Notes", text: Binding(
                    get: { product.notes ?? "" },
                    set: { product.notes = $0.isEmpty ? nil : $0 }
                ))
            }
            .navigationTitle("Edit Product")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        product.expirationDate = Calendar.current.date(byAdding: .month, value: product.paoMonths, to: product.openDate) ?? product.openDate
                        product.updatedAt = Date()
                        try? modelContext.save()
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
}

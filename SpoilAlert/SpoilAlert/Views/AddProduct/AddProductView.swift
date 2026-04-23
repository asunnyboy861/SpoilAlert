import SwiftUI
import SwiftData
import PhotosUI

struct AddProductView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var purchaseManager: PurchaseManager

    @State private var name = ""
    @State private var brand = ""
    @State private var category = ProductCategory.moisturizer
    @State private var openDate = Date()
    @State private var paoMonths = 12
    @State private var notes = ""
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var productImage: UIImage?
    @State private var showCamera = false
    @State private var cameraImage: UIImage?
    @State private var isScanningPAO = false
    @State private var paoResult: String?
    @State private var showPaywall = false

    @Query(filter: #Predicate<SkincareProduct> { $0.usageStatus == "active" })
    private var activeProducts: [SkincareProduct]

    var body: some View {
        NavigationStack {
            Form {
                basicInfoSection
                dateSection
                photoSection
                notesSection
            }
            .navigationTitle("Add Product")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") { saveProduct() }
                        .fontWeight(.semibold)
                        .disabled(name.isEmpty || brand.isEmpty)
                }
            }
            .sheet(isPresented: $showCamera) {
                CameraView(image: $cameraImage)
            }
            .sheet(isPresented: $showPaywall) {
                PaywallView()
            }
            .alert("PAO Detected", isPresented: .init(
                get: { paoResult != nil },
                set: { if !$0 { paoResult = nil } }
            )) {
                Button("Use \(paoResult ?? "")") {
                    if let months = Int(paoResult?.replacingOccurrences(of: "M", with: "") ?? "") {
                        paoMonths = months
                    }
                }
                Button("Cancel", role: .cancel) { paoResult = nil }
            } message: {
                Text("Found PAO period: \(paoResult ?? "")")
            }
        }
    }

    private var basicInfoSection: some View {
        Section("Product Info") {
            TextField("Product Name", text: $name)
            TextField("Brand", text: $brand)
            Picker("Category", selection: $category) {
                ForEach(ProductCategory.allCases, id: \.self) { cat in
                    Label(cat.rawValue, systemImage: cat.iconName).tag(cat)
                }
            }
            .onChange(of: category) { _, newValue in
                paoMonths = newValue.defaultPAO
            }
        }
    }

    private var dateSection: some View {
        Section("Expiry") {
            DatePicker("Opening Date", selection: $openDate, displayedComponents: .date)
            Picker("PAO Period", selection: $paoMonths) {
                ForEach([3, 6, 12, 24], id: \.self) { months in
                    Text("\(months)M").tag(months)
                }
            }
            HStack {
                Text("Expires")
                Spacer()
                Text(expiryDate.formatted(date: .abbreviated, time: .omitted))
                    .foregroundColor(.secondary)
            }
        }
    }

    private var expiryDate: Date {
        Calendar.current.date(byAdding: .month, value: paoMonths, to: openDate) ?? openDate
    }

    private var photoSection: some View {
        Section("Photo") {
            HStack {
                PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                    Label("Choose Photo", systemImage: "photo.on.rectangle")
                }
                .onChange(of: selectedPhotoItem) { _, newItem in
                    Task {
                        if let data = try? await newItem?.loadTransferable(type: Data.self),
                           let image = UIImage(data: data) {
                            productImage = image
                            await scanForPAO(image: image)
                        }
                    }
                }

                Button {
                    if purchaseManager.currentTier == .free {
                        showPaywall = true
                    } else {
                        showCamera = true
                    }
                } label: {
                    Label("Scan PAO", systemImage: "camera")
                }
            }

            if let image = productImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 150)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
    }

    private var notesSection: some View {
        Section("Notes") {
            TextField("Optional notes...", text: $notes, axis: .vertical)
                .lineLimit(3...6)
        }
    }

    private func scanForPAO(image: UIImage) async {
        guard purchaseManager.currentTier != .free else { return }
        isScanningPAO = true
        defer { isScanningPAO = false }

        do {
            if let result = try await PAORecognitionService.recognizePAO(from: image) {
                paoResult = "\(result.paoMonths)M"
            }
        } catch {
            // Silently fail - user can manually set PAO
        }
    }

    private func saveProduct() {
        let product = SkincareProduct(
            name: name,
            brand: brand,
            category: category.rawValue,
            openDate: openDate,
            paoMonths: paoMonths
        )
        product.notes = notes.isEmpty ? nil : notes
        product.imageData = productImage?.jpegData(compressionQuality: 0.7)

        modelContext.insert(product)
        try? modelContext.save()

        Task {
            await NotificationService.shared.scheduleExpiryReminders(for: product)
        }

        dismiss()
    }
}

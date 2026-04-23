import SwiftUI
import SwiftData

struct SkinJournalView: View {
    @Query(sort: \SkinLog.date, order: .reverse) private var logs: [SkinLog]
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var purchaseManager: PurchaseManager
    @State private var showAddLog = false
    @State private var showPaywall = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    if purchaseManager.currentTier == .free {
                        lockedView
                    } else {
                        if logs.isEmpty {
                            ContentUnavailableView(
                                "No Journal Entries",
                                systemImage: "book",
                                description: Text("Track your skin condition daily")
                            )
                        } else {
                            skinTrendChart
                            logList
                        }
                    }
                }
                .padding()
                .frame(maxWidth: 720)
                .frame(maxWidth: .infinity)
            }
            .navigationTitle("Skin Journal")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        if purchaseManager.currentTier == .free {
                            showPaywall = true
                        } else {
                            showAddLog = true
                        }
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                    }
                }
            }
            .sheet(isPresented: $showAddLog) {
                AddSkinLogView()
            }
            .sheet(isPresented: $showPaywall) {
                PaywallView()
            }
        }
    }

    private var lockedView: some View {
        VStack(spacing: 16) {
            Image(systemName: "lock.fill")
                .font(.system(size: 48))
                .foregroundColor(.secondary)
            Text("Skin Journal")
                .font(.title2.weight(.semibold))
            Text("Upgrade to Plus to track your skin condition and build a personal skincare journal.")
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)

            Button {
                showPaywall = true
            } label: {
                Text("Upgrade to Plus")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
        }
        .padding(32)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.05), radius: 10)
    }

    private var skinTrendChart: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Skin Trend (Last 7 Days)")
                .font(.headline)

            let recentLogs = Array(logs.prefix(7).reversed())
            HStack(alignment: .bottom, spacing: 8) {
                ForEach(recentLogs) { log in
                    VStack {
                        Text(conditionEmoji(log.condition))
                            .font(.title2)
                        RoundedRectangle(cornerRadius: 4)
                            .fill(conditionColor(log.condition))
                            .frame(height: CGFloat(log.condition) * 20)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .frame(height: 120)
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.05), radius: 10)
    }

    private var logList: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recent Entries")
                .font(.headline)

            ForEach(logs.prefix(20)) { log in
                HStack {
                    Text(conditionEmoji(log.condition))
                        .font(.title2)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(log.date.formatted(date: .abbreviated, time: .shortened))
                            .font(.subheadline.weight(.medium))
                        Text(log.notes)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                }
                .padding(.vertical, 4)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.05), radius: 10)
    }

    private func conditionEmoji(_ condition: Int) -> String {
        switch condition {
        case 1: return "😞"
        case 2: return "😕"
        case 3: return "😐"
        case 4: return "🙂"
        case 5: return "😊"
        default: return "😐"
        }
    }

    private func conditionColor(_ condition: Int) -> Color {
        switch condition {
        case 1: return .red
        case 2: return .orange
        case 3: return .yellow
        case 4: return .green
        case 5: return Color(red: 0.2, green: 0.8, blue: 0.4)
        default: return .gray
        }
    }
}

struct AddSkinLogView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var condition = 3
    @State private var notes = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("How's your skin today?") {
                    Picker("Condition", selection: $condition) {
                        Text("😞 Bad").tag(1)
                        Text("😕 So-so").tag(2)
                        Text("😐 Neutral").tag(3)
                        Text("🙂 Good").tag(4)
                        Text("😊 Great").tag(5)
                    }
                    .pickerStyle(.segmented)
                }

                Section("Notes") {
                    TextField("What products did you use? Any reactions?", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                }
            }
            .navigationTitle("New Entry")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        let log = SkinLog(condition: condition, notes: notes)
                        modelContext.insert(log)
                        try? modelContext.save()
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
}

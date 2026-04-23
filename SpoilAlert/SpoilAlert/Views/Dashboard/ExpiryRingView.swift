import SwiftUI

struct ExpiryRingView: View {
    let safeCount: Int
    let warningCount: Int
    let expiredCount: Int
    let totalCount: Int

    private var safeRatio: CGFloat {
        guard totalCount > 0 else { return 0 }
        return CGFloat(safeCount) / CGFloat(totalCount)
    }

    private var warningRatio: CGFloat {
        guard totalCount > 0 else { return 0 }
        return CGFloat(warningCount) / CGFloat(totalCount)
    }

    var body: some View {
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
}

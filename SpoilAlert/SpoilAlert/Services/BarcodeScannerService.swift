@preconcurrency import Vision
import UIKit

final class BarcodeScannerService {

    static func detectBarcode(in image: UIImage) async throws -> String? {
        guard let cgImage = image.cgImage else { return nil }

        return try await withCheckedThrowingContinuation { continuation in
            let request = VNDetectBarcodesRequest { request, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                guard let observation = request.results?.first as? VNBarcodeObservation,
                      let payload = observation.payloadStringValue else {
                    continuation.resume(returning: nil)
                    return
                }
                continuation.resume(returning: payload)
            }
            request.symbologies = [.ean13, .ean8, .upce, .qr, .code128]
            let handler = VNImageRequestHandler(cgImage: cgImage)
            try? handler.perform([request])
        }
    }
}

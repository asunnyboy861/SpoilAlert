@preconcurrency import Vision
import UIKit

struct PAOResult {
    let paoMonths: Int
    let confidence: Float
    let recognizedText: String
}

enum PAOError: LocalizedError {
    case invalidImage
    case noPAOFound

    var errorDescription: String? {
        switch self {
        case .invalidImage: return "Invalid image provided"
        case .noPAOFound: return "No PAO information found in image. Try taking a closer photo of the jar symbol."
        }
    }
}

final class PAORecognitionService {

    static func recognizePAO(from image: UIImage) async throws -> PAOResult? {
        guard let cgImage = image.cgImage else {
            throw PAOError.invalidImage
        }
        let textObservations = try await performOCR(on: cgImage)
        return extractPAO(from: textObservations)
    }

    private static func performOCR(on cgImage: CGImage) async throws -> [VNRecognizedTextObservation] {
        try await withCheckedThrowingContinuation { continuation in
            let request = VNRecognizeTextRequest { request, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                let observations = request.results as? [VNRecognizedTextObservation] ?? []
                continuation.resume(returning: observations)
            }
            request.recognitionLevel = .accurate
            request.recognitionLanguages = ["en-US"]
            request.usesLanguageCorrection = true
            request.minimumTextHeight = 0.01

            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            DispatchQueue.global(qos: .userInitiated).async {
                do {
                    try handler.perform([request])
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    private static func extractPAO(from observations: [VNRecognizedTextObservation]) -> PAOResult? {
        let patterns: [NSRegularExpression] = [
            (try? NSRegularExpression(pattern: "(\\d{1,2})\\s*[Mm]\\b")),
            (try? NSRegularExpression(pattern: "PAO\\s*(\\d{1,2})\\s*[Mm]")),
            (try? NSRegularExpression(pattern: "(\\d{1,2})\\s*month"))
        ].compactMap { $0 }

        var bestResult: PAOResult?
        var bestConfidence: Float = 0

        for observation in observations {
            guard let candidate = observation.topCandidates(1).first else { continue }
            let text = candidate.string
            let confidence = candidate.confidence

            for pattern in patterns {
                let range = NSRange(text.startIndex..., in: text)
                if let match = pattern.firstMatch(in: text, range: range),
                   let monthRange = Range(match.range(at: 1), in: text),
                   let months = Int(text[monthRange]),
                   months > 0 && months <= 36 {
                    if confidence > bestConfidence {
                        bestConfidence = confidence
                        bestResult = PAOResult(paoMonths: months, confidence: confidence, recognizedText: text)
                    }
                }
            }
        }
        return bestResult
    }
}

import UIKit
import CoreML
import Vision

class ImageClassifier: ObservableObject {
    @Published var result: ClassificationResult?
    @Published var isProcessing = false

    enum ClassificationResult {
        case hotdog(confidence: Float)
        case notHotdog(topLabel: String, confidence: Float)
    }

    private lazy var classificationRequest: VNCoreMLRequest? = {
        guard let model = try? VNCoreMLModel(for: MobileNetV2(configuration: .init()).model) else {
            print("Failed to load MobileNetV2 model")
            return nil
        }
        let request = VNCoreMLRequest(model: model) { [weak self] request, error in
            self?.processClassifications(for: request, error: error)
        }
        request.imageCropAndScaleOption = .centerCrop
        return request
    }()

    func classify(image: UIImage) {
        guard let ciImage = CIImage(image: image) else {
            print("Could not create CIImage")
            return
        }

        DispatchQueue.main.async {
            self.isProcessing = true
            self.result = nil
        }

        let handler = VNImageRequestHandler(ciImage: ciImage, options: [:])

        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let request = self?.classificationRequest else { return }
            do {
                try handler.perform([request])
            } catch {
                print("Classification failed: \(error)")
                DispatchQueue.main.async {
                    self?.isProcessing = false
                }
            }
        }
    }

    private func processClassifications(for request: VNRequest, error: Error?) {
        guard let classifications = request.results as? [VNClassificationObservation],
              let topResult = classifications.first else {
            DispatchQueue.main.async {
                self.isProcessing = false
            }
            return
        }

        // MobileNetV2 trained on ImageNet returns identifiers as comma-separated
        // synonyms. Class 934 is: "hotdog, hot dog, red hot"
        let hotdogObservation = classifications.prefix(5).first { observation in
            let id = observation.identifier.lowercased()
            return id.contains("hotdog") || id.contains("hot dog") || id.contains("red hot")
        }

        DispatchQueue.main.async {
            self.isProcessing = false
            if let hotdogObs = hotdogObservation {
                self.result = .hotdog(confidence: hotdogObs.confidence)
            } else {
                let topLabel = topResult.identifier.components(separatedBy: ", ").first
                    ?? topResult.identifier
                self.result = .notHotdog(topLabel: topLabel, confidence: topResult.confidence)
            }
        }
    }
}

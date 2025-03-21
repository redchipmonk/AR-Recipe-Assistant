//
//  VisionProcessor.swift
//  AR-Recipe-Assistant
//
//  Created by Paul Han on 3/13/25.
//

import Vision
import ARKit

struct TrackedObject {
    let label: String
    let center: CGPoint
}


class VisionProcessor {
    
    static var shared: VisionProcessor!
    
    
    // The following contains the COCO classes that are related to food and/or kitchen items
    private var filteredItems: Set<String> = ["fork", "knife", "bowl", "banana", "apple", "orange", "sink"]
    
    private var request: VNCoreMLRequest?
    private var isProcessingFrame = false
    
    private var currPredictions: [VNRecognizedObjectObservation]!
    private var currPredictionsWithObjects: [VNRecognizedObjectObservation] = []
    
    private var confidenceThreshold = 0.5
    
    // Is this best way???
    private weak var uiManager: UIManager?

    private init(uiManager: UIManager) {
        self.uiManager = uiManager
        setupVisionModel()
    }
    
    static func initialize(uiManager: UIManager) {
        guard shared == nil else {
            fatalError("Singleton VisionProcessor is already initialized")
        }
        shared = VisionProcessor(uiManager: uiManager)
    }
    
    private func setupVisionModel() {
        guard let model = try? yolov8x().model else {
            fatalError("Failed to load the model")
        }
        let visionModel = try? VNCoreMLModel(for: model)
        request = VNCoreMLRequest(model: visionModel!, completionHandler: visionRequestDidComplete)
        request?.imageCropAndScaleOption = .scaleFill
    }

    func processFrame(frame: ARFrame) {
        guard !isProcessingFrame, let request = request else { return }
        isProcessingFrame = true

        DispatchQueue.global(qos: .userInitiated).async {
            let handler = VNImageRequestHandler(cvPixelBuffer: frame.capturedImage)
            try? handler.perform([request])

            DispatchQueue.main.async {
                self.isProcessingFrame = false
            }
        }
    }
    
    private func filterPredictions(predictions: [VNRecognizedObjectObservation]) -> [VNRecognizedObjectObservation]{
        
        var filteredPredictions:[VNRecognizedObjectObservation] = []
        for prediction in predictions {
            let label: String = prediction.label ?? "N/A"
            if self.filteredItems.contains(label) {
                filteredPredictions.append(prediction)
            }
        }
        return filteredPredictions
    }

    private func visionRequestDidComplete(request: VNRequest, error: Error?) {
        guard let predictions = request.results as? [VNRecognizedObjectObservation] else { return }
        
        self.currPredictions = filterPredictions(predictions: predictions)
        
        if self.currPredictions.count > 0 {
            self.currPredictionsWithObjects = self.currPredictions
        }
        
        self.uiManager!.setBoundingBoxPredictions(predictions: self.currPredictions)
        
    }
    
    func getPredictions() -> [VNRecognizedObjectObservation] {
        if self.currPredictions == nil {
            return []
        }
        
        return self.currPredictions
    }
    
    func getCurrentWorldStateString() -> String {
        let predictions = self.currPredictionsWithObjects
        var lines: [String] = []

        for prediction in predictions {
            guard let label = prediction.label else { continue }

            let bbox = prediction.boundingBox
            let centerX = ((bbox.minX + bbox.maxX) / 2.0) * 100
            let centerY = ((bbox.minY + bbox.maxY) / 2.0) * 100

            let formatted = String(format: "- %@ at (%.2f, %.2f)", label, centerX, centerY)
            lines.append(formatted)
        }

        return lines.joined(separator: "\n")
    }
}



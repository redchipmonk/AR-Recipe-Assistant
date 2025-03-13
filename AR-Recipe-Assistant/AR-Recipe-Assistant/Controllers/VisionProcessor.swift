//
//  VisionProcessor.swift
//  AR-Recipe-Assistant
//
//  Created by Paul Han on 3/13/25.
//

import Vision
import ARKit

class VisionProcessor {
    
    static var shared: VisionProcessor!
    
    
    // The following contains the COCO classes that are related to food and/or kitchen items
//    private var filteredItems: Set<String> = ["wine glass", "cup", "fork", "knife", "spoon", "bowl", "banana", "apple", "sandwich", "orange", "broccoli", "carrot", "hot dog", "pizza", "donut", "cake"]
    
    
    private var filteredItems: Set<String> = ["tv"]
    
    private var request: VNCoreMLRequest?
    private var isProcessingFrame = false
    
    private var currPredictions: [VNRecognizedObjectObservation]!
    
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
        guard let model = try? yolov8n().model else {
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
        self.uiManager!.setBoundingBoxPredictions(predictions: self.currPredictions)
    }
    
    func getPredictions() -> [VNRecognizedObjectObservation] {
        if self.currPredictions == nil {
            return []
        }
        
        return self.currPredictions
    }
}

//
//  ARSessionHandler.swift
//  AR-Recipe-Assistant
//
//  Created by Paul Han on 3/13/25.
//

import ARKit

class ARSessionHandler: NSObject, ARSessionDelegate, ARSCNViewDelegate {
    
    private var sceneView: ARSCNView
    
    private var currentFrame: ARFrame!
    
    init(sceneView: ARSCNView) {
        self.sceneView = sceneView
        super.init()
        setupARView()
    }

    private func setupARView() {
        sceneView.delegate = self
        sceneView.session.delegate = self
    }

    func startSession() {
        let configuration = ARWorldTrackingConfiguration()
        sceneView.session.run(configuration)
    }

    func pauseSession() {
        sceneView.session.pause()
    }

    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        VisionProcessor.shared.processFrame(frame: frame)
        self.currentFrame = frame
    }
    
    func getCurrentFrame() -> ARFrame {
        return currentFrame
    }
    
}

extension ARFrame {
    func toBase64() -> String? {
        let pixelBuffer = self.capturedImage
        let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
        
        let context = CIContext()
        guard let cgImage = context.createCGImage(ciImage, from: ciImage.extent) else { return nil }
        let uiImage = UIImage(cgImage: cgImage, scale: 1.0, orientation: .right)
        
        guard let imageData = uiImage.jpegData(compressionQuality: 0.7) else { return nil }
        return imageData.base64EncodedString()
    }
}

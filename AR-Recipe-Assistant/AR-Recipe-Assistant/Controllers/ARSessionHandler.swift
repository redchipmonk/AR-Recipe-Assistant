//
//  ARSessionHandler.swift
//  AR-Recipe-Assistant
//
//  Created by Paul Han on 3/13/25.
//

import ARKit

class ARSessionHandler: NSObject, ARSessionDelegate, ARSCNViewDelegate {
    
    private var sceneView: ARSCNView

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
    }
}

//
//  ViewController.swift
//  AR-Recipe-Assistant
//
//  Created by Paul Han on 3/10/25.
//

import UIKit
import ARKit
import CoreML
import Vision
import CoreMedia

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    var uiManager: UIManager!
    var arSessionHandler: ARSessionHandler!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        uiManager = UIManager(viewController: self)
        VisionProcessor.initialize(uiManager: uiManager)
        
        arSessionHandler = ARSessionHandler(sceneView: sceneView)

        uiManager.setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        arSessionHandler.startSession()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        arSessionHandler.pauseSession()
    }
}


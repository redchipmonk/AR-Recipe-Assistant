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
    var recipeManager: ReciperManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        arSessionHandler = ARSessionHandler(sceneView: sceneView)
        
        
        uiManager = UIManager(viewController: self)
        recipeManager = ReciperManager(uiManager: uiManager, arSessionHandler: arSessionHandler)
        VisionProcessor.initialize(uiManager: uiManager)
        
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


//
//  UIManager.swift
//  AR-Recipe-Assistant
//
//  Created by Paul Han on 3/13/25.
//

import UIKit
import ARKit
class UIManager {
    
    private weak var viewController: ViewController!
    private weak var view: UIView!
    private weak var sceneView: ARSCNView!
    private var boxesView: DrawingBoundingBoxView!
    
    var recipeOverlay: UIView!
    var recipeLabel: UILabel!
    var nextStepButton: UIButton!
    var generateRecipeButton: UIButton!
    
    var steps: [String] = [
        "Step 1: Gather ingredients",
        "Step 2: Preheat oven",
        "Step 3: Mix ingredients",
        "Step 4: Bake",
        "Step 5: Serve"
    ]
    var currentStepIndex = 0
    

    init(viewController: ViewController) {
        self.viewController = viewController
        self.view = viewController.view
        self.sceneView = viewController.sceneView
    }

    func setupUI() {
        setupBoundingBoxLayer()
        setupRecipeOverlay()
        setupGenerateRecipeButton()
        setupConstraints()
    }

    func setupRecipeOverlay() {
        recipeOverlay = UIView()
        recipeOverlay.backgroundColor = UIColor.white.withAlphaComponent(0.8)
        recipeOverlay.layer.cornerRadius = 10
        recipeOverlay.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(recipeOverlay)
        
        recipeLabel = UILabel()
        recipeLabel.numberOfLines = 0
        recipeLabel.text = "Recipe: 5-step Guide\nTap Next!"
        recipeLabel.translatesAutoresizingMaskIntoConstraints = false
        recipeOverlay.addSubview(recipeLabel)
        
        nextStepButton = UIButton()
        nextStepButton.setTitle("Next", for: .normal)
        nextStepButton.backgroundColor = .systemBlue
        nextStepButton.setTitleColor(.white, for: .normal)
        nextStepButton.layer.cornerRadius = 5
        nextStepButton.translatesAutoresizingMaskIntoConstraints = false
        nextStepButton.addTarget(self, action: #selector(nextStep), for: .touchUpInside)
        recipeOverlay.addSubview(nextStepButton)
    }

    func setupGenerateRecipeButton() {
        generateRecipeButton = UIButton()
        generateRecipeButton.setTitle("Generate Recipe", for: .normal)
        generateRecipeButton.backgroundColor = .systemGreen
        generateRecipeButton.setTitleColor(.white, for: .normal)
        generateRecipeButton.layer.cornerRadius = 5
        generateRecipeButton.translatesAutoresizingMaskIntoConstraints = false
        generateRecipeButton.addTarget(self, action: #selector(generateRecipe), for: .touchUpInside)
        view.addSubview(generateRecipeButton)
    }

    func setupConstraints() {
        NSLayoutConstraint.activate([
            // AR View fills the whole screen
            sceneView.topAnchor.constraint(equalTo: view.topAnchor),
            sceneView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            sceneView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            sceneView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            // Recipe Overlay on the right (30% width)
            recipeOverlay.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.3),
            recipeOverlay.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.5),
            recipeOverlay.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            recipeOverlay.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            // Recipe Label inside overlay
            recipeLabel.topAnchor.constraint(equalTo: recipeOverlay.topAnchor, constant: 10),
            recipeLabel.leadingAnchor.constraint(equalTo: recipeOverlay.leadingAnchor, constant: 10),
            recipeLabel.trailingAnchor.constraint(equalTo: recipeOverlay.trailingAnchor, constant: -10),

            // Next Step Button at the bottom of overlay
            nextStepButton.bottomAnchor.constraint(equalTo: recipeOverlay.bottomAnchor, constant: -10),
            nextStepButton.leadingAnchor.constraint(equalTo: recipeOverlay.leadingAnchor, constant: 10),
            nextStepButton.trailingAnchor.constraint(equalTo: recipeOverlay.trailingAnchor, constant: -10),
            nextStepButton.heightAnchor.constraint(equalToConstant: 40),

            // Generate Recipe Button at the bottom center
            generateRecipeButton.widthAnchor.constraint(equalToConstant: 180),
            generateRecipeButton.heightAnchor.constraint(equalToConstant: 50),
            generateRecipeButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            generateRecipeButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])
    }
    
    @objc func generateRecipe() {
        currentStepIndex = 0
        recipeLabel.text = steps[currentStepIndex]
    }
    
    @objc func nextStep() {
        if currentStepIndex < steps.count - 1 {
            currentStepIndex += 1
            recipeLabel.text = steps[currentStepIndex]
        }
    }
    
    func setupBoundingBoxLayer() {
        boxesView = DrawingBoundingBoxView()
        boxesView.translatesAutoresizingMaskIntoConstraints = false
        boxesView.backgroundColor = UIColor.clear
        view.addSubview(boxesView)

        NSLayoutConstraint.activate([
            boxesView.topAnchor.constraint(equalTo: view.topAnchor),
            boxesView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            boxesView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            boxesView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    func setBoundingBoxPredictions(predictions: [VNRecognizedObjectObservation]) {
        DispatchQueue.main.async {
            self.boxesView?.predictedObjects = predictions
        }
    }
}

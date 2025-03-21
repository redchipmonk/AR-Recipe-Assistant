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
    
    var recipePanel: UIView! // Sliding panel container
    var recipeOverlay: UIView!
    var recipeLabel: UILabel!
    var nextStepButton: UIButton!
    var generateRecipeButton: UIButton!
    var toggleButton: UIButton! // New button to toggle panel
        
    var recipePanelTrailingConstraint: NSLayoutConstraint! // Constraint for sliding animation
    
    var settingsPanel: UIView!
    var settingsPanelLeadingConstraint: NSLayoutConstraint!
    var settingToggle1: UISegmentedControl!
    var settingToggle2: UISegmentedControl!
    var settingToggle3: UISegmentedControl!

    var settingsToggleButton: UIButton!
    
    
    var isMethod1: Bool = true
    var isMethod2: Bool = false
    
    var isDemo: Bool = true
    var isReal: Bool = false
    
    init(viewController: ViewController) {
        self.viewController = viewController
        self.view = viewController.view
        self.sceneView = viewController.sceneView
        setupUI()
    }
    
    func setupUI() {
        setupBoundingBoxLayer()
        setupRecipePanel()
        setupRecipeOverlay()
        setupGenerateRecipeButton()
        setupToggleButton()
        setupSettingsPanel()
        setupSettingsToggleButton()
        setupConstraints()
    }
    func setupSettingsPanel() {
        settingsPanel = UIView()
        settingsPanel.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        settingsPanel.layer.cornerRadius = 10
        settingsPanel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(settingsPanel)
        
        settingToggle1 = UISegmentedControl(items: ["YOLO", "VLM"])
        settingToggle1.selectedSegmentIndex = 0
        settingToggle1.translatesAutoresizingMaskIntoConstraints = false
        settingToggle1.addTarget(self, action: #selector(toggleMethod), for: .valueChanged)

        settingsPanel.addSubview(settingToggle1)
        
        settingToggle2 = UISegmentedControl(items: ["BB On", "BB Off"])
        settingToggle2.selectedSegmentIndex = 0
        settingToggle2.translatesAutoresizingMaskIntoConstraints = false
        settingToggle2.addTarget(self, action: #selector(toggleBoundingBoxVisibility), for: .valueChanged)
        settingsPanel.addSubview(settingToggle2)
        
        settingToggle3 = UISegmentedControl(items: ["Demo", "Real"])
        settingToggle3.selectedSegmentIndex = 0
        settingToggle3.translatesAutoresizingMaskIntoConstraints = false
        settingToggle3.addTarget(self, action: #selector(toggleDemo), for: .valueChanged)
        settingsPanel.addSubview(settingToggle3)
    }
    
    func setupSettingsToggleButton() {
        settingsToggleButton = UIButton()
        settingsToggleButton.setTitle("⚙", for: .normal)
        settingsToggleButton.backgroundColor = .gray
        settingsToggleButton.setTitleColor(.white, for: .normal)
        settingsToggleButton.layer.cornerRadius = 20
        settingsToggleButton.translatesAutoresizingMaskIntoConstraints = false
        settingsToggleButton.addTarget(self, action: #selector(toggleSettingsPanel), for: .touchUpInside)
        view.addSubview(settingsToggleButton)
    }
    
    
    
    func setupRecipePanel() {
        // Container view that holds the overlay and button
        recipePanel = UIView()
        recipePanel.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        recipePanel.layer.cornerRadius = 10
        recipePanel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(recipePanel)
    }
    
    func setupRecipeOverlay() {
        recipeOverlay = UIView()
        recipeOverlay.backgroundColor = UIColor.white.withAlphaComponent(0.8)
        recipeOverlay.layer.cornerRadius = 10
        recipeOverlay.translatesAutoresizingMaskIntoConstraints = false
        recipePanel.addSubview(recipeOverlay)
        
        recipeLabel = UILabel()
        recipeLabel.numberOfLines = 0
        recipeLabel.translatesAutoresizingMaskIntoConstraints = false
        recipeLabel.font = UIFont.systemFont(ofSize: 14)
        recipeLabel.textColor = .white
        recipeLabel.textAlignment = .center
        recipeLabel.adjustsFontSizeToFitWidth = true
        recipeLabel.minimumScaleFactor = 0.7
        recipeOverlay.addSubview(recipeLabel)
        
        nextStepButton = UIButton()
        nextStepButton.setTitle("Next", for: .normal)
        nextStepButton.backgroundColor = .systemBlue
        
        nextStepButton.setTitleColor(.white, for: .normal)
        nextStepButton.layer.cornerRadius = 5
        nextStepButton.translatesAutoresizingMaskIntoConstraints = false
        recipeOverlay.addSubview(nextStepButton)
    }
    
    func setupGenerateRecipeButton() {
        generateRecipeButton = UIButton()
        generateRecipeButton.setTitle("Generate Recipe", for: .normal)
        generateRecipeButton.backgroundColor = .systemGreen
        
        generateRecipeButton.setTitleColor(.white, for: .normal)
        generateRecipeButton.layer.cornerRadius = 5
        generateRecipeButton.translatesAutoresizingMaskIntoConstraints = false
        recipePanel.addSubview(generateRecipeButton)
    }
    
    func setupToggleButton() {
        toggleButton = UIButton()
        toggleButton.setTitle("🍳", for: .normal)
        toggleButton.backgroundColor = .brown
        toggleButton.setTitleColor(.white, for: .normal)
        toggleButton.layer.cornerRadius = 20
        toggleButton.translatesAutoresizingMaskIntoConstraints = false
        toggleButton.addTarget(self, action: #selector(togglePanel), for: .touchUpInside)
        view.addSubview(toggleButton)
    }
    
    func setupConstraints() {
        settingsPanelLeadingConstraint = settingsPanel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: -200)

        recipePanelTrailingConstraint = recipePanel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 200) // Initially off-screen
        
        NSLayoutConstraint.activate([
            // Full-screen Scene View
            sceneView.topAnchor.constraint(equalTo: view.topAnchor),
            sceneView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            sceneView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            sceneView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            // Recipe Panel (Slide-in Container)
            recipePanel.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.4),
            
            recipePanel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            recipePanel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            recipePanelTrailingConstraint,
            
            // Recipe Overlay inside the panel
            recipeOverlay.topAnchor.constraint(equalTo: recipePanel.topAnchor, constant: 10),
            recipeOverlay.leadingAnchor.constraint(equalTo: recipePanel.leadingAnchor, constant: 10),
            recipeOverlay.trailingAnchor.constraint(equalTo: recipePanel.trailingAnchor, constant: -10),
            recipeOverlay.heightAnchor.constraint(equalTo: recipePanel.heightAnchor, multiplier: 0.7), // 70% height
            
            // Recipe Label inside overlay
            recipeLabel.topAnchor.constraint(equalTo: recipeOverlay.topAnchor, constant: 10),
            recipeLabel.leadingAnchor.constraint(equalTo: recipeOverlay.leadingAnchor, constant: 10),
            recipeLabel.trailingAnchor.constraint(equalTo: recipeOverlay.trailingAnchor, constant: -10),
            
            // Next Step Button inside overlay
            nextStepButton.bottomAnchor.constraint(equalTo: recipeOverlay.bottomAnchor, constant: -10),
            nextStepButton.leadingAnchor.constraint(equalTo: recipeOverlay.leadingAnchor, constant: 10),
            nextStepButton.trailingAnchor.constraint(equalTo: recipeOverlay.trailingAnchor, constant: -10),
            nextStepButton.heightAnchor.constraint(equalToConstant: 40),
            
            // Generate Recipe Button at the bottom of the panel
            generateRecipeButton.bottomAnchor.constraint(equalTo: recipePanel.bottomAnchor, constant: -10),
            generateRecipeButton.leadingAnchor.constraint(equalTo: recipePanel.leadingAnchor, constant: 10),
            generateRecipeButton.trailingAnchor.constraint(equalTo: recipePanel.trailingAnchor, constant: -10),
            generateRecipeButton.heightAnchor.constraint(equalToConstant: 50),
            
            // Toggle Button (Floating)
            toggleButton.widthAnchor.constraint(equalToConstant: 40),
            toggleButton.heightAnchor.constraint(equalToConstant: 40),
            toggleButton.centerYAnchor.constraint(equalTo: recipePanel.centerYAnchor),
            toggleButton.trailingAnchor.constraint(equalTo: recipePanel.leadingAnchor, constant: -10),
            
            
            settingsPanel.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.4),
            settingsPanel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            settingsPanel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            settingsPanelLeadingConstraint,
            
            settingToggle1.topAnchor.constraint(equalTo: settingsPanel.topAnchor, constant: 20),
            settingToggle1.leadingAnchor.constraint(equalTo: settingsPanel.leadingAnchor, constant: 10),
            settingToggle1.trailingAnchor.constraint(equalTo: settingsPanel.trailingAnchor, constant: -10),
            
            settingToggle2.topAnchor.constraint(equalTo: settingToggle1.bottomAnchor, constant: 20),
            settingToggle2.leadingAnchor.constraint(equalTo: settingsPanel.leadingAnchor, constant: 10),
            settingToggle2.trailingAnchor.constraint(equalTo: settingsPanel.trailingAnchor, constant: -10),
            
            settingToggle3.topAnchor.constraint(equalTo: settingToggle2.bottomAnchor, constant: 20),
            settingToggle3.leadingAnchor.constraint(equalTo: settingsPanel.leadingAnchor, constant: 10),
            settingToggle3.trailingAnchor.constraint(equalTo: settingsPanel.trailingAnchor, constant: -10),
            
            settingsToggleButton.widthAnchor.constraint(equalToConstant: 40),
            settingsToggleButton.heightAnchor.constraint(equalToConstant: 40),
            settingsToggleButton.centerYAnchor.constraint(equalTo: settingsPanel.centerYAnchor),
            settingsToggleButton.leadingAnchor.constraint(equalTo: settingsPanel.trailingAnchor, constant: 10)
        ])
    }
    
    @objc func togglePanel() {
        let isExpanded = recipePanelTrailingConstraint.constant == 0
        recipePanelTrailingConstraint.constant = isExpanded ? 200 : 0 // Slide in or out
        
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    @objc func toggleSettingsPanel() {
        let isExpanded = settingsPanelLeadingConstraint.constant == 0
        settingsPanelLeadingConstraint.constant = isExpanded ? -200 : 0
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    @objc func toggleBoundingBoxVisibility() {
        let isBoundingBoxOn = settingToggle2.selectedSegmentIndex == 0
        boxesView.isHidden = !isBoundingBoxOn
    }
    
    @objc func toggleMethod() {
        self.isMethod1 = settingToggle1.selectedSegmentIndex == 0
        self.isMethod2 = settingToggle1.selectedSegmentIndex == 1
    }
    
    @objc func toggleDemo()  {
        self.isDemo = settingToggle3.selectedSegmentIndex == 0
        self.isReal = settingToggle3.selectedSegmentIndex == 1
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

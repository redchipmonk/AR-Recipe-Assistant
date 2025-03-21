//
//  ReciperManager.swift
//  AR-Recipe-Assistant
//
//  Created by Paul Han on 3/17/25.
//

import Foundation
import UIKit

class ReciperManager {
    
    var steps: [String] = ["Welcome to Recipe AR Assistant!"]
    
    var currentStepIndex = 0
    
    var isGeneratingRecipe: Bool = false
    
    private var uiManager: UIManager!
    private var arSessionHandler: ARSessionHandler!
    
    private var frameTimer: Timer?
    private let timerInterval = 3.0 // process a frame every X seconds
    
    private var startWorldState:String = ""
    
    
    init(uiManager: UIManager, arSessionHandler: ARSessionHandler) {
        self.uiManager = uiManager
        self.arSessionHandler = arSessionHandler
        
        setupUITargets()
        startFrameProcessingTimer()
    }
    
    private func startFrameProcessingTimer() {
        frameTimer = Timer.scheduledTimer(timeInterval: timerInterval, target: self, selector: #selector(processFramePeriodically), userInfo: nil, repeats: true)
        
    }

    private func setupUITargets() {
        self.uiManager.nextStepButton.addTarget(self, action: #selector(nextStep), for: .touchUpInside)
        self.uiManager.generateRecipeButton.addTarget(self, action: #selector(generateRecipe), for: .touchUpInside)
        self.uiManager.recipeLabel.text = self.steps[0]
    }
    
    @objc private func processFramePeriodically() {
        // If not currently in the middle of recipe, do not process frame
        if !isGeneratingRecipe {
            return
        }
        
        // Depending on whether Method1 or Method2 is selected, process the frame differently

        if self.uiManager.isMethod1 {
            let currState: String = VisionProcessor.shared.getCurrentWorldStateString()
            
            let recipeStepQuery = Templates.generateRecipeStepQueryPromptMethod2(recipeSteps: self.steps, startState: self.startWorldState, currentState: currState)
            
            queryOpenAI(prompt: recipeStepQuery) { response in
                DispatchQueue.main.async {
                    let unwrappedResponse = response ?? "No response"
                    print("OpenAI Response:", unwrappedResponse)
                    
                    let extractedStepNum = self.extractStepNumber(from: unwrappedResponse)
                    if extractedStepNum == -1 {
                        // for now, just don't update the current step number
                        print("Error: Could not sense current step number")
                    } else {
                        self.currentStepIndex = extractedStepNum
                        self.uiManager.recipeLabel.text = self.steps[self.currentStepIndex]
                        
                        // Stop recipe sensing when you reach the last step
                        if self.currentStepIndex == self.steps.count - 1 {
                            self.isGeneratingRecipe = false
                        }
                    }
                }
            }
            
        } else if self.uiManager.isMethod2 {
            let frame = self.arSessionHandler.getCurrentFrame()
            guard let frameBase64 = frame.toBase64() else { return }
            
            let recipeStepQuery = Templates.generateRecipeStepQueryPromptMethod1(recipeSteps: self.steps, prevStep: self.currentStepIndex)
            
            queryOpenAI(prompt: recipeStepQuery, imageBase64: frameBase64) { response in
                DispatchQueue.main.async {
                    let unwrappedResponse = response ?? "No response"
                    print("OpenAI Response:", unwrappedResponse)
                    
                    let extractedStepNum = self.extractStepNumber(from: unwrappedResponse)
                    if extractedStepNum == -1 {
                        // for now, just don't update the current step number
                        print("Error: Could not sense current step number")
                    } else {
                        self.currentStepIndex = extractedStepNum
                        self.uiManager.recipeLabel.text = self.steps[self.currentStepIndex]
                        
                        // Stop recipe sensing when you reach the last step
                        if self.currentStepIndex == self.steps.count - 1 {
                            self.isGeneratingRecipe = false
                        }
                    }
                }
            }
        }
    }
    
    @objc func generateRecipe() {
        let image = self.arSessionHandler.getCurrentFrame()
        guard let imageBase64 = image.toBase64() else { return }
        
        // Additionally, if using Method1 need to also save starting objects
        if self.uiManager.isMethod1 && self.uiManager.isReal {
            self.startWorldState = VisionProcessor.shared.getCurrentWorldStateString()
        } else if self.uiManager.isMethod1 && self.uiManager.isDemo {
            self.startWorldState = Templates.getDemoStartWorldState()
        }
        
        if self.uiManager.isDemo {
            self.steps = self.extractRecipeGeneration(from: Templates.generateSampleRecipe())
            self.currentStepIndex = 0
            self.uiManager.recipeLabel.text = self.steps[0]
            if self.steps.count > 1 {
                self.isGeneratingRecipe = true
            }
        } else if self.uiManager.isReal {
            let recipePrompt = Templates.generateRecipePrompt()
            queryOpenAI(prompt: recipePrompt, imageBase64: imageBase64) { response in
                DispatchQueue.main.async {
                    let unwrappedResponse = response ?? "No response"
                    print("OpenAI Response:", unwrappedResponse)
                    
                    self.steps = self.extractRecipeGeneration(from: unwrappedResponse)
                    self.currentStepIndex = 0
                    self.uiManager.recipeLabel.text = self.steps[0]
                    if self.steps.count > 1 {
                        self.isGeneratingRecipe = true
                    }
                }
            }
        }
    }

    @objc func nextStep() {
        if isGeneratingRecipe && currentStepIndex < steps.count - 1 {
            currentStepIndex += 1
            
            UIView.transition(with: self.uiManager.recipeLabel, duration: 0.3, options: .transitionCrossDissolve, animations: {
                self.uiManager.recipeLabel.text = self.steps[self.currentStepIndex]
            })
            
            // Stop recipe sensing when you reach the last step
            if currentStepIndex == steps.count - 1 {
                isGeneratingRecipe = false
            }
        }
    }
    
    
    func extractStepNumber(from response: String) -> Int {
        if response.contains("<unknown>") {
            return -1
        }
        
        let pattern = #"<answer>Step (\d+)<answer>"#
        
        if let regex = try? NSRegularExpression(pattern: pattern),
           let match = regex.firstMatch(in: response, range: NSRange(response.startIndex..., in: response)),
           let range = Range(match.range(at: 1), in: response) {
            
            return Int(response[range]) ?? -1
        }

        return -1
    }
    
    
    private func extractRecipeGeneration(from recipe: String) -> [String] {
        var steps: [String] = []
        
        // If the recipe contains <recipe-impossible>, return an error message
        if recipe.contains("<recipe-impossible>") {
            return ["Recipe cannot be constructed from the image. Not enough food items."]
        }
        
        if recipe.contains("No response") {
            return ["Could not communicate with LLM server. Please try again."]
        }
        
        // Match content between <recipe-start> and <recipe-end>
        let recipePattern = #"<recipe-start>([\s\S]*?)<recipe-end>"#
        let stepPattern = #"(Step \d+: .+)"#

        if let recipeRegex = try? NSRegularExpression(pattern: recipePattern, options: []),
           let stepRegex = try? NSRegularExpression(pattern: stepPattern, options: []) {
            
            if let match = recipeRegex.firstMatch(in: recipe, options: [], range: NSRange(recipe.startIndex..., in: recipe)),
               let range = Range(match.range(at: 1), in: recipe) {
                
                let extractedRecipe = String(recipe[range])

                // Extract individual steps while keeping "Step X: ..."
                let matches = stepRegex.matches(in: extractedRecipe, options: [], range: NSRange(extractedRecipe.startIndex..., in: extractedRecipe))
                
                for match in matches {
                    if let range = Range(match.range(at: 1), in: extractedRecipe) {
                        steps.append(String(extractedRecipe[range]))
                    }
                }
            }
        }

        return steps
    }
}

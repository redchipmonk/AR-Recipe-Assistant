//
//  Templates.swift
//  AR-Recipe-Assistant
//
//  Created by Paul Han on 3/17/25.
//

struct Templates {
    static func generateRecipePrompt() -> String {
        return """
        What is a recipe that can be generated from the items in the image? Give a step by step recipe, in the following format:
        <recipe-start>
        Step 1: ... 
        Step 2: ...
        ...
        Step N: Done!
        <recipe-end>
        
        Or, if there are not enough appropriate food items in the image, return:
        <recipe-impossible>
        """
    }
    
    static func generateRecipeStepQueryPromptMethod1(recipeSteps: [String], prevStep: Int) -> String {
        let recipeString = recipeSteps.joined(separator: "\n")
        return """
        You are given the following recipe:

        \(recipeString)

        Now, examine the image and determine which step, if any, is currently being executed. Your task is to identify the most likely step **only if it is unambiguous based on the visual evidence**.

        ⚠️ If the image does **not clearly correspond** to a specific step, or if there is any ambiguity, respond with:
        <unknown>

        ✅ If you are highly confident and the visual evidence **clearly and directly corresponds to exactly one step**, respond in the following format:
        <answer>Step X<answer>

        Do not guess. Only make a step prediction if you are certain.
        """
    }
    
    static func getDemoStartWorldState() -> String {
        return """
        - banana at (44.73, 34.95)
        - orange at (32.11, 65.4)
        - apple at (72.13, 65.16)
        """
    }
    
    static func generateRecipeStepQueryPromptMethod2(recipeSteps: [String], startState: String, currentState: String) -> String {
        let recipeString = recipeSteps.joined(separator: "\n")
        return """
        Suppose I have the following recipe:
        \(recipeString)

        We represent world states by listing the **detected relevant objects** in the scene, along with their **normalized camera space coordinates (range: 0-100)**. These coordinates indicate where objects are positioned within the camera frame.

        - **The initial state of the world** (before any steps were executed) is:
        \(startState)

        - **The current detected state** (objects currently visible) is:
        \(currentState)

        Objects may **change position**, **new objects may appear**, and **some may disappear** as the user progresses through the recipe steps. The goal is to **infer the most likely step** based on these state transitions.

        ### **Task:**
        Analyze the detected objects and their positions. Determine which step of the recipe is currently being executed.

        - If a step can be **clearly determined**, respond in the format:  
          `<answer>Step X<answer>`

        - If it is **ambiguous or impossible to determine**, return `<unknown>`

        Think step-by-step about the logical progression of objects through the recipe steps before answering.
        """
    }
    
    static func generateSampleRecipe() -> String {
        return """
            <recipe-start>
            Step 1: Rinse apple with water for 10-20 seconds
            Step 2: Cut apple into slices.
            Step 3: Peel and slice banana into slices.
            Step 4: Peel and slice orange into slices.
            Step 5: Mix apple, orange, and banana slices together in same bowl.
            <recipe-end>
        """
    }
}

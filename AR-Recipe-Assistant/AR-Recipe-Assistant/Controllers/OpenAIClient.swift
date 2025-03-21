//
//  OpenAIClient.swift
//  AR-Recipe-Assistant
//
//  Created by Paul Han on 3/13/25.
//


import Foundation
import UIKit

struct OpenAIResponse: Codable {
    let choices: [Choice]
}

struct Choice: Codable {
    let message: Message
}

struct Message: Codable {
    let content: String
}

func encodeImageToBase64(image: UIImage) -> String? {
    return image.pngData()?.base64EncodedString()
}

func queryOpenAI(prompt: String, imageBase64: String, completion: @escaping (String?) -> Void) {
    let url = URL(string: "https://api.openai.com/v1/chat/completions")!
    let apiKey = ProcessInfo.processInfo.environment["OPENAI_API_KEY"]

    
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.addValue("Bearer \(apiKey ?? "NO_API_KEY")", forHTTPHeaderField: "Authorization")
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
    let requestBody: [String: Any] = [
            "model": "gpt-4o-mini",
            "messages": [
                [
                    "role": "user",
                    "content": [
                        ["type": "text", "text": prompt],
                        ["type": "image_url", "image_url": ["url": "data:image/jpeg;base64,\(imageBase64)"]]
                    ]
                ]
            ],
            "max_tokens": 1000
        ]
  
    request.httpBody = try? JSONSerialization.data(withJSONObject: requestBody)

    let task = URLSession.shared.dataTask(with: request) { data, response, error in
        guard let data = data, error == nil else {
            print("Error:", error ?? "Unknown error")
            completion(nil)
            return
        }
        
        if let response = try? JSONDecoder().decode(OpenAIResponse.self, from: data) {
            completion(response.choices.first?.message.content)
        } else {
            completion(nil)
        }
    }
    
    task.resume()
}


func queryOpenAI(prompt: String, completion: @escaping (String?) -> Void) {
    let url = URL(string: "https://api.openai.com/v1/chat/completions")!
    let apiKey = ProcessInfo.processInfo.environment["OPENAI_API_KEY"]

    
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.addValue("Bearer \(apiKey ?? "NO_API_KEY")", forHTTPHeaderField: "Authorization")
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
    let requestBody: [String: Any] = [
            "model": "gpt-4o-mini",
            "messages": [
                [
                    "role": "user",
                    "content": [
                        ["type": "text", "text": prompt]
                    ]
                ]
            ],
            "max_tokens": 1000
        ]
  
    request.httpBody = try? JSONSerialization.data(withJSONObject: requestBody)

    let task = URLSession.shared.dataTask(with: request) { data, response, error in
        guard let data = data, error == nil else {
            print("Error:", error ?? "Unknown error")
            completion(nil)
            return
        }
        
        if let response = try? JSONDecoder().decode(OpenAIResponse.self, from: data) {
            completion(response.choices.first?.message.content)
        } else {
            completion(nil)
        }
    }
    
    task.resume()
}

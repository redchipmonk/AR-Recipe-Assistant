//
//  DrawingBoundingBoxView.swift
//  AR-Recipe-Assistant
//
//  Created by Paul Han on 3/13/25.
//

import UIKit
import Vision

class DrawingBoundingBoxView: UIView {
    
    private var overlayLayer = CALayer()
    
    static private var colors: [String: UIColor] = [:]
    
    public func labelColor(with label: String) -> UIColor {
        if let color = DrawingBoundingBoxView.colors[label] {
            return color
        } else {
            let color = UIColor(hue: .random(in: 0...1), saturation: 1, brightness: 1, alpha: 0.8)
            DrawingBoundingBoxView.colors[label] = color
            return color
        }
    }
    
    public var predictedObjects: [VNRecognizedObjectObservation] = [] {
        didSet {
            DispatchQueue.main.async {
                self.drawBoxes(with: self.predictedObjects)
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupOverlayLayer()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupOverlayLayer()
    }
    
    private func setupOverlayLayer() {
        overlayLayer.frame = self.bounds
        self.layer.addSublayer(overlayLayer)
    }
    
    func drawBoxes(with predictions: [VNRecognizedObjectObservation]) {
        overlayLayer.sublayers?.forEach { $0.removeFromSuperlayer() }

        for prediction in predictions {
            drawBoundingBox(for: prediction)
        }
    }
    
    private func drawBoundingBox(for prediction: VNRecognizedObjectObservation) {
        let labelString: String = prediction.label ?? "N/A"
        let color: UIColor = labelColor(with: labelString)

        let scale = CGAffineTransform(scaleX: bounds.width, y: bounds.height)
        let flip = CGAffineTransform(scaleX: 1, y: -1).translatedBy(x: 0, y: -1)
        let transformedRect = prediction.boundingBox.applying(flip).applying(scale)

        // Draw Bounding Box
        let boxLayer = CAShapeLayer()
        boxLayer.frame = transformedRect
        boxLayer.borderColor = color.cgColor
        boxLayer.borderWidth = 4
        boxLayer.backgroundColor = UIColor.clear.cgColor
        overlayLayer.addSublayer(boxLayer)

        // Draw Label
        let textLayer = CATextLayer()
        textLayer.string = labelString
        textLayer.fontSize = 14
        textLayer.alignmentMode = .center
        textLayer.foregroundColor = UIColor.black.cgColor
        textLayer.backgroundColor = color.cgColor
        textLayer.cornerRadius = 4
        textLayer.contentsScale = UIScreen.main.scale
        textLayer.frame = CGRect(
            x: transformedRect.origin.x,
            y: transformedRect.origin.y - 20,
            width: 100,
            height: 20
        )
        overlayLayer.addSublayer(textLayer)
    }
}

extension VNRecognizedObjectObservation {
    var label: String? {
        return self.labels.first?.identifier
    }
}

extension CGRect {
    func toString(digit: Int) -> String {
        let xStr = String(format: "%.\(digit)f", origin.x)
        let yStr = String(format: "%.\(digit)f", origin.y)
        let wStr = String(format: "%.\(digit)f", width)
        let hStr = String(format: "%.\(digit)f", height)
        return "(\(xStr), \(yStr), \(wStr), \(hStr))"
    }
}


//
//  CanvasView.swift
//  Task6
//
//  Created by neoviso on 9/5/22.
//

import UIKit

class CanvasView: UIView {
    
    private var lines: [Line] = []
    private var undoLines: [Line] = []
    private var brushColor: UIColor = .black
    private var brushWidth: Float = 4
    
    weak var viewController: ViewController?
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        context.setLineCap(.round)
        context.setLineJoin(.round)
        
        lines.forEach { line in
            context.setStrokeColor(line.color.cgColor)
            context.setLineWidth(CGFloat(line.width))
            
            for (index, point) in line.points.enumerated() {
                if index == 0 {
                    context.move(to: point)
                } else {
                    context.addLine(to: point)
                }
            }
            context.strokePath()
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if lines.count == 0 {
            viewController?.clearCanvasButton.isEnabled = true
            viewController?.undoButton.isEnabled = true
        }
        if undoLines.count != 0 {
            viewController?.redoButton.isEnabled = false
            undoLines.removeAll()
        }
        
        lines.append(Line.init(points: [], color: brushColor, width: brushWidth))
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let point = touches.first?.location(in: self) else { return }
        guard var lastLine = lines.popLast() else { return }
        lastLine.points.append(point)
        lines.append(lastLine)
        setNeedsDisplay()
    }
    
    func undo() {
        if lines.count == 1 {
            viewController?.undoButton.isEnabled = false
            viewController?.clearCanvasButton.isEnabled = false
        }
        if viewController?.redoButton.isEnabled == false {
            viewController?.redoButton.isEnabled = true
        }
        undoLines.append(lines.removeLast())
        setNeedsDisplay()
    }
    
    func redo() {
        if undoLines.count == 1 {
            viewController?.redoButton.isEnabled = false
        }
        if viewController?.undoButton.isEnabled == false {
            viewController?.undoButton.isEnabled = true
        }
        if viewController?.clearCanvasButton.isEnabled == false {
            viewController?.clearCanvasButton.isEnabled = true
        }
        lines.append(undoLines.last!)
        undoLines.removeLast()
        setNeedsDisplay()
    }
    
    func clear() {
        guard lines.count > 0 else { return }
        lines.removeAll()
        undoLines.removeAll()
        viewController?.undoButton.isEnabled = false
        viewController?.redoButton.isEnabled = false
        viewController?.clearCanvasButton.isEnabled = false
        setNeedsDisplay()
    }
    
    func setBrushWidth(width: Float) {
        brushWidth = width
    }
    
    func setBrushColor(color: UIColor) {
        brushColor = color
    }
}


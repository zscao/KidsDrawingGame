//  Copyright © 2019 zscao. All rights reserved.

import UIKit
import KidsDrawingGame

class CanvasView: UIView {
    
    private var _strokeColor: CGColor = UIColor.black.cgColor
    
    private var _canvas: Drawable?
    private var _store: DrawingStore?
    private var _drawingLayer: CALayer!
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func setup(viewMode: ViewMode, picture: Picture) {
        
        // setup background
        if let texture = UIImage(named: "CanvasTexture") {
            self.layer.backgroundColor = UIColor(patternImage: texture).cgColor
        }
        
        // setup drawing layer
        let drawingLayer = CALayer()
        drawingLayer.frame = self.frame
        self.layer.addSublayer(drawingLayer)
        _drawingLayer = drawingLayer
        
        // setup sketch layer
        let sketch = Sketch(picture: picture)
        let scale = sketch.getScale(size: self.frame.size)
        let layer = sketch.getSketchLayer(strokeColor: viewMode.color.cgColor, lineWidth: SketchLineWidth / scale)
        layer.transform = CATransform3DMakeScale(scale, scale, 1)
        layer.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        self.layer.addSublayer(layer)
        
        _store = DrawingStore(id: picture.name)
        _canvas = Canvas(size: self.frame.size.toScreenScalePixel(), picture: picture, viewMode: viewMode)
        _strokeColor = UIColor.red.cgColor

        reset()
    }
    
    func reset() {
        if let store = _store, let canvas = _canvas {
            let lines = store.loadLines()
            canvas.setup(lines: lines)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first, let canvas = _canvas else { return }
        
        let location = touch.location(in: self)
        canvas.startLine(start: location.toScreenScalePixel(), color: _strokeColor, width: 30 * UIScreen.main.scale)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first, let canvas = _canvas else { return }
        
        let location = touch.location(in: self)
        canvas.lineTo(to: location.toScreenScalePixel())
        
        refreshDrawing()
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first, let canvas = _canvas else { return }
        
        let location = touch.location(in: self)
        canvas.endLine(at: location.toScreenScalePixel())
        
        refreshDrawing()
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let canvas = _canvas else { return }
        
        let location = touches.first?.location(in: self)
        canvas.endLine(at: location?.toScreenScalePixel())
    }
    
    func setStrokeColor(color: UIColor) {
        _strokeColor = color.cgColor
    }
    
    func clear() {
        _canvas?.clear()
        refreshDrawing()
    }
    
    func undo() {
        _canvas?.undo()
        refreshDrawing()
    }
    
    func refreshDrawing() {
        if let canvas = _canvas, let image = canvas.image {
            _drawingLayer.contents = image
            //let uiImage = UIImage(cgImage: image, scale: UIScreen.main.scale, orientation: .up)
            //self.image = uiImage
        }
    }
    
    func save() {
        if let canvas = _canvas, canvas.changed, let store = _store {
            //let lines = canvas.lines
            //store.saveLines(lines: lines)
        }
    }
    
    func replay() {
        
        guard let canvas = _canvas else { return }
        
        let strokes = canvas.strokes
        if strokes.count == 0 { return }
        
        canvas.clear()
        self.refreshDrawing()
        
        var strokeIndex: Int = 0
        var pointIndex: Int = 0
        
        Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { [unowned self] timer in
            
            let stroke = strokes[strokeIndex]
            if stroke is LineStroke {
                let line = (stroke as! LineStroke).line
                
                if pointIndex == 0 {
                    canvas.startLine(start: line.startPoint, color: line.color, width: line.width)
                    self.refreshDrawing()
                }
                else {
                    canvas.lineTo(to: line.points[pointIndex])
                    self.refreshDrawing()
                }
                
                pointIndex += 1
                if pointIndex >= line.points.count {
                    pointIndex = 0
                    strokeIndex += 1
                }
            }
            else {
                strokeIndex += 1
            }
            
            if strokeIndex >= strokes.count {
                timer.invalidate()
                print("done")
            }
        }
    }
}

extension CGSize {
    func toScreenScalePixel() -> CGSize {
        let scale = UIScreen.main.scale
        return CGSize(width: self.width * scale, height: self.height * scale)
    }
}

extension CGPoint {
    func toScreenScalePixel() -> CGPoint {
        let scale = UIScreen.main.scale
        return CGPoint(x: self.x * scale, y: self.y * scale)
    }
}

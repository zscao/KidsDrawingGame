//  Copyright © 2019 zscao. All rights reserved.

import UIKit
import KidsDrawingGame

class CanvasView: UIView {
    
    private var _strokeColor: CGColor = UIColor.black.cgColor
    
    private var _canvas: Drawable? = nil
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func setup(viewMode: ViewMode, picture: Picture) {
        _canvas = Canvas(size: frame.size, picture: picture, viewMode: viewMode)
        
        if let sketch = _canvas?.sketchLayer {
            sketch.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
            self.layer.addSublayer(sketch)
        }
        _strokeColor = UIColor.red.cgColor
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first, let canvas = _canvas else { return }
        
        let location = touch.location(in: self)
        canvas.startLine(start: location, color: _strokeColor, width: 30)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first, let canvas = _canvas else { return }
        
        let location = touch.location(in: self)
        canvas.lineTo(to: location)
        
        refreshDrawing()
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first, let canvas = _canvas else { return }
        
        let location = touch.location(in: self)
        canvas.endLine(at: location)
        
        refreshDrawing()
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let canvas = _canvas else { return }
        
        
        
        let location = touches.first?.location(in: self)
        canvas.endLine(at: location)
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
            self.layer.contents = image
        }
    }
}


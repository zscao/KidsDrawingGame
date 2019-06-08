//  Copyright © 2019 zscao. All rights reserved.

import UIKit
import KidsDrawingGame

class CanvasView: UIView {
    
    private var _strokeColor: CGColor = UIColor.black.cgColor
    
    private var _canvas: Canvas? = nil
    
    /*
     // Only override draw() if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     override func draw(_ rect: CGRect) {
     // Drawing code
     }
     */
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func setup(viewMode: ViewMode) {
        let album = Album()
        album.addShapes()
        album.addSamples()
        
        if let square = album["butterfly"] {
            _canvas = Canvas(size: frame.size, baseMap: square, viewMode: viewMode)
        }
        _strokeColor = UIColor.red.cgColor
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first, let canvas = _canvas else { return }
        
        let location = touch.location(in: self)
        canvas.startLine(start: location, color: _strokeColor, width: 30)
        
        if let layer = self.layer.hitTest(location) as? CAShapeLayer {
            layer.fillColor = UIColor.green.cgColor
        }
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
        if let canvas = _canvas, let image = canvas.getImage() {
            self.layer.contents = image
        }
    }
}


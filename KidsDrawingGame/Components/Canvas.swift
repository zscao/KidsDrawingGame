//  Copyright © 2019 zscao. All rights reserved.

import UIKit

public class Canvas {
    
    private var _cgContext: CGContext?
    private var _picture: Picture
    private var _viewMode: ViewMode
    
    //private var _sketchLayer: CALayer?
    private var _mask: Masking?
    
    private var _currentStroke: Stroke?
    private var _historyStrokes: [Stroke]
    
    private var imageWidth: Int = 0
    private var imageHeight: Int = 0
    
    private var _changed: Bool = false
    
    public init(size: CGSize, picture: Picture, viewMode: ViewMode) {
        imageWidth = Int(size.width)
        imageHeight = Int(size.height)
        
        _picture = picture
        _viewMode = viewMode
        
        _historyStrokes = [Stroke]()
                
        _mask = ImageMask(size: size, picture: picture)
        _cgContext = getImageContext()
    }
        
    private func getImageContext() -> CGContext? {

        if let context = CGContext(data: nil,
                         width: imageWidth,
                         height: imageHeight,
                         bitsPerComponent: 8,
                         bytesPerRow: 0,
                         space: CGColorSpaceCreateDeviceRGB(),
                         bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) {
            context.setShouldAntialias(true)
            
            let flipVertical = CGAffineTransform(a: 1, b: 0, c: 0, d: -1, tx: 0, ty: CGFloat(context.height))
            context.concatenate(flipVertical)
            
            return context
        }        
        return nil
    }
    
    private func reset() {
        if let context = _cgContext {
            context.resetClip()
            
            let rect = CGRect(x: 0, y: 0, width: imageWidth, height: imageHeight)
            context.clear(rect)
            //context.setFillColor(_viewMode.backgroundColor.cgColor)
            //context.fill(rect)
            
            for stroke in _historyStrokes {
                context.makeStroke(stroke: stroke)
            }
        }
    }
    
    //this is to translate the coordinate of UIView to that of Quartz
    private func flipVertical(position: CGPoint) -> CGPoint {
        return CGPoint(x: position.x, y: CGFloat(self.imageHeight) - position.y)
    }
}


extension Canvas: Drawable {

    public var image: CGImage? {
        get {
            return _cgContext?.makeImage()
        }
    }
    
    public var strokes: [Stroke] {
        get {
            // make a copy of the history
            return _historyStrokes.map({ (stroke) -> Stroke in
                return stroke
            })
        }
    }
    
    public var changed: Bool {
        get {
            return self._changed
        }
    }
    
    public func setup(lines: [Line]) {
        
        guard let mask = _mask else { return }
        
        if lines.count > 0 {
            mask.preloadMasks()
            for line in lines {
                let maskImage = mask.getMaskImageAtPoint(at: flipVertical(position: line.startPoint))
                let stroke = LineStroke(line: line, mask: maskImage)
                _historyStrokes.append(stroke)
            }
        }
        else {
            DispatchQueue.global(qos: .userInitiated).async {
                mask.preloadMasks()
            }
        }
        
        reset()
    }
    
    public func startLine(start: CGPoint, color: CGColor, width lineWidth: CGFloat) {
        guard let context = _cgContext, let mask = _mask else { return }
        
        // restart a new stroke
        _currentStroke = nil
        
        if mask.isPointInBound(at: start) == false {
            return
        }
        
        let maskImage = mask.getMaskImageAtPoint(at: flipVertical(position: start))
        
        let line = Line(start: start, color: color, width: lineWidth)
        _currentStroke = LineStroke(line: line, mask: maskImage)
        
        guard let stroke = _currentStroke as? LineStroke else { return }
        _historyStrokes.append(stroke)
        
        context.makeStroke(stroke: stroke)
        
        _changed = true
    }
    
    public func lineTo(to: CGPoint) {
        guard let context = _cgContext, let stroke = _currentStroke as? LineStroke else { return }
        
        stroke.line.lineTo(to: to)
        
        context.addPath(stroke.line.lastSegment)
        context.strokePath()
        
        _changed = true
    }
    
    public func endLine(at: CGPoint?) {
        if let endPoint = at {
            lineTo(to: endPoint)
        }
        _currentStroke = nil
    }
    
    public func fill(at: CGPoint, color: CGColor) {
        guard let context = _cgContext, let mask = _mask else { return }
        
        _currentStroke = nil
        
        if mask.isPointInBound(at: at) == false { return }
        
        let maskImage = mask.getMaskImageAtPoint(at: flipVertical(position: at))
        context.fillMask(mask: maskImage, color: color)
    }
    
    public func clear() {
        _historyStrokes.removeAll()
        reset()
        
        _changed = true
    }
    
    public func undo() {
        if _historyStrokes.isEmpty == false {
            _historyStrokes.removeLast()
            reset()
            
            _changed = true
        }
    }    
}


fileprivate extension CGContext {
    func makeStroke(stroke: Stroke) {
        resetClip()
        if let mask = stroke.mask {
            let rect = flipVertical(rect: mask.rect)
            clip(to: rect, mask: mask.image)
        }
        
        if stroke is LineStroke {
            let lineStroke = stroke as! LineStroke
            let line = lineStroke.line
            
            if line.color == UIColor.clear.cgColor {
                setBlendMode(.clear)
            }
            else {
                setBlendMode(.color)
            }
            setStrokeColor(line.color)
            setLineWidth(line.width)
            setLineJoin(.round)
            setLineCap(.round)
            addPath(line.path)
            strokePath()
        }
    }
    
    func fillMask(mask: MaskImage?, color: CGColor) {
        resetClip()
        if let mask = mask {
            let rect = flipVertical(rect: mask.rect)
            clip(to: rect, mask: mask.image)
            
            setFillColor(color)
            fill(rect)
        }
    }
    
    private func flipVertical(rect: CGRect) -> CGRect {
        return CGRect(origin: CGPoint(x: rect.origin.x, y: CGFloat(height) - rect.origin.y - rect.height), size: rect.size)
    }
}




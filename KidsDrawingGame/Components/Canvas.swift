//  Copyright © 2019 zscao. All rights reserved.

import UIKit

public class Canvas {
    public var image: CGImage? {
        get {
            return _cgContext?.makeImage()
        }
    }
    
    public var sketchLayer: CALayer? {
        get {
            return _sketchLayer
        }
    }
    
    
    private var _cgContext: CGContext?
    private var _picture: Picture
    private var _viewMode: ViewMode
    
    private var _sketchLayer: CALayer?
    private var _mask: Mask?
    
    private var _currentStroke: Stroke?
    private var _historyStrokes: [Stroke] = [Stroke]()
    
    private var imageWidth: Int = 0
    private var imageHeight: Int = 0
    
    public init(size: CGSize, picture: Picture, viewMode: ViewMode) {
        imageWidth = Int(size.width)
        imageHeight = Int(size.height)
        
        _picture = picture
        _viewMode = viewMode
        
        _cgContext = getImageContext()
        _sketchLayer = getSketchLayer()
        
        if let maskImage = getMaskImage() {
            _mask = Mask(image: maskImage)
        }
        
        reset()
    }
    
    
    private func getSketchLayer() -> CALayer {
        let sketch = Sketch(picture: _picture);
        let layer = sketch.getSketchLayer(strokeColor: _viewMode.color.cgColor, lineWidth: 5)
        
        let scale = sketch.getScale(width: imageWidth, height: imageHeight)
        layer.transform = CATransform3DMakeScale(scale, scale, 1)

        return layer
    }
    
    private func getMaskImage() -> CGImage? {
        if let context = getMaskContext() {
            setContextTransform(context: context)
            
            let sketch = Sketch(picture: _picture)
            let layer = sketch.getSketchLayer(strokeColor: UIColor.white.cgColor, lineWidth: 3)
            
            layer.render(in: context)
            return context.makeImage()
        }
        return nil
    }
    
    private func getImageContext() -> CGContext? {
        return CGContext(data: nil,
                         width: imageWidth,
                         height: imageHeight,
                         bitsPerComponent: 8,
                         bytesPerRow: 0,
                         space: CGColorSpaceCreateDeviceRGB(),
                         bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue)
    }
    
    private func getMaskContext() -> CGContext? {
        return CGContext(data: nil,
                        width: imageWidth,
                        height: imageHeight,
                        bitsPerComponent: 8,
                        bytesPerRow: imageWidth,
                        space: CGColorSpaceCreateDeviceGray(),
                        bitmapInfo: CGImageAlphaInfo.none.rawValue)
    }
    
    private func setContextTransform(context: CGContext) {
        if _picture.isFlipped {
            let flipVertical = CGAffineTransform(a: 1, b: 0, c: 0, d: -1, tx: 0, ty: CGFloat(context.height))
            context.concatenate(flipVertical)
        }
        let sketch = Sketch(picture: _picture)
        let scale = sketch.getScale(width: imageWidth, height: imageHeight)
        
        // set the picture in the middle of the view
        var deltax = CGFloat(context.width) - _picture.viewBox.width * scale
        var deltay = CGFloat(context.height) - _picture.viewBox.height * scale
        if deltax > deltay {
            deltax /= 2
            deltay = 0
        }
        else {
            deltax = 0
            deltay /= 2
        }
        
        deltax += -_picture.viewBox.minX * scale
        deltay += -_picture.viewBox.minY * scale
        
        context.translateBy(x: deltax, y: deltay)
        context.scaleBy(x: scale, y: scale)
    }
}


public extension Canvas {

    func reset() {
        if let context = _cgContext {
            let rect = CGRect(x: 0, y: 0, width: imageWidth, height: imageHeight)
            
            context.clear(rect)
            context.setFillColor(_viewMode.backgroundColor.cgColor)
            context.fill(rect)

            for stroke in _historyStrokes {
                makeStroke(context: context, rect: rect, stroke: stroke)
            }
        }
    }
    
    func startLine(start: CGPoint, color: CGColor, width lineWidth: CGFloat) {
        guard let context = _cgContext, let mask = _mask else { return }
        
        // restart a new stroke
        _currentStroke = nil
        
        if mask.isPointInBound(at: start) == false {
            return
        }
        
        let maskImage = mask.getImageMaskAtPoint(at: start)
        let rect = CGRect(x: 0, y: 0, width: imageWidth, height: imageHeight)
        
        let startPoint = flipVertical(position: start)
        let line = Line(start: startPoint, color: color, width: lineWidth)
        _currentStroke = Stroke(line: line, mask: maskImage, rect: rect)
        
        guard let stroke = _currentStroke else { return }
        _historyStrokes.append(stroke)
        makeStroke(context: context, rect: rect, stroke: stroke)
    }
    
    func lineTo(to: CGPoint) {
        guard let context = _cgContext, let stroke = _currentStroke else { return }
        
        let toPoint = flipVertical(position: to)
        stroke.line.lineTo(to: toPoint)
        
        context.addPath(stroke.line.lastSegment)
        context.strokePath()
    }
    
    func endLine(at: CGPoint?) {
        if let endPoint = at {
            lineTo(to: endPoint)
        }
        _currentStroke = nil
    }
    
    func clear() {
        _historyStrokes.removeAll()
        reset()
    }
    
    func undo() {
        if _historyStrokes.isEmpty == false {
            _historyStrokes.removeLast()
            reset()
        }
    }
    

    
    //this is to translate the coordinate of UIView to that of Quartz
    private func flipVertical(position: CGPoint) -> CGPoint {
        return CGPoint(x: position.x, y: CGFloat(self.imageHeight) - position.y)
    }
    
    private func makeStroke(context: CGContext, rect: CGRect, stroke: Stroke) {
        
        context.resetClip()
        if let mask = stroke.mask {
            context.clip(to: rect, mask: mask)
            //context.draw(mask, in: rect)
        }
        
        context.setStrokeColor(stroke.line.color)
        context.setLineWidth(stroke.line.width)
        context.setLineJoin(.round)
        context.setLineCap(.round)
        context.addPath(stroke.line.path)
        context.strokePath()
    }
    
}

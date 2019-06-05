//  Copyright © 2019 zscao. All rights reserved.

import Foundation
import UIKit

public class Canvas {
    
    private (set) var imageSize: CGSize
    
    private var _cgContext: CGContext?
    
    private var _currentStroke: Stroke?
    private var _historyStrokes: [Stroke] = [Stroke]()
    
    // the picture with scratch patterns/lines
    private var _scratch: BaseMap?
    
    public init(size: CGSize, baseMap picture: Picture) {
        imageSize = size
        _scratch = BaseMap(size: size, picture: picture)
        
        setupCGContext()
    }
    
    public func startLine(start: CGPoint, color: CGColor, width lineWidth: CGFloat) {
        
        guard let context = _cgContext, let scratch = _scratch else { return }
        
        // restart a new stroke
        _currentStroke = nil
        
        if scratch.isPointInBound(at: start) == false {
            return
        }
        
        let mask = scratch.getImageMaskAtPoint(at: start)
        let rect = CGRect(x: 0, y: 0, width: imageSize.width, height: imageSize.height)
        
        let startPoint = flipVertical(position: start)
        let line = Line(start: startPoint, color: color, width: lineWidth)
        _currentStroke = Stroke(line: line, mask: mask, rect: rect)
        
        guard let stroke = _currentStroke else { return }
        _historyStrokes.append(stroke)
        makeStroke(context: context, rect: rect, stroke: stroke)
    }
    
    public func lineTo(to: CGPoint) {
        guard let context = _cgContext, let stroke = _currentStroke else { return }
        
        let toPoint = flipVertical(position: to)
        stroke.line.lineTo(to: toPoint)
        
        context.addPath(stroke.line.lastSegment)
        context.strokePath()
    }
    
    public func endLine(at: CGPoint?) {
        if let endPoint = at {
            lineTo(to: endPoint)
        }
        _currentStroke = nil
    }
    
    public func clear() {
        _historyStrokes.removeAll()
        setupCGContext()
    }
    
    public func undo() {
        if _historyStrokes.isEmpty == false {
            _historyStrokes.removeLast()
        }
        setupCGContext()
    }
    
    public func getImage() -> CGImage? {
        guard let context = _cgContext else { return nil }
        let image = context.makeImage()
        
        return image
    }
    
    private func setupCGContext() {
        _currentStroke = nil
        _cgContext = nil
        
        _cgContext = CGContext(data: nil,
                               width: Int(imageSize.width),
                               height: Int(imageSize.height),
                               bitsPerComponent: 8,
                               bytesPerRow: 0,
                               space: CGColorSpaceCreateDeviceRGB(),
                               bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue)
        
        guard let context = _cgContext else { return }
        
        let rect = CGRect(x: 0, y: 0, width: imageSize.width, height: imageSize.height)
        
        if let scratch = _scratch, let scratchImage = scratch.image {
            context.draw(scratchImage, in: rect)
        }
        
        for stroke in _historyStrokes {
            makeStroke(context: context, rect: rect, stroke: stroke)
        }
    }
    
     //this is to translate the coordinate of UIView to that of Quartz
    private func flipVertical(position: CGPoint) -> CGPoint {
        return CGPoint(x: position.x, y: self.imageSize.height - position.y)
    }
    
//    private func translateSKScenePoistion(position: CGPoint) -> CGPoint {
//        return CGPoint(
//            x: position.x + self.imageSize.width / 2,
//            y: position.y + self.imageSize.height / 2)
//    }
    
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

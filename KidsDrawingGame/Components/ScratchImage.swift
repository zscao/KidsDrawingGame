//  Copyright © 2019 zscao. All rights reserved.

import UIKit

public class ScratchImage {
    
    private var imageWidth: Int = 0
    private var imageHeight: Int = 0
    
    private var viewMode: ViewMode
    
    public init(size: CGSize, viewMode: ViewMode) {
        imageWidth = Int(size.width)
        imageHeight = Int(size.height)
        
        self.viewMode = viewMode
    }
    
    public func getImage(picture: Picture) -> CGImage? {
        var ctx = CGContext(data: nil,
                            width: Int(imageWidth),
                            height: Int(imageHeight),
                            bitsPerComponent: 8,
                            bytesPerRow: 0,
                            space: CGColorSpaceCreateDeviceRGB(),
                            bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue)
        
        guard let context = ctx else { return nil }
        
        context.setFillColor(viewMode.backgroundColor.cgColor)
        context.fill(CGRect(x: 0, y: 0, width: imageWidth, height: imageHeight))
        
        context.setup(for: picture)
        
        let layer = getImageLayer(picture: picture) { layer in
            layer.strokeColor = viewMode.color.cgColor
            layer.lineWidth = 5
            layer.fillColor = UIColor.clear.cgColor
        }
        
        layer.render(in: context)
        let image = context.makeImage()
        ctx = nil
        return image
    }
    
    
    func getMaskImage(picture: Picture) -> CGImage? {
        var ctx = CGContext(data: nil,
                            width: imageWidth,
                            height: imageHeight,
                            bitsPerComponent: 8,
                            bytesPerRow: imageWidth,
                            space: CGColorSpaceCreateDeviceGray(),
                            bitmapInfo: CGImageAlphaInfo.none.rawValue)
        
        guard let context = ctx else { return nil }
        context.setup(for: picture)
        
        let layer = getImageLayer(picture: picture) { layer in
            layer.strokeColor = UIColor.white.cgColor
            layer.lineWidth = 3
            layer.fillColor = UIColor.clear.cgColor
        }
        
        layer.render(in: context)
        let image = context.makeImage()
        ctx = nil
        return image
    }
    
    private func getImageLayer(picture: Picture, _ setupLayer : (_ layer: CAShapeLayer) -> Void) -> CALayer {
        let rootLayer = CALayer()
        rootLayer.bounds = picture.viewBox
        
        for path in picture.paths {
            let layer = CAShapeLayer()
            layer.bounds = rootLayer.bounds
            layer.path = path
            
            setupLayer(layer)
            
            rootLayer.addSublayer(layer)
        }
        return rootLayer
    }
}


fileprivate extension CGContext {
    
    func setup(for picture: Picture) {
        if picture.isFlipped {
            let flipVertical = CGAffineTransform(a: 1, b: 0, c: 0, d: -1, tx: 0, ty: CGFloat(self.height))
            self.concatenate(flipVertical)
        }
        let scale = getScaleForPicture(pictureSize: picture.viewBox.size)
        self.translateBy(x: CGFloat(self.width) / 2, y: CGFloat(self.height) / 2)
        self.scaleBy(x: scale, y: scale)
    }
    
    private func getScaleForPicture(pictureSize: CGSize) -> CGFloat {
        
        if pictureSize.width == 0 || pictureSize.height == 0 {
            return 1.0
        }
        
        let scalex = CGFloat(self.width) / pictureSize.width
        let scaley = CGFloat(self.height) / pictureSize.height
        
        return scalex < scaley ? scalex : scaley
    }
    
    // set the picture in the center of the screen
//    private func getTranslateForPicture(pictureBounds position: CGRect) -> CGPoint {
//        if position.origin == .zero {
//            return position.origin
//        }
//
//        var deltax = -position.minX
//        var deltay = -position.minY
//
//        let scale = getScaleForPicture(pictureSize: position.size)
//        let spanx = CGFloat(self.width) - position.width * scale
//        let spany = CGFloat(self.height) - position.height * scale
//
//        if spanx > spany {
//            deltax += spanx / 2
//        }
//        else {
//            deltay += spany / 2
//        }
//
//        return CGPoint(x: deltax, y: deltay)
//    }
}

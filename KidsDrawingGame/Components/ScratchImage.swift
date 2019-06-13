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
        
        context.setup(picture: picture)
        
        context.setStrokeColor(viewMode.color.cgColor)
        context.strokePath()
        
        // create an image mask
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
        
        context.setup(picture: picture)
        
        context.setStrokeColor(UIColor.white.cgColor)
        context.strokePath()
        
        // create an image mask
        let image = context.makeImage()
        ctx = nil
        return image
    }
}


fileprivate extension CGContext {
    
    func setup(picture: Picture) {
        if picture.isFlipped {
            let flipVertical = CGAffineTransform(a: 1, b: 0, c: 0, d: -1, tx: 0, ty: CGFloat(self.height))
            self.concatenate(flipVertical)
        }
        
        let scale = getScaleForPicture(pictureSize: picture.viewBox.size)
        let translate = getTranslateForPicture(pictureBounds: picture.viewBox)
        self.setLineWidth(4)
        self.scaleBy(x: scale, y: scale)
        self.translateBy(x: translate.x, y: translate.y)
        
        
        for path in picture.paths {
            self.addPath(path)
        }
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
    private func getTranslateForPicture(pictureBounds position: CGRect) -> CGPoint {
        if position.origin == .zero {
            return position.origin
        }
        
        var deltax = -position.minX
        var deltay = -position.minY
        
        let scale = getScaleForPicture(pictureSize: position.size)
        let spanx = CGFloat(self.width) - position.width * scale
        let spany = CGFloat(self.height) - position.height * scale
        
        if spanx > spany {
            deltax += spanx / 2
        }
        else {
            deltay += spany / 2
        }
        
        return CGPoint(x: deltax, y: deltay)
    }
}

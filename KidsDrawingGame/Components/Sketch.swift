//  Copyright © 2019 zscao. All rights reserved.

import UIKit

public class Sketch {
    
    private var _picture: Picture
    
    public init(picture: Picture) {
        _picture = picture
    }
    
    public func getScale(width: Int, height: Int) -> CGFloat {
        return getScale(size: CGSize(width: width, height: height))
    }
    
    public func getScale(size: CGSize) -> CGFloat {
        
        let pictureSize = _picture.viewBox.size
        if pictureSize.width == 0 || pictureSize.height == 0 {
            return 1.0
        }
        
        let scalex = size.width / pictureSize.width
        let scaley = size.height / pictureSize.height
        
        return scalex < scaley ? scalex : scaley
    }
    
    public func getSketchLayer(strokeColor: CGColor, lineWidth: CGFloat) -> CALayer {
        let rootLayer = CALayer()
        rootLayer.bounds = _picture.viewBox
        
        for path in _picture.paths {
            let layer = CAShapeLayer()
            layer.strokeColor = strokeColor
            layer.lineWidth = lineWidth
            layer.lineCap = .round
            layer.lineJoin = .round
            layer.fillColor = UIColor.clear.cgColor
            
            layer.path = path
            
            rootLayer.addSublayer(layer)
        }
        return rootLayer
    }
}

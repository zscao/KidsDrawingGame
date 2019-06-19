//  Copyright © 2019 zscao. All rights reserved.

import UIKit

class MaskFinderLinearFill: MaskFinder {
    
    override func getMaskImageData(at point: CGPoint) -> UnsafeMutablePointer<UInt8> {
        let imageData: UnsafeMutablePointer<UInt8> = allocateImageData()
        
        guard let data = _image.dataProvider?.data else { return imageData }
        let pixelData: UnsafePointer<UInt8> = CFDataGetBytePtr(data)
        
        var x = Int(point.x),
        y = Int(point.y)
        
        let originalColor = getPixelColor(x: x, y: y, from: pixelData)
        
        
        
        let stack = Stack<LineData>()
        stack.push(data: LineData(x1: x, x2: x, y: y-1, dy: 1))
        
        while var line = stack.pop() {
            line.y += line.dy
            
            if line.y < 0 || line.y >= _image.height { continue }
            
            x = line.x1
            while x >= 0 {
                let imageColor = getPixelColor(x: x, y: line.y, from: imageData)
                if imageColor == _maskColor { break }
                
                let pixelColor = getPixelColor(x: x, y: line.y, from: pixelData)
                if pixelColor != originalColor { break }
                
                setPixelColor(x: x, y: line.y, color: _maskColor, to: imageData)
                
                x -= 1
            }
            
            var left = x < line.x1 ? x + 1 : -1
            
            x = line.x1 + 1
            while x < _image.width {
                if getPixelColor(x: x, y: line.y, from: imageData) == _maskColor {
                    while x <= line.x2 && getPixelColor(x: x, y: line.y, from: imageData) == _maskColor {
                        x += 1
                    }
                }
                
                let pixelColor = getPixelColor(x: x, y: line.y, from: pixelData)
                if pixelColor == originalColor {
                    setPixelColor(x: x, y: line.y, color: _maskColor, to: imageData)
                    if left < 0 {
                        left = x
                    }
                    else if x == _image.width - 1 {
                        stack.push(data: LineData(x1: left, x2: x, y: line.y, dy: line.dy))
                        if left < line.x1 || x > line.x2 {
                            stack.push(data: LineData(x1: left, x2: x, y: line.y, dy: -line.dy))
                        }
                    }
                }
                else {
                    if left >= 0 {
                        stack.push(data: LineData(x1: left, x2: x, y: line.y, dy: line.dy))
                        
                        if left < line.x1 || x > line.x2 {
                            stack.push(data: LineData(x1: left, x2: x, y: line.y, dy: -line.dy))
                        }
                        
                        left = -1
                    }
                    
                    if x >= line.x2 { break }
                }
                x += 1
            }
            
        }
        
        return imageData
    }
}

struct LineData {
    var x1: Int
    var x2: Int
    var y: Int
    var dy: Int
}


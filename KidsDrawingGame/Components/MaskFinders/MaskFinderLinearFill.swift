//  Copyright © 2019 zscao. All rights reserved.

import UIKit

class MaskFinderLinearFill: MaskFinder {
    
    override func getMaskImageData(at point: CGPoint) -> UnsafeMutablePointer<UInt8> {
        
        #if DEBUG
        print("")
        print("start getting image data")
        let start0 = DispatchTime.now()
        #endif
        
        let imageData: UnsafeMutablePointer<UInt8> = allocateImageData()
        
        #if DEBUG
        let end01 = DispatchTime.now()
        let elapse01 = (end01.uptimeNanoseconds - start0.uptimeNanoseconds) / 1_000_000
        print("allocate image data: \(elapse01)")
        #endif
        
        guard let data = _image.dataProvider?.data else { return imageData }
        let pixelData: UnsafePointer<UInt8> = CFDataGetBytePtr(data)
        
        var x = Int(point.x),
        y = Int(point.y)
        
        let originalColor = getPixelColor(x: x, y: y, from: pixelData)
        
        let stack = Stack<LineData>()
        stack.push(data: LineData(x1: x, x2: x, y: y-1, dy: 1))
        
        
        #if DEBUG
        var minX: Int = _image.width,
        minY: Int = _image.height,
        maxX: Int = 0,
        maxY: Int = 0
        
        var loopCount = 0
        let start = DispatchTime.now()
        #endif
        
        while var line = stack.pop() {
            
            loopCount += 1
            
            line.y += line.dy
            
            #if DEBUG
            if line.x1 < minX { minX = line.x1 }
            if line.x2 > maxX { maxX = line.x2 }
            if line.y < minY { minY = line.y}
            if line.y > maxY { maxY = line.y}
            #endif
            
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
                        
                        // need to across at least 2 pixels to reach another block
                        if left < line.x1 - 1 || x > line.x2 + 1 {
                            stack.push(data: LineData(x1: left, x2: x, y: line.y, dy: -line.dy))
                        }
                    }
                }
                else {
                    if left >= 0 {
                        stack.push(data: LineData(x1: left, x2: x, y: line.y, dy: line.dy))
                        
                        // need to cross at least 2 pixels to reach another block
                        if left < line.x1 - 1 || x > line.x2 + 1 {
                            stack.push(data: LineData(x1: left, x2: x, y: line.y, dy: -line.dy))
                        }
                        
                        left = -1
                    }
                    
                    if x >= line.x2 { break }
                }
                x += 1
            }
            
        }
        
        #if DEBUG
        
        let end = DispatchTime.now()
        let elapsed = (end.uptimeNanoseconds - start.uptimeNanoseconds) / 1_000_000 // elapsed time in million seconds
        print("loop time: " + String(elapsed))
        
        print(String("minX: \(minX), minY: \(minY), maxX: \(maxX), maxY: \(maxY)"))
        let width = maxX - minX
        let height = maxY - minY
        print(String("width: \(width), height: \(height)"))
        if height > 0 {
            print("repeated lines: \(Float(loopCount) / Float(height))")
        }
        
        print(String("loop count: \(loopCount)"))
        print("")
        #endif
        
        return imageData
    }
}

struct LineData {
    var x1: Int
    var x2: Int
    var y: Int
    var dy: Int
}


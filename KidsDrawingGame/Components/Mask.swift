//  Copyright © 2019 zscao. All rights reserved.

import UIKit

class Mask {
    private var _picture: Picture
    
    private var _maskImage: CGImage?
    private var _maskHistory: [CGImage] = [CGImage]()
    
    private let _maskColorValue: UInt8 = 0xff
    private var imageWidth: Int = 0
    private var imageHeight: Int = 0
    
    init(size: CGSize, picture: Picture) {
        imageWidth = Int(size.width)
        imageHeight = Int(size.height)
        
        _picture = picture
        
        _maskImage = getMaskImage()
    }
    
    private func getMaskImage() -> CGImage? {
        if let context = getMaskContext() {
            setContextTransform(context: context)
            
            let sketch = Sketch(picture: _picture)
            let scale = sketch.getScale(width: imageWidth, height: imageHeight)
            var lineWidth = SketchLineWidth
            if lineWidth > 3 { lineWidth = (lineWidth - 2) / scale }
            let layer = sketch.getSketchLayer(strokeColor: UIColor.white.cgColor, lineWidth: lineWidth)
            
            layer.render(in: context)
            return context.makeImage()
        }
        return nil
    }
    
    private func getMaskContext() -> CGContext? {
        if let context = CGContext(data: nil,
                         width: imageWidth,
                         height: imageHeight,
                         bitsPerComponent: 8,
                         bytesPerRow: imageWidth,
                         space: CGColorSpaceCreateDeviceGray(),
                         bitmapInfo: CGImageAlphaInfo.none.rawValue) {
            context.setShouldAntialias(true)
            return context
        }
        return nil
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
    
extension Mask: Masking {
    
    func isPointInBound(at position: CGPoint) -> Bool {
        guard let maskImage = _maskImage else { return false }
        
        if let pixelData = maskImage.dataProvider?.data {
            let data: UnsafePointer<UInt8> = CFDataGetBytePtr(pixelData)
            
            let pixelInfo: Int = maskImage.width * Int(position.y) + Int(position.x)
            let colorData = data[pixelInfo]
            
            return colorData == 0 // the color of the point is black so it must not be on the boundary but within it
        }
        return false
    }
    
    func getImageMaskAtPoint(at position: CGPoint) -> CGImage? {
        if let mask = findImageMaskAtPointInHistory(at: position) {
            return mask
        }
        
        return findImageMaskAtPoint(at: position)
    }
    
    
    private func findImageMaskAtPointInHistory(at position: CGPoint) -> CGImage? {
        if _maskHistory.isEmpty { return nil }
        
        for mask in _maskHistory {
            guard let pixelData = mask.dataProvider?.data else { continue }
            
            let data8: UnsafePointer<UInt8> = CFDataGetBytePtr(pixelData)
            let startPoint = PixelPoint(x: Int(position.x), y: Int(position.y))
            let startPosition: Int = imageWidth * startPoint.y + startPoint.x
            
            // mask areas are never overlapped, so if a pixel with the mask color can be found in a mask image, then the image must be the right one
            if data8[startPosition] == _maskColorValue {
                return mask
            }
        }
        
        return nil
    }
    
    private func findImageMaskAtPoint(at position: CGPoint) -> CGImage? {
        
        guard let pixelData = _maskImage?.dataProvider?.data else { return nil }
        
        let data8: UnsafePointer<UInt8> = CFDataGetBytePtr(pixelData)
        
        // used to save the image data
        let imageData: UnsafeMutablePointer<UInt8> = allocateUnsafeMutablePointer(width: imageWidth, height: imageHeight, initialValue: 0)
        // used to save the check status of each pixel
        let checkData: UnsafeMutablePointer<Bool> = allocateUnsafeMutablePointer(width: imageWidth, height: imageHeight, initialValue: false)
        
        let startPoint = PixelPoint(x: Int(position.x), y: Int(position.y))
        let startPosition: Int = imageWidth * startPoint.y + startPoint.x
        let originColorData = data8[startPosition]
        //let originColorData: ColorData = ColorData.FromUnsafeUInt8(data: data8, position: startPosition)
        
        let queue = Queue<PixelPoint>()
        queue.enqueue(startPoint)
        checkData[startPosition] = true
        
        while let currentPoint = queue.dequeue() {
            let currentPosition = currentPoint.y * imageWidth + currentPoint.x
            
            // set image color
            imageData[currentPosition] = _maskColorValue
            
            // check nearby 4 pixels
            // 1. right side
            if currentPoint.x < imageWidth - 1 {
                let nextPoint = PixelPoint(x: currentPoint.x + 1, y: currentPoint.y)
                let nextPosition = nextPoint.y * imageWidth + nextPoint.x
                
                if checkData[nextPosition] == false {
                    checkData[nextPosition] = true
                    
                    let nextColorData = data8[nextPosition]
                    if nextColorData == originColorData {
                        queue.enqueue(nextPoint)
                    }
                }
            }
            // down side
            if currentPoint.y < imageHeight - 1 {
                let nextPoint = PixelPoint(x: currentPoint.x, y: currentPoint.y + 1)
                let nextPosition = nextPoint.y * imageWidth + nextPoint.x
                
                if checkData[nextPosition] == false {
                    checkData[nextPosition] = true
                    let nextColorData = data8[nextPosition]
                    if nextColorData == originColorData {
                        queue.enqueue(nextPoint)
                    }
                }
            }
            // left side
            if currentPoint.x > 0 {
                let nextPoint = PixelPoint(x: currentPoint.x - 1, y: currentPoint.y)
                let nextPosition = nextPoint.y * imageWidth + nextPoint.x
                
                if checkData[nextPosition] == false {
                    checkData[nextPosition] = true
                    let nextColorData = data8[nextPosition]
                    if nextColorData == originColorData {
                        queue.enqueue(nextPoint)
                    }
                }
            }
            // up side
            if currentPoint.y > 0 {
                let nextPoint = PixelPoint(x: currentPoint.x, y: currentPoint.y - 1)
                let nextPosition = nextPoint.y * imageWidth + nextPoint.x
                
                if checkData[nextPosition] == false {
                    checkData[nextPosition] = true
                    let nextColorData = data8[nextPosition]
                    if nextColorData == originColorData {
                        queue.enqueue(nextPoint)
                    }
                }
            }
        }
        
        let bitmapContext = CGContext(data: imageData,
                                      width: imageWidth,
                                      height: imageHeight,
                                      bitsPerComponent: 8,
                                      bytesPerRow: imageWidth,
                                      space: CGColorSpaceCreateDeviceGray(),
                                      bitmapInfo: CGImageAlphaInfo.none.rawValue)
        
        let result = bitmapContext?.makeImage()
        
        //imageData.deallocate()
        imageData.deallocate()
        checkData.deallocate()
        
        if result != nil {
            _maskHistory.append(result!)
        }
        return result
    }
    
    private func allocateUnsafeMutablePointer<T>(width: Int, height: Int, initialValue: T) -> UnsafeMutablePointer<T> {
        
        let data = UnsafeMutablePointer<T>.allocate(capacity: width * height)
        
        // clear the momery
        for x in 0 ..< width {
            for y in 0 ..< height {
                let p = y * width + x
                (data + p).initialize(to: initialValue)
            }
        }
        return data
    }
}

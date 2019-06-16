//  Copyright © 2019 zscao. All rights reserved.

import UIKit

class Mask {
    private var _maskImage: CGImage
    private var _maskHistory: [CGImage] = [CGImage]()
    
    private let _maskColorValue: UInt8 = 0xff
    
    init(image: CGImage) {
        _maskImage = image
    }
    
    func isPointInBound(at position: CGPoint) -> Bool {
        if let pixelData = _maskImage.dataProvider?.data {
            let data: UnsafePointer<UInt8> = CFDataGetBytePtr(pixelData)
            
            let pixelInfo: Int = _maskImage.width * Int(position.y) + Int(position.x)
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
            let startPosition: Int = _maskImage.width * startPoint.y + startPoint.x
            
            // mask areas are never overlapped, so if a pixel with the mask color can be found in a mask image, then the image must be the right one
            if data8[startPosition] == _maskColorValue {
                return mask
            }
        }
        
        return nil
    }
    
    private func findImageMaskAtPoint(at position: CGPoint) -> CGImage? {
        
        guard let pixelData = _maskImage.dataProvider?.data else { return nil }
        
        let data8: UnsafePointer<UInt8> = CFDataGetBytePtr(pixelData)
        
        // used to save the image data
        let imageData: UnsafeMutablePointer<UInt8> = allocateUnsafeMutablePointer(width: _maskImage.width, height: _maskImage.height, initialValue: 0)
        // used to save the check status of each pixel
        let checkData: UnsafeMutablePointer<Bool> = allocateUnsafeMutablePointer(width: _maskImage.width, height: _maskImage.height, initialValue: false)
        
        let startPoint = PixelPoint(x: Int(position.x), y: Int(position.y))
        let startPosition: Int = _maskImage.width * startPoint.y + startPoint.x
        let originColorData = data8[startPosition]
        //let originColorData: ColorData = ColorData.FromUnsafeUInt8(data: data8, position: startPosition)
        
        let queue = Queue<PixelPoint>()
        queue.enqueue(startPoint)
        checkData[startPosition] = true
        
        while let currentPoint = queue.dequeue() {
            let currentPosition = currentPoint.y * _maskImage.width + currentPoint.x
            
            // set image color
            imageData[currentPosition] = _maskColorValue
            
            // check nearby 4 pixels
            // 1. right side
            if currentPoint.x < _maskImage.width - 1 {
                let nextPoint = PixelPoint(x: currentPoint.x + 1, y: currentPoint.y)
                let nextPosition = nextPoint.y * _maskImage.width + nextPoint.x
                
                if checkData[nextPosition] == false {
                    checkData[nextPosition] = true
                    
                    let nextColorData = data8[nextPosition]
                    if nextColorData == originColorData {
                        queue.enqueue(nextPoint)
                    }
                }
            }
            // down side
            if currentPoint.y < _maskImage.height - 1 {
                let nextPoint = PixelPoint(x: currentPoint.x, y: currentPoint.y + 1)
                let nextPosition = nextPoint.y * _maskImage.width + nextPoint.x
                
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
                let nextPosition = nextPoint.y * _maskImage.width + nextPoint.x
                
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
                let nextPosition = nextPoint.y * _maskImage.width + nextPoint.x
                
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
                                      width: _maskImage.width,
                                      height: _maskImage.height,
                                      bitsPerComponent: 8,
                                      bytesPerRow: _maskImage.width,
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

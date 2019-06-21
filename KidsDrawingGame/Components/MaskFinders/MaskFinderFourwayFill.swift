//  Copyright © 2019 zscao. All rights reserved.

import UIKit

/*
class MaskFinderFourwayFill: MaskFinder {
    
    override func getMaskImageData(at point: CGPoint) -> UnsafeMutablePointer<UInt8> {
        // used to save the image data
        let imageData: UnsafeMutablePointer<UInt8> = allocateImageData()
        
        guard let pixelData = _image.dataProvider?.data else { return imageData }
        let data8: UnsafePointer<UInt8> = CFDataGetBytePtr(pixelData)

        // used to save the check status of each pixel
        let checkData: UnsafeMutablePointer<Bool> = allocateUnsafeMutablePointer(width: _image.width, height: _image.height, initialValue: false)
        
        let startPoint = PixelPoint(x: Int(point.x), y: Int(point.y))
        let startPosition: Int = _image.width * startPoint.y + startPoint.x
        let originColorData = data8[startPosition]
        //let originColorData: ColorData = ColorData.FromUnsafeUInt8(data: data8, position: startPosition)
        
        let queue = Queue<PixelPoint>()
        queue.enqueue(startPoint)
        checkData[startPosition] = true
        
        while let currentPoint = queue.dequeue() {
            let currentPosition = currentPoint.y * _image.width + currentPoint.x
            
            // set image color
            imageData[currentPosition] = _maskColor
            
            // check nearby 4 pixels
            // 1. right side
            if currentPoint.x < _image.width - 1 {
                let nextPoint = PixelPoint(x: currentPoint.x + 1, y: currentPoint.y)
                let nextPosition = nextPoint.y * _image.width + nextPoint.x
                
                if checkData[nextPosition] == false {
                    checkData[nextPosition] = true
                    
                    let nextColorData = data8[nextPosition]
                    if nextColorData == originColorData {
                        queue.enqueue(nextPoint)
                    }
                }
            }
            // down side
            if currentPoint.y < _image.height - 1 {
                let nextPoint = PixelPoint(x: currentPoint.x, y: currentPoint.y + 1)
                let nextPosition = nextPoint.y * _image.width + nextPoint.x
                
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
                let nextPosition = nextPoint.y * _image.width + nextPoint.x
                
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
                let nextPosition = nextPoint.y * _image.width + nextPoint.x
                
                if checkData[nextPosition] == false {
                    checkData[nextPosition] = true
                    let nextColorData = data8[nextPosition]
                    if nextColorData == originColorData {
                        queue.enqueue(nextPoint)
                    }
                }
            }
        }

        checkData.deallocate()
        return imageData
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

 */

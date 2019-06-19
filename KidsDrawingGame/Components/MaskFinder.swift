//  Copyright © 2019 zscao. All rights reserved.

import UIKit

class MaskFinder {
    
    let _image: CGImage
    let _maskColor: UInt8
    
    init(image: CGImage, maskColor: UInt8) {
        _image = image
        _maskColor = maskColor
    }
    
    func findMaskImage(at point: CGPoint) -> CGImage? {
        
        let imageData = getMaskImageData(at: point)
        
        let image = createImage(data: imageData)
        imageData.deallocate()
        
        return image
    }
    
    func getMaskImageData(at point: CGPoint) -> UnsafeMutablePointer<UInt8> {
        let imageData: UnsafeMutablePointer<UInt8> = allocateImageData()
        return imageData
    }
    
    func getPixelColor(x: Int, y: Int, from data: UnsafePointer<UInt8>) -> UInt8 {
        let index = y * _image.width + x
        return data[index]
    }
    
    func setPixelColor(x: Int, y: Int, color: UInt8, to data: UnsafeMutablePointer<UInt8>) {
        let index = y * _image.width + x
        data[index] = color
    }
    
    func allocateImageData() -> UnsafeMutablePointer<UInt8> {
        
        let data = UnsafeMutablePointer<UInt8>.allocate(capacity: _image.width * _image.height)
        
        // clear the momery
        for x in 0 ..< _image.width {
            for y in 0 ..< _image.height {
                let p = y * _image.width + x
                (data + p).initialize(to: 0)
            }
        }
        return data
    }
    
    private func createImage(data: UnsafeMutableRawPointer) -> CGImage? {
        if let context = CGContext(data: data,
                                   width: _image.width,
                                   height: _image.height,
                                   bitsPerComponent: 8,
                                   bytesPerRow: _image.width,
                                   space: CGColorSpaceCreateDeviceGray(),
                                   bitmapInfo: CGImageAlphaInfo.none.rawValue) {
            return context.makeImage()
        }
        
        return nil
    }
    
}



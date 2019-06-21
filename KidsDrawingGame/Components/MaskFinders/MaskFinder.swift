//  Copyright © 2019 zscao. All rights reserved.

import UIKit

class MaskFinder {
    
    let _image: CGImage
    let _maskColor: UInt8
    
    init(image: CGImage, maskColor: UInt8) {
        _image = image
        _maskColor = maskColor
    }
    
    func findMaskImage(at point: CGPoint) -> MaskImage? {
        
        guard let imageData = getMaskImageData(at: point) else { return nil }
        
        if let image = createImage(data: imageData.data, size: imageData.rect.size) {
            return MaskImage(image: image, rect: imageData.rect)
        }
        return nil
    }
    
    func getMaskImageData(at point: CGPoint) -> MaskImageData? {
        let data = UnsafeMutablePointer<UInt8>.allocate(capacity: 0)
        return MaskImageData(data: data, rect: .zero)
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
        
        let capacity = _image.width * _image.height
        let data = UnsafeMutablePointer<UInt8>.allocate(capacity: capacity)
        
        data.initialize(repeating: 0, count: capacity)

        return data
    }
    
    private func createImage(data: UnsafeMutableRawPointer, size: CGSize) -> CGImage? {
        if let context = CGContext(data: data,
                                   width: Int(size.width),
                                   height: Int(size.height),
                                   bitsPerComponent: 8,
                                   bytesPerRow: Int(size.width),
                                   space: CGColorSpaceCreateDeviceGray(),
                                   bitmapInfo: CGImageAlphaInfo.none.rawValue) {
            return context.makeImage()
        }
        
        return nil
    }
    
}


class MaskImageData {
    var data: UnsafeMutablePointer<UInt8>
    var rect: CGRect
    
    init(data: UnsafeMutablePointer<UInt8>, rect: CGRect) {
        self.data = data
        self.rect = rect
    }
    
    deinit {
        #if DEBUG
        print("dealloating mask image data")
        #endif
        
        data.deallocate()
    }
}

struct MaskImage {
    var image: CGImage
    var rect: CGRect
}

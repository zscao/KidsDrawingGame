//  Copyright © 2019 zscao. All rights reserved.

import Foundation
import UIKit

class BaseMap {
    
    private (set) var imageWidth: Int
    private (set) var imageHeight: Int
    private (set) var image: CGImage?
    private (set) var viewMode: ViewMode
    
    private var _maskImage: CGImage?
    private var _maskHistory: [CGImage] = [CGImage]()
    
    private let _lineWidth: CGFloat = 10
    private let _maskColorValue: UInt8 = 0xff
    
    private var _flipVertical: CGAffineTransform!
    
    init(size: CGSize, picture: Picture, viewMode: ViewMode) {
        self.imageWidth = Int(size.width)
        self.imageHeight = Int(size.height)
        self.viewMode = viewMode
        _flipVertical = CGAffineTransform(a: 1, b: 0, c: 0, d: -1, tx: 0, ty: size.height);
        
        image = createImage(picture: picture)
        _maskImage = setupMaskImage(picture: picture)
    }
    
    func isPointInBound(at position: CGPoint) -> Bool {
        if let pixelData = _maskImage?.dataProvider?.data {
            let data: UnsafePointer<UInt8> = CFDataGetBytePtr(pixelData)
            
            let pixelInfo: Int = imageWidth * Int(position.y) + Int(position.x)
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
    
    
    private func createImage(picture: Picture) -> CGImage? {
        let ctx = CGContext(data: nil,
                            width: imageWidth,
                            height: imageHeight,
                            bitsPerComponent: 8,
                            bytesPerRow: 0,
                            space: CGColorSpaceCreateDeviceRGB(),
                            bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue)
        
        guard let context = ctx else { return nil }
        
        context.setFillColor(viewMode.backgroundColor.cgColor)
        context.fill(CGRect(x: 0, y: 0, width: imageWidth, height: imageHeight))
        
        if picture.isFlipped {
            context.concatenate(_flipVertical)
        }
        
        let translate = getTranslateForPicture(pictureSize: picture.size)
        let scale = getScaleForPicture(pictureSize: picture.size)
        context.translateBy(x: translate.x, y: translate.y)
        context.scaleBy(x: scale, y: scale)
        
        for path in picture.paths {
            context.addPath(path)
        }
        context.setStrokeColor(viewMode.color.cgColor)
        context.setLineWidth(_lineWidth)
        context.strokePath()
        
        // create an image mask
        return context.makeImage()
    }
    
    private func setupMaskImage(picture: Picture) -> CGImage? {
        let ctx = CGContext(data: nil,
                            width: imageWidth,
                            height: imageHeight,
                            bitsPerComponent: 8,
                            bytesPerRow: imageWidth,
                            space: CGColorSpaceCreateDeviceGray(),
                            bitmapInfo: CGImageAlphaInfo.none.rawValue)
        
        guard let context = ctx else { return nil }
        
        if picture.isFlipped {
            context.concatenate(_flipVertical)
        }
        
        let translate = getTranslateForPicture(pictureSize: picture.size)
        let scale = getScaleForPicture(pictureSize: picture.size)
        
        context.translateBy(x: translate.x, y: translate.y)
        context.scaleBy(x: scale, y: scale)
        
        //        for path in picture.paths {
        //            context.addPath(path)
        //        }
        //        context.setFillColor(UIColor.white.cgColor)
        //        context.fillPath(using: .evenOdd)
        
        // draw
        for path in picture.paths {
            context.addPath(path)
        }
        context.setStrokeColor(UIColor.white.cgColor)
        context.setLineWidth(_lineWidth - 2)
        context.strokePath()
        
        // create an image mask
        return context.makeImage()
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
    
    private func getScaleForPicture(pictureSize: CGSize) -> CGFloat {
        
        if pictureSize.width == 0 || pictureSize.height == 0 {
            return 1.0
        }
        
        let scalex = CGFloat(imageWidth) / pictureSize.width
        let scaley = CGFloat(imageHeight) / pictureSize.height
        
        return scalex < scaley ? scalex : scaley
    }
    
    // set the picture in the center of the screen
    private func getTranslateForPicture(pictureSize: CGSize) -> CGPoint {
        if pictureSize.width == 0 || pictureSize.height == 0 {
            return CGPoint(x: 0, y: 0)
        }
        
        let scalex = CGFloat(imageWidth) / pictureSize.width
        let scaley = CGFloat(imageHeight) / pictureSize.height
        
        if scalex < scaley {
            let height = pictureSize.height * scalex
            let span = CGFloat(imageHeight) - height
            return CGPoint(x: 0, y: span / 2)
        }
        else {
            let width = pictureSize.width * scaley
            let span = CGFloat(imageWidth) - width
            return CGPoint(x: span / 2, y: 0)
        }
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

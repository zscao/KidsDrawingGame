//  Copyright © 2019 zscao. All rights reserved.

import UIKit

class ImageMask {

    private let maskColor: UInt8 = 0xff
    
    private let imageWidth: Int
    private let imageHeight: Int
    private let _picture: Picture
    
    private var _image: CGImage?
    private var _masks = [MaskImage]()
    
    init(size: CGSize, picture: Picture) {
        imageWidth = Int(size.width)
        imageHeight = Int(size.height)
        _picture = picture
        
        _image = getMaskImage()
    }
    
    private func getMaskImage() -> CGImage? {
        if let context = getMaskContext() {
            
            let sketch = Sketch(picture: _picture)
            let scale = sketch.getScale(width: imageWidth, height: imageHeight)
            let layer = sketch.getSketchLayer(strokeColor: UIColor.white.cgColor, lineWidth: SketchLineWidth / scale)
            
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
            
//            if _picture.isFlipped {
//                let flipVertical = CGAffineTransform(a: 1, b: 0, c: 0, d: -1, tx: 0, ty: CGFloat(context.height))
//                context.concatenate(flipVertical)
//            }
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
            
            return context
        }
        return nil
    }
    

}

extension ImageMask: Masking {
    func preloadMasks() {
        //let store = MaskImageStore(id: "test")
        let masks = MaskImageStore(id: _picture.name).loadMaskImages()
        for mask in masks {
            _masks.append(mask)
        }
        
        // prefill the mask with the background area as it usually take more time to generate
        if let image = _image {
            let _ = getMaskImageAtPoint(at: CGPoint(x: 0, y: 0))
            let _ = getMaskImageAtPoint(at: CGPoint(x: 0, y: image.height - 1))
            let _ = getMaskImageAtPoint(at: CGPoint(x: image.width - 1, y: 0))
            let _ = getMaskImageAtPoint(at: CGPoint(x: image.width - 1, y: image.height - 1))
        }
    }
    
    func isPointInBound(at position: CGPoint) -> Bool {
        guard let maskImage = _image else { return false }
        
        if let pixelData = maskImage.dataProvider?.data {
            let data: UnsafePointer<UInt8> = CFDataGetBytePtr(pixelData)
            
            let pixelInfo: Int = maskImage.width * Int(position.y) + Int(position.x)
            let colorData = data[pixelInfo]
            
            return colorData == 0 // the color of the point is black so it must not be on the boundary but within it
        }
        return false
    }
    
    func getMaskImageAtPoint(at position: CGPoint) -> MaskImage? {
        if let mask = findMaskImageAtPointInHistory(at: position) {
            return mask
        }
        
        if let image = _image {
            
            let start = DispatchTime.now()
            
            let finder = MaskFinderQuickFill(image: image, maskColor: maskColor)
            //let finder = MaskFinderLinearFill(image: image, maskColor: maskColor)
            //let finder = MaskFinderFourwayFill(image: image, maskColor: maskColor)
            
            if let mask = finder.findMaskImage(at: position) {
                let end = DispatchTime.now()
                let elapsed = (end.uptimeNanoseconds - start.uptimeNanoseconds) / 1_000_000 // elapsed time in million seconds
                print("Elapsed time: " + String(elapsed))
                
                _masks.append(mask)
                
                // save the mask image
                let storeName = _picture.name
                DispatchQueue.global(qos: .background).async {
                    let store = MaskImageStore(id: storeName)
                    store.saveMaskImage(mask: mask)
                }
                
                return mask
            }
        }
        return nil
    }
    
    private func findMaskImageAtPointInHistory(at position: CGPoint) -> MaskImage? {
        if _masks.isEmpty { return nil }
        
        let x = position.x
        let y = position.y
        
        for mask in _masks {
            if x < mask.rect.minX || x > mask.rect.maxX || y < mask.rect.minY || y > mask.rect.maxY { continue }
            
            guard let pixelData = mask.image.dataProvider?.data else { continue }
            let data8: UnsafePointer<UInt8> = CFDataGetBytePtr(pixelData)
            
            let rx = Int(x - mask.rect.minX)
            let ry = Int(y - mask.rect.minY)
            
            let startPosition: Int = Int(mask.rect.width) * ry + rx
            
            // mask areas are never overlapped, so if a pixel with the mask color can be found in a mask image, then the image must be the right one
            if data8[startPosition] == maskColor {
                return mask
            }
        }
        
        return nil
    }
}

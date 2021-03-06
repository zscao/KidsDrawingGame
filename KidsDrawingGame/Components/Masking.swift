//  Copyright © 2019 zscao. All rights reserved.

import Foundation

protocol Masking {
    
    func preloadMasks()
    
    func isPointInBound(at position: CGPoint) -> Bool
    
    func getMaskImageAtPoint(at position: CGPoint) -> MaskImage?
}

//  Copyright © 2019 zscao. All rights reserved.

import Foundation

protocol Masking {
    func isPointInBound(at position: CGPoint) -> Bool
    
    func getImageMaskAtPoint(at position: CGPoint) -> CGImage?
}

//  Copyright © 2019 zscao. All rights reserved.

import UIKit

public struct Picture {
    private (set) var viewBox: CGRect
    private (set) var paths: [CGPath]
    private (set) var isFlipped: Bool
    
    public init(viewBox: CGRect, paths: [CGPath], flipped: Bool) {
        self.viewBox = viewBox
        self.paths = paths
        self.isFlipped = flipped
    }
}

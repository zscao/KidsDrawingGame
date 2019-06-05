//  Copyright © 2019 zscao. All rights reserved.

import UIKit

public struct Picture {
    private (set) var size: CGSize
    private (set) var paths: [CGPath]
    private (set) var isFlipped: Bool
    
    public init(size: CGSize, paths: [CGPath], flipped: Bool) {
        self.size = size
        self.paths = paths
        self.isFlipped = flipped
    }
}

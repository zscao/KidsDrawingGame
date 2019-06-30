//  Copyright © 2019 zscao. All rights reserved.

import UIKit

public struct Picture {
    public private (set) var name: String
    private (set) var viewBox: CGRect
    private (set) var paths: [CGPath]
    //private (set) var isFlipped: Bool
    
    public init(name: String, viewBox: CGRect, paths: [CGPath]) {
        self.name = name
        self.viewBox = viewBox
        self.paths = paths
        //self.isFlipped = flipped
    }
}

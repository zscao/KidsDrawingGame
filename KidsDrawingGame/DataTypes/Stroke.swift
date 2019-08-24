//  Copyright © 2019 zscao. All rights reserved.

import Foundation




public class Stroke {
    var mask: MaskImage? = nil
}

public class LineStroke: Stroke {
    public var line: Line
    
    init(line: Line, mask: MaskImage?) {
        self.line = line
        
        super.init()
        self.mask = mask
    }
}

//
//  Copyright © 2019 zscao. All rights reserved.
//

import UIKit

class Line {
    private (set) var color: CGColor
    private (set) var width: CGFloat
    private (set) var path: CGMutablePath
    
    private var _lastPoint: CGPoint
    private var _currentPoint: CGPoint
    private var _startPoint: CGPoint
    
    var lastSegment: CGPath {
        get {
            let p = CGMutablePath()
            p.move(to: _lastPoint)
            p.addLine(to: _currentPoint)
            return p
        }
    }
    
    init(start startPoint: CGPoint, color: CGColor, width: CGFloat) {
        self.path = CGMutablePath()
        self.path.move(to: startPoint)
        self.path.addLine(to: startPoint)
        
        self.color = color
        self.width = width
        
        _startPoint = startPoint
        _lastPoint = startPoint
        _currentPoint = startPoint
    }
    
    func lineTo(to toPoint: CGPoint) {
        path.addLine(to: toPoint)
        
        _lastPoint = _currentPoint
        _currentPoint = toPoint
    }
    
    func closePath() {
        path.closeSubpath()
        
        _lastPoint = _currentPoint
        _currentPoint = _startPoint
    }
}

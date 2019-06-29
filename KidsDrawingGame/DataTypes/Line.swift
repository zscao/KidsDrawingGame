//
//  Copyright © 2019 zscao. All rights reserved.
//

import UIKit

public class Line {
    public private (set) var color: CGColor
    public private (set) var width: CGFloat
    public private (set) var path: CGMutablePath
    public private (set) var startPoint: CGPoint
    
    private var _lastPoint: CGPoint
    private var _currentPoint: CGPoint
    
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
        self.startPoint = startPoint
        
        self.color = color
        self.width = width
        
        _lastPoint = startPoint
        _currentPoint = startPoint
    }
    
    public init(start startPoint: CGPoint, color: CGColor, width: CGFloat, path: CGPath) {
        self.path = CGMutablePath()
        self.path.addPath(path)
        self.startPoint = startPoint
        
        self.color = color
        self.width = width
        
        _lastPoint = self.path.currentPoint
        _currentPoint = self.path.currentPoint
    }
    
    
    func lineTo(to toPoint: CGPoint) {
        path.addLine(to: toPoint)
        
        _lastPoint = _currentPoint
        _currentPoint = toPoint
    }
    
    func closePath() {
        path.closeSubpath()
        
        _lastPoint = _currentPoint
        _currentPoint = self.startPoint
    }
}

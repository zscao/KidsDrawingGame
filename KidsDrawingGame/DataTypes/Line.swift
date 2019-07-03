//
//  Copyright © 2019 zscao. All rights reserved.
//

import UIKit

public class Line {
    public private (set) var color: CGColor
    public private (set) var width: CGFloat
    //public private (set) var startPoint: CGPoint
    public private (set) var points: [CGPoint]
    
    //private var _lastPoint: CGPoint
    //private var _currentPoint: CGPoint
    
    public var path: CGMutablePath {
        get {
            let p = CGMutablePath()
            p.addLines(between: self.points)
            return p
        }
    }
    
    public var startPoint: CGPoint {
        get {
            return points[0]
        }
    }
    
    var lastSegment: CGPath {
        get {
            let path = CGMutablePath()
            
            let lastIndex = points.count - 1
            let last2Index = points.count > 1 ? points.count - 2 : 0
            path.move(to: points[last2Index])
            path.addLine(to: points[lastIndex])
            
            return path
        }
    }
    
    init(start startPoint: CGPoint, color: CGColor, width: CGFloat) {
        self.points = [CGPoint]()
        self.points.append(startPoint)
        
        self.color = color
        self.width = width
    }
    
    public init(points: [CGPoint], color: CGColor, width: CGFloat) {
        self.points = points
        self.color = color
        self.width = width
    }
    
    func lineTo(to toPoint: CGPoint) {
        points.append(toPoint)
    }

}

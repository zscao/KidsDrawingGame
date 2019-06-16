//  Copyright © 2019 zscao. All rights reserved.

import Foundation

public protocol Drawable {
    
    var image: CGImage? { get }
    
    var sketchLayer: CALayer? { get }
    
    func reset()
    
    func startLine(start: CGPoint, color: CGColor, width lineWidth: CGFloat)
    
    func lineTo(to: CGPoint)
    
    func endLine(at: CGPoint?)
    
    func clear()
    
    func undo()
}

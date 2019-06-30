//  Copyright © 2019 zscao. All rights reserved.

import Foundation

public protocol Drawable {
    
    var image: CGImage? { get }
    
    var lines: [Line] { get }
    
    var changed: Bool { get }
    
    func reset()
    
    func startLine(start: CGPoint, color: CGColor, width lineWidth: CGFloat)
    
    func lineTo(to: CGPoint)
    
    func endLine(at: CGPoint?)
    
    func clear()
    
    func undo()

}

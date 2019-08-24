//  Copyright © 2019 zscao. All rights reserved.

import Foundation

public protocol Drawable {
    
    var image: CGImage? { get }
    
    var strokes: [Stroke] { get }
    
    var changed: Bool { get }
    
    func setup(lines: [Line])
    
    func startLine(start: CGPoint, color: CGColor, width lineWidth: CGFloat)
    
    func lineTo(to: CGPoint)
    
    func endLine(at: CGPoint?)
    
    func fill(at: CGPoint, color: CGColor)
    
    func clear()
    
    func undo()

}

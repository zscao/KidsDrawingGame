//  Copyright © 2019 zscao. All rights reserved.

import UIKit

class BubbleLayer: CALayer {
    
    private var timer: Timer?
    
    init(frame: CGRect) {
        super.init()
        self.frame = frame
        self.backgroundColor = UIColor.blue.cgColor
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func start() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [unowned self] t in
            let length = CGFloat.random(in: 20 ... 200)
            let size = CGSize(width: length, height: length)
            let position = CGPoint(x: CGFloat.random(in: 100 ... self.frame.width - 100), y: self.frame.maxY)
            
            self.createBubble(size: size, position: position)
        }
    }
    
    func stop() {
        timer?.invalidate()
        timer = nil
    }
    
    
    private func createBubble(size: CGSize, position: CGPoint) {
        if let image = UIImage(named: "bubble") {
            
            let layer = CALayer()
            layer.bounds = CGRect(origin: .zero, size: size)
            layer.position = position
            layer.contents = image.cgImage
            layer.opacity = Float.random(in: 0.5...1.0)
            self.addSublayer(layer)
            
            let path = getFloatPath(from: position)
            
            CATransaction.begin()
            CATransaction.setCompletionBlock {
                layer.removeFromSuperlayer()
            }
            
            let animation = CAKeyframeAnimation(keyPath: "position")
            animation.duration = 6.0
            animation.path = path
            animation.fillMode = CAMediaTimingFillMode.forwards
            animation.isRemovedOnCompletion = true
            
            layer.add(animation, forKey: "floating")
            
            CATransaction.commit()
            
            layer.position = path.currentPoint
        }
    }
    
    private func getFloatPath(from position: CGPoint) -> CGPath {
        let ox = position.x
        let oy = position.y
        
        let ex = ox
        let ey: CGFloat = CGFloat.random(in: 100 ... (oy - 500))
        var t: CGFloat = CGFloat.random(in: 10...300)
        
        let direction = Int.random(in: 0...1)
        if direction == 0 { t *= -1 }
        
        let cp1 = CGPoint(x: ox - t, y: (oy + ey) / 2)
        let cp2 = CGPoint(x: ox + t, y: cp1.y)
        
        let path = CGMutablePath()
        path.move(to: CGPoint(x: ox, y: oy))
        path.addCurve(to: CGPoint(x: ex, y: ey), control1: cp1, control2: cp2)
        
        return path
    }
}

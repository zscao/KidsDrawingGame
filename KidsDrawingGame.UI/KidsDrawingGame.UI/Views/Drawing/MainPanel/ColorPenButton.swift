//  Copyright © 2019 zscao. All rights reserved.

import UIKit

class ColorPenButton: UIButton {

    private (set) var color: UIColor = UIColor.black

    func setColor(color: UIColor) {
        self.color = color
        setNeedsDisplay()
    }
    
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
    
        let borderRect = rect.insetBy(dx: 2, dy: 2)
        
        context.setFillColor(self.color.cgColor)
        context.fillEllipse(in: borderRect)
        
        context.setStrokeColor(UIColor.lightGray.cgColor)
        context.setLineWidth(4.0)
        context.strokeEllipse(in: borderRect)
    }
}

//  Copyright © 2019 zscao. All rights reserved.

import UIKit

class ActionButton: UIButton {
    var action: DrawingAction = .drawing
}
/*
class ActionButton1: CAShapeLayer {
    private (set) var action: DrawingAction = .drawing
    private (set) var size: CGSize = .zero
    private (set) var color: CGColor = UIColor.white.cgColor
    
    init(action: DrawingAction, size: CGSize, color: CGColor) {
        self.action = action
        self.size = size
        
        super.init()
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(layer: Any) {
        super.init(layer: layer)
    }
    
    private func setup() {
        let rect = CGRect(origin: .zero, size: self.size)
        self.bounds = rect
        
        refresh()
    }
    
    private func refresh() {
        let rect = CGRect(origin: .zero, size: self.size)
        
        let path = CGMutablePath()
        path.addRoundedRect(in: rect, cornerWidth: 5, cornerHeight: 5)
        
        self.path = path
        self.strokeColor = UIColor.white.cgColor
        self.lineWidth = 4
        self.fillColor = self.color
    }
    
}
*/

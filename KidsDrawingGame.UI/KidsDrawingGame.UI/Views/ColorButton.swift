//  Copyright © 2019 zscao. All rights reserved.

import UIKit

class ColorButton: CAShapeLayer {
    private (set) var color: UIColor = .white
    private var _height: CGFloat = 40
    
    var size: CGSize {
        get {
            return CGSize(width: _height * 3, height: _height - 3)
        }
    }
    
    init(color: UIColor, height: CGFloat) {
        self.color = color
        _height = height
        super.init()
        
        setup()
    }
    
    override init(layer: Any) {
        super.init(layer: layer)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func setup() {
        let rect = CGRect(origin: .zero, size: self.size)
        self.bounds = rect
        
        let path = CGMutablePath()
        path.addRoundedRect(in: rect, cornerWidth: 5, cornerHeight: 5)
        
        self.path = path
        self.strokeColor = UIColor.white.cgColor
        self.lineWidth = 4
        self.fillColor = color.cgColor
    }
    
}

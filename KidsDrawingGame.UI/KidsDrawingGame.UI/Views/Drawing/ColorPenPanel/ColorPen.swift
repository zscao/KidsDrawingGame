//  Copyright © 2019 zscao. All rights reserved.

import UIKit
import KidsDrawingGame

class ColorPen: CAShapeLayer {
    private (set) var color: UIColor = .white
    private var _height: CGFloat = 40
    
    var size: CGSize {
        get {
            return CGSize(width: _height * 2.5, height: _height - 3)
        }
    }
    
    init(color: UIColor, height: CGFloat) {
        self.color = color
        _height = height
        super.init()
    }
    
    override init(layer: Any) {
        super.init(layer: layer)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func setup(viewMode: ViewMode) -> ColorPen {
        let rect = CGRect(origin: .zero, size: self.size)
        self.bounds = rect
        
        let path = CGMutablePath()
        path.addRoundedRect(in: rect, cornerWidth: 5, cornerHeight: 5)
        
        self.path = path
        self.strokeColor = UIColor.white.cgColor // color.cgColor
        self.lineWidth = 1
        self.fillColor = viewMode.backgroundColor.withAlphaComponent(0.8).cgColor
        
        self.shadowOpacity = 1.0
        self.shadowOffset = CGSize(width: 6, height: 4)
        self.shadowRadius = 6
        self.shadowColor = UIColor.gray.cgColor
        
        // stroke a line
        let stroke = CGMutablePath()
        stroke.move(to: CGPoint(x: 20, y: size.height - 20))
        stroke.addCurve(to: CGPoint(x: size.width / 2, y: size.height / 2), control1: CGPoint(x: size.width / 2, y: -size.height * 0.4), control2: CGPoint(x: size.width / 4, y: size.height * 1.4))
        stroke.addLine(to: CGPoint(x: size.width - 40, y: size.height / 2))
        //stroke.addCurve(to: CGPoint(x: size.width - 20, y: size.height / 2), control1: CGPoint(x: size.width * 0.75, y: 0), control2: CGPoint(x: size.width * 0.75, y: size.height / 2))
        //stroke.addCurve(to: CGPoint(x: size.width - 20, y: 20), control1: CGPoint(x: size.width / 2, y: 0), control2: CGPoint(x: size.width / 2, y: size.height))
        
        let subLayer = CAShapeLayer()
        subLayer.bounds = rect
        subLayer.position = CGPoint(x: size.width / 2, y: size.height / 2)
        subLayer.path = stroke
        subLayer.strokeColor = color.cgColor
        subLayer.lineWidth = 30
        subLayer.lineCap = .round
        subLayer.lineJoin = .round
        self.addSublayer(subLayer)
        
        return self
    }
    
}

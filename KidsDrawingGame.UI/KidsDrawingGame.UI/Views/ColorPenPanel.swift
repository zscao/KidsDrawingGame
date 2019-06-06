//  Copyright © 2019 zscao. All rights reserved.

import UIKit

class ColorPenPanel: UIView {

    var onAction: ((_ color: UIColor) -> Void)? = nil
    
    private var colorButtons: [ColorButton] = [ColorButton]()
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    func show() {
        self.isHidden = false
        
        for (index, btn) in colorButtons.enumerated() {
            btn.isHidden = false
            
            let from = frame.height - 100
            let to = CGFloat(index + 1) * (btn.size.height + 3)
            btn.position = CGPoint(x: btn.size.width / 2, y: to)
            
//            let animation = CABasicAnimation(keyPath: "position.y")
//            animation.duration = 2.0
//            animation.fromValue = from
//            animation.toValue = to
//            btn.add(animation, forKey: "position.y")
//            btn.animation(forKey: "position.y")
        }
    }
    
    func hide() {
        self.isHidden = true
        
        for (index, btn) in colorButtons.enumerated() {
            btn.isHidden = true
            
            let from = frame.height - 100
            let to = CGFloat(index + 1) * btn.size.height
            btn.position = CGPoint(x: btn.size.width / 2, y: from)
        }
        
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    
    private func setup() {
        
        //self.backgroundColor = .darkGray
        
        let height = self.frame.height
        let btnHeight = height / 15
        
//        for r in 0..<3 {
//            var red = 255 - r * 128
//            if red < 0 { red = 0 }
//            for g in 0..<3 {
//                var green = 255 - g * 128
//                if green < 0 { green = 0}
//                for b in 0..<3 {
//                    var blue = 255 - b * 128
//                    if blue < 0 { blue  = 0}
//
//                    let color = UIColor(displayP3Red: CGFloat(red) / 255, green: CGFloat(green) / 255, blue: CGFloat(blue) / 255, alpha: 1.0)
//                    let btn = ColorButton(color: color, height: btnHeight)
//                    colorButtons.append(btn)
//                }
//            }
//        }
        
        colorButtons.append(ColorButton(color: .red, height: btnHeight))
        colorButtons.append(ColorButton(color: .orange, height: btnHeight))
        colorButtons.append(ColorButton(color: .yellow, height: btnHeight))
        colorButtons.append(ColorButton(color: .green, height: btnHeight))
        colorButtons.append(ColorButton(color: .blue, height: btnHeight))
        colorButtons.append(ColorButton(color: .cyan, height: btnHeight))
        colorButtons.append(ColorButton(color: .magenta, height: btnHeight))
        colorButtons.append(ColorButton(color: .purple, height: btnHeight))
        colorButtons.append(ColorButton(color: .brown, height: btnHeight))
        colorButtons.append(ColorButton(color: .white, height: btnHeight))
        colorButtons.append(ColorButton(color: .lightGray, height: btnHeight))
        colorButtons.append(ColorButton(color: .gray, height: btnHeight))
        colorButtons.append(ColorButton(color: .darkGray, height: btnHeight))
        colorButtons.append(ColorButton(color: .black, height: btnHeight))
        
        
        for btn in colorButtons {
            btn.isHidden = true
            btn.position = CGPoint(x: btn.size.width / 2, y: frame.height - 100)
            self.layer.addSublayer(btn)
        }
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        
        let location = touch.location(in: self)
        let locationInView = self.convert(location, to: nil)
        
        if let btn = self.layer.hitTest(locationInView) as? ColorButton {
            self.onAction?(btn.color)
        }
    }
}

fileprivate class ColorButton: CAShapeLayer {
    private (set) var color: UIColor = .white
    private var height: CGFloat = 40
    private var width: CGFloat = 200
    
    var size: CGSize {
        get {
            return CGSize(width: width, height: height)
        }
    }
    
    init(color: UIColor, height: CGFloat) {
        self.color = color
        self.height = height
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
        let rect = CGRect(origin: .zero, size: CGSize(width: 200, height: self.height))
        let path = CGMutablePath()
        path.addRoundedRect(in: rect, cornerWidth: 5, cornerHeight: 5)
        
        self.bounds = rect
        self.path = path
        self.strokeColor = UIColor.white.cgColor
        self.lineWidth = 4
        self.fillColor = color.cgColor
    }
    
}

//  Copyright © 2019 zscao. All rights reserved.

import UIKit
import KidsDrawingGame

class ColorPenPanel: UIView {

    var onAction: ((_ color: UIColor) -> Void)? = nil
    
    private var colorButtons: [ColorPen] = [ColorPen]()
    private var _selectedButton: ColorPen?
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
   
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    func setup(viewMode: ViewMode) {
        
        self.isHidden = true
        //self.backgroundColor = .lightGray
        
        let height = self.frame.height
        let btnHeight = height / 15
        
        
        colorButtons.append(ColorPen(color: .red, height: btnHeight).setup(viewMode: viewMode))
        colorButtons.append(ColorPen(color: .orange, height: btnHeight).setup(viewMode: viewMode))
        colorButtons.append(ColorPen(color: .yellow, height: btnHeight).setup(viewMode: viewMode))
        colorButtons.append(ColorPen(color: .green, height: btnHeight).setup(viewMode: viewMode))
        colorButtons.append(ColorPen(color: .blue, height: btnHeight).setup(viewMode: viewMode))
        colorButtons.append(ColorPen(color: .cyan, height: btnHeight).setup(viewMode: viewMode))
        colorButtons.append(ColorPen(color: .magenta, height: btnHeight).setup(viewMode: viewMode))
        colorButtons.append(ColorPen(color: .purple, height: btnHeight).setup(viewMode: viewMode))
        colorButtons.append(ColorPen(color: .brown, height: btnHeight).setup(viewMode: viewMode))
        colorButtons.append(ColorPen(color: .white, height: btnHeight).setup(viewMode: viewMode))
        colorButtons.append(ColorPen(color: .lightGray, height: btnHeight).setup(viewMode: viewMode))
        //colorButtons.append(ColorButton(color: .gray, height: btnHeight))
        //colorButtons.append(ColorButton(color: .darkGray, height: btnHeight))
        colorButtons.append(ColorPen(color: .black, height: btnHeight).setup(viewMode: viewMode))
        
        resetButtons()
        
        for btn in colorButtons {
            self.layer.addSublayer(btn)
        }
    }
    
    private func resetButtons() {
        _selectedButton = nil
        
        for (index, btn) in colorButtons.enumerated() {
            btn.isHidden = true
            btn.opacity = 1.0
            btn.transform = CATransform3DIdentity
            
            let x: CGFloat = frame.size.width + btn.size.width / 2
            let y = CGFloat(index + 1) * (btn.size.height + 12)
            btn.position = CGPoint(x: x, y: y)
        }
    }
    
    private func findTouchedButton(at position: CGPoint) -> ColorPen? {
        let locationInView = self.convert(position, to: nil)
        
        guard let touched = self.layer.hitTest(locationInView) as? CAShapeLayer else { return nil }
        
        if let pen = touched as? ColorPen {
            return pen
        }
        else if let pen = touched.superlayer as? ColorPen {
            return pen
        }
        else {
            return nil
        }
        
//        if let layers = self.layer.sublayers {
//            for layer in layers {
//                guard let btn = layer as? ColorButton else { continue }
//
//                if let touched = btn.hitTest(locationInView) as? ColorButton {
//                    return touched
//                }
//            }
//        }
//        return nil
    }
    
    private func addScaleToButton(to button: ColorPen, scale: CGFloat) {
        let scale: CGFloat = 1.2
        button.transform = CATransform3DMakeScale(scale, scale, 1.0)
        let deltax: CGFloat = button.size.width * (scale - 1) / 2
        button.position = CGPoint(x: frame.width / 2 - deltax, y: button.position.y)
    }
    
    private func removeScaleFromButton(from button: ColorPen) {
        button.transform = CATransform3DIdentity
        button.position = CGPoint(x: frame.width / 2, y: button.position.y)
    }
    
    func show() {
        self.isHidden = false
        
        for btn in colorButtons {
            btn.isHidden = false
            btn.position = CGPoint(x: frame.size.width / 2, y: btn.position.y)
        }
    }
    
    func hide() {
        CATransaction.begin()
        CATransaction.setCompletionBlock({
            self.isHidden = true
            self.resetButtons()
        })
        
        for btn in colorButtons {
            btn.position = CGPoint(x: frame.width + btn.size.width / 2, y: btn.position.y)
        }
        CATransaction.commit()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        
        let location = touch.location(in: self)
        if let selecting = findTouchedButton(at: location) {
            addScaleToButton(to: selecting, scale: 1.2)
            _selectedButton = selecting
        }
        
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        
        let location = touch.location(in: self)
        if let selecting = findTouchedButton(at: location) {
            
            if let selected = _selectedButton {
                if selected.color == selecting.color { return }
                removeScaleFromButton(from: selected)
            }

            addScaleToButton(to: selecting, scale: 1.2)
            _selectedButton = selecting
        }
        else if let selected = _selectedButton {
            removeScaleFromButton(from: selected)
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        
        let location = touch.location(in: self)
        
        if let selected = findTouchedButton(at: location) {
            self.onAction?(selected.color)
            
            CATransaction.begin()
            CATransaction.setCompletionBlock({
                self.isHidden = true
                self.resetButtons()
            })
            
            for btn in colorButtons {
                if btn.color == selected.color { continue }
                btn.opacity = 0.0
            }
            
            CATransaction.commit()
            return
        }
        
        self.isHidden = true
        resetButtons()
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.isHidden = true
        resetButtons()
    }
    
    func showSparkles(at position: CGPoint) -> CAEmitterLayer {
        let emitterLayer = CAEmitterLayer()
        emitterLayer.emitterPosition = position
        
        let cell = CAEmitterCell()
        cell.birthRate = 5
        cell.lifetime = 1.5
        cell.velocity = 100
        cell.scale = 0.3
        
        cell.emissionRange = CGFloat.pi
        cell.contents = UIImage(named: "star")!.cgImage
        
        emitterLayer.emitterCells = [cell]
        
        self.layer.addSublayer(emitterLayer)
        return emitterLayer
    }
}

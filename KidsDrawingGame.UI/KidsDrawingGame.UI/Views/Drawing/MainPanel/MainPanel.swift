//  Copyright © 2019 zscao. All rights reserved.

import UIKit

class MainPanel: UIView {
    
    var onAction: ((_ action: DrawingAction) -> Void)? = nil
    
    private var _colorPenButton: ColorPenButton? = nil
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        //self.backgroundColor = .darkGray
        
        initButtons()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func setColorPen(color: UIColor) {
        if let btn = _colorPenButton {
            btn.setColor(color: color)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        return
    }
    
    
    private func initButtons() {
        self.addSubview(getActionButton(at: CGPoint(x: 10, y: 0), action: .goBack, image: UIImage(named: "BackButton")))
        self.addSubview(getActionButton(at: CGPoint(x: 110, y: 0), action: .clear, image: UIImage(named: "ClearButton")))
        self.addSubview(getActionButton(at: CGPoint(x: 210, y: 0), action: .undo, image: UIImage(named: "UndoButton")))
        
        
        
        //self.addSubview(getActionButton(at: CGPoint(x: 210, y: 10), action: .pickPen, title: "Color"))
        let size = CGSize(width: 80, height: 80)
        
        let position = CGPoint(x: frame.width - size.width - 10, y: 0)
        let btn = ColorPenButton(frame: CGRect(origin: position, size: size))
        btn.setColor(color: UIColor.red)
        btn.addTarget(self, action: #selector(actionButtonTapped(_:)), for: .touchUpInside)
        self.addSubview(btn)
        
        _colorPenButton = btn
    }
    
    
    private func getActionButton(at position: CGPoint, action: DrawingAction, image: UIImage?) -> UIButton {
        
        let size = CGSize(width: 80, height: 80)
        
        let button = ActionButton(frame: CGRect(origin: position, size: size))
        button.action = action
        button.setImage(image, for: .normal)
        button.backgroundColor = .white
        
        button.addTarget(self, action: #selector(actionButtonTapped(_:)), for: .touchUpInside)
        
        return button
    }
    
    
    @objc func actionButtonTapped(_ send: UIButton!) {
        if let btn = send as? ColorPenButton {
            self.onAction?(.colorPen)
        }
        else if let btn = send as? ActionButton {
            self.onAction?(btn.action)
        }
    }
    
}


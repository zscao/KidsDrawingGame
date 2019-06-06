//  Copyright © 2019 zscao. All rights reserved.

import UIKit

class MainPanel: UIView {
    
    var onAction: ((_ action: DrawingAction) -> Void)? = nil
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .darkGray
        
        initButtons()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        return
    }
    
    
    private func initButtons() {
        self.addSubview(getActionButton(at: CGPoint(x: 10, y: 10), action: .clear, title: "Clear"))
        self.addSubview(getActionButton(at: CGPoint(x: 110, y: 10), action: .undo, title: "Undo"))
        self.addSubview(getActionButton(at: CGPoint(x: 210, y: 10), action: .pickPen, title: "Color"))
//        self.addSubview(getColorButton(at: CGPoint(x: 210, y: 10), color: .red, title: "Red"))
//        self.addSubview(getColorButton(at: CGPoint(x: 310, y: 10), color: .green, title: "Green"))
//        self.addSubview(getColorButton(at: CGPoint(x: 410, y: 10), color: .blue, title: "Blue"))
//        self.addSubview(getColorButton(at: CGPoint(x: 510, y: 10), color: .white, title: "White"))
        //self.addSubview(getColorButton(at: CGPoint(x: 610, y: 10), color: .black, title: "Black"))
    }
    
    
    private func getActionButton(at position: CGPoint, action: DrawingAction, title: String) -> UIButton {
        let button = ActionButton(frame: CGRect(origin: position, size: CGSize(width: 80, height: 30)))
        button.action = action
        button.setTitleColor(UIColor.black, for: .normal)
        button.setTitle(title, for: .normal)
        button.backgroundColor = .white
        
        button.addTarget(self, action: #selector(actionButtonTapped(_:)), for: .touchUpInside)
        
        return button
    }
    
    
    @objc func actionButtonTapped(_ send: ActionButton!) {
        self.onAction?(send.action)
    }
    
}


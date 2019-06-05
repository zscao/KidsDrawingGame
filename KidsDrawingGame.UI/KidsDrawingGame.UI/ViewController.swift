//
//  Copyright © 2019 zscao. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    private var canvasView: CanvasView?
    private var mainPanel: MainPanel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.canvasView = CanvasView(frame: self.view.frame)
        if let canvas = self.canvasView {
            canvas.image = UIImage(named: "lake")
            canvas.isUserInteractionEnabled = true
            self.view.addSubview(canvas)
            
            canvas.refreshDrawing()
        }
        
        let mainPanelRect = CGRect(
            x: 10,
            y: self.view.frame.maxY - 70,
            width: 600,
            height: 60)
        
        self.mainPanel = MainPanel(frame: mainPanelRect)
        if let panel = self.mainPanel {
            self.view.addSubview(panel)
            
            panel.onAction = { [unowned self] action in
                switch action {
                case .clear:
                    self.canvasView?.clear()
                case .undo:
                    self.canvasView?.undo()
                case .pickColor(let color):
                    self.canvasView?.setStrokeColor(color: color)
                default:
                    return
                }
            }
        }
    }
}


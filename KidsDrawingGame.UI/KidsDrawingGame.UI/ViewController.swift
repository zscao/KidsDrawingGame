//
//  Copyright © 2019 zscao. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    private var canvasView: CanvasView?
    private var mainPanel: MainPanel?
    private var colorPanel: ColorPenPanel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let mainframe = self.view.frame
        
        self.canvasView = CanvasView(frame: mainframe)
        if let canvas = self.canvasView {
            canvas.isUserInteractionEnabled = true
            self.view.addSubview(canvas)
            
            canvas.refreshDrawing()
        }
        
        let colorPanelRect = CGRect(
            x: 10,
            y: 10,
            width: 250,
            height: mainframe.height - 100)
        
        self.colorPanel = ColorPenPanel(frame: colorPanelRect)
        if let panel = self.colorPanel {
            panel.hide()
            self.view.addSubview(panel)
            
            panel.onAction = {[unowned self] color in
                self.colorPanel?.hide()
                self.canvasView?.setStrokeColor(color: color)
            }
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
                case .pickPen:
                    //self.canvasView?.setStrokeColor(color: color)
                    if let colorPanel = self.colorPanel {
                        UIView.animate(withDuration: 2, animations: { [unowned colorPanel]() in
                            //let center = CGPoint(x: 200, y: 200)
                            if colorPanel.isHidden {
                                colorPanel.show()
                            }
                            else {
                                colorPanel.hide()
                            }
                        })
                    }
                default:
                    return
                }
            }
        }
    }
}


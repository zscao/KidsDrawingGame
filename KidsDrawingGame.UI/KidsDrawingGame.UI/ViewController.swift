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
        
        setupCanvas()
        setupColorPanel()
        setupMainPanel()
    }
    
    private func setupCanvas() {
        let mainframe = self.view.frame
        
        self.canvasView = CanvasView(frame: mainframe)
        if let canvas = self.canvasView {
            canvas.isUserInteractionEnabled = true
            self.view.addSubview(canvas)
            
            canvas.refreshDrawing()
        }
    }
    
    private func setupColorPanel() {
        let mainframe = self.view.frame
        
        let colorPanelRect = CGRect(
            x: mainframe.width - 250,
            y: 0,
            width: 250,
            height: mainframe.height - 80)
        
        self.colorPanel = ColorPenPanel(frame: colorPanelRect)
        if let panel = self.colorPanel {
            self.view.addSubview(panel)
            
            panel.onAction = {[unowned self] color in
                self.mainPanel?.setColorPen(color: color)
                self.canvasView?.setStrokeColor(color: color)
            }
        }
    }
    
    private func setupMainPanel() {
        let mainPanelRect = getMainPanelRect(frameSize: self.view.frame.size)
        
        self.mainPanel = MainPanel(frame: mainPanelRect)
        if let panel = self.mainPanel {
            self.view.addSubview(panel)
            
            panel.onAction = { [unowned self] action in
                switch action {
                case .clear:
                    self.canvasView?.clear()
                case .undo:
                    self.canvasView?.undo()
                case .colorPen:
                    if let colorPanel = self.colorPanel {
                        if colorPanel.isHidden {
                            colorPanel.show()
                        }
                        else {
                            colorPanel.hide()
                        }
                    }
                default:
                    return
                }
            }
        }
    }
    
    private func getMainPanelRect(frameSize: CGSize) -> CGRect {
        return CGRect(
            x: 10,
            y: frameSize.height - 90,
            width: frameSize.width - 20,
            height: 80)
    }
}


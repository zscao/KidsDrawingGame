//  Copyright © 2019 zscao. All rights reserved.

import UIKit
import KidsDrawingGame


class DrawingView: UIView {
    
    var onHome: (() -> Void)?
    
    private var canvasView: CanvasView?
    private var mainPanel: MainPanel?
    private var colorPanel: ColorPenPanel?
    
    private var viewMode = ViewMode(color: UIColor.black, backgroundColor: UIColor.white)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func setup(picture: Picture) {
        setupCanvas(picture: picture)
        setupColorPanel()
        setupMainPanel()
    }
    
    private func setupCanvas(picture: Picture) {
        let mainframe = self.frame
        
        self.canvasView = CanvasView(frame: mainframe)
        if let canvas = self.canvasView {
            canvas.isUserInteractionEnabled = true
            self.addSubview(canvas)
            canvas.setup(viewMode: viewMode, picture: picture)
            canvas.refreshDrawing()
        }
    }
    
    private func setupColorPanel() {
        let mainframe = self.frame
        
        let colorPanelRect = CGRect(
            x: mainframe.width - 250,
            y: 0,
            width: 250,
            height: mainframe.height - 80)
        
        self.colorPanel = ColorPenPanel(frame: colorPanelRect)
        if let panel = self.colorPanel {
            panel.setup(viewMode: viewMode)
            self.addSubview(panel)
            
            panel.onAction = {[unowned self] color in
                self.mainPanel?.setColorPen(color: color)
                self.canvasView?.setStrokeColor(color: color)
            }
        }
    }
    
    private func setupMainPanel() {
        let mainPanelRect = getMainPanelRect(frameSize: self.frame.size)
        
        self.mainPanel = MainPanel(frame: mainPanelRect)
        if let panel = self.mainPanel {
            self.addSubview(panel)
            
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
                case .goBack:
                    self.onHome?()
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
    }}

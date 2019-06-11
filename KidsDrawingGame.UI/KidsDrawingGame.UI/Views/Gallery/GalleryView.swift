//  Copyright © 2019 zscao. All rights reserved.

import UIKit
import PocketSVG

class GalleryView: UIView {

    var onSelection: ((_ picture: String) -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup()
    {
        addSVGLayer(from: "butterfly", at: CGPoint(x: 200, y: 200))
        addSVGLayer(from: "flower", at: CGPoint(x: 200, y: 500))
    }
    
    private func addSVGImageView(from resource: String, frame: CGRect) {
        if let url = Bundle.main.url(forResource: resource, withExtension: "svg") {
            let svg = SVGImageView.init(contentsOf: url)
            svg.bounds = frame
            svg.contentMode = .scaleAspectFit
            
            
            self.addSubview(svg)
        }
    }
    
    private func addSVGLayer(from resource: String, at position: CGPoint) {
        if let url = Bundle.main.url(forResource: resource, withExtension: "svg") {
            let svg = SVGLayer(contentsOf: url)
            svg.bounds = CGRect(x: 0, y: 0, width: 250, height: 250)
            svg.position = position
            
            svg.name = resource
            
            self.layer.addSublayer(svg)
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        
        let location = touch.location(in: self)
        let locationInView = self.convert(location, to: nil)
        guard let touched = self.layer.hitTest(locationInView) else { return }
        
        if let layer = touched as? SVGLayer, let name = layer.name {
            onSelection?(name)
        }
        else if let layer = touched.superlayer as? SVGLayer, let name = layer.name {
            onSelection?(name)
        }
    }
    
}

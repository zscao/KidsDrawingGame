//  Copyright © 2019 zscao. All rights reserved.

import PocketSVG
import KidsDrawingGame

extension Album {
    func addSamples() {
        addSample("flower", flipped: true)
        addSample("benz", flipped: true)
        addSample("butterfly", flipped: true)
    }
    
    func addSample(_ name: String, flipped: Bool) {
        if let pic = loadFromSVG(name: name, flipped: true) {
            append(name: name, picture: pic)
        }
    }
    
    
    private func loadFromSVG(name: String, flipped: Bool) -> Picture? {
        if let url = Bundle.main.url(forResource: name, withExtension: "svg") {
            let svgPaths = SVGBezierPath.pathsFromSVG(at: url)
            let svgRect = SVGBoundingRectForPaths(svgPaths)
            
            var paths = [CGPath]()
            for (_, path) in svgPaths.enumerated() {
                paths.append(path.cgPath)
            }
            return Picture(viewBox: svgRect, paths: paths, flipped: flipped)
        }
        return nil
    }
}

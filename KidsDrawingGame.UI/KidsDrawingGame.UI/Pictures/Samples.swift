//  Copyright © 2019 zscao. All rights reserved.

import PocketSVG
import KidsDrawingGame

extension Album {
    func addSamples() {
        addSample("flower")
        addSample("benz")
        addSample("butterfly")
    }
    
    func addSample(_ name: String) {
        if let pic = loadFromSVG(name: name) {
            append(name: name, picture: pic)
        }
    }
    
    
    private func loadFromSVG(name: String) -> Picture? {
        if let url = Bundle.main.url(forResource: name, withExtension: "svg") {
            let svgPaths = SVGBezierPath.pathsFromSVG(at: url)
            let svgRect = SVGBoundingRectForPaths(svgPaths)
            
            var paths = [CGPath]()
            for (_, path) in svgPaths.enumerated() {
                paths.append(path.cgPath)
            }
            return Picture(name: name, viewBox: svgRect, paths: paths)
        }
        return nil
    }
}

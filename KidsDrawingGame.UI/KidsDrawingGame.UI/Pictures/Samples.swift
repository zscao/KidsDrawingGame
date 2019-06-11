//  Copyright © 2019 zscao. All rights reserved.

import PocketSVG
import KidsDrawingGame

extension Album {
    func addSamples() {
        if let sample = loadFromSVG(name: "freesample", flipped: true) {
            _collection["sample"] = sample
        }
        if let flower = loadFromSVG(name: "flower", flipped: true) {
            _collection["flower"] = flower
        }
        if let bus = loadFromSVG(name: "bus", flipped: true) {
            _collection["bus"] = bus
        }
        if let pic = loadFromSVG(name: "butterfly", flipped: true) {
            _collection["butterfly"] = pic
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

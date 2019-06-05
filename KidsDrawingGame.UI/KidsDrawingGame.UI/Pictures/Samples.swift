//  Copyright © 2019 zscao. All rights reserved.

import PocketSVG
import KidsDrawingGame

extension Album {
    func addSamples() {
        if let sample = loadFromSVG(name: "FreeSample", size: CGSize(width: 300, height: 300), flipped: true) {
            _collection["sample"] = sample
        }
        if let flower = loadFromSVG(name: "Flower", size: CGSize(width: 864, height: 864), flipped: true) {
            _collection["flower"] = flower
        }
        if let bus = loadFromSVG(name: "Bus", size: CGSize(width: 600, height: 300), flipped: true) {
            _collection["bus"] = bus
        }
        if let pic = loadFromSVG(name: "butterfly", size: CGSize(width: 1200, height: 1200), flipped: true) {
            _collection["butterfly"] = pic
        }
    }
    
    private func loadFromSVG(name: String, size: CGSize, flipped: Bool) -> Picture? {
        if let url = Bundle.main.url(forResource: name, withExtension: "svg") {
            let svgPaths = SVGBezierPath.pathsFromSVG(at: url)
            var paths = [CGPath]()
            
            for (_, path) in svgPaths.enumerated() {
                paths.append(path.cgPath)
            }
            return Picture(size: size, paths: paths, flipped: flipped)
        }
        return nil
    }
}

//  Copyright © 2019 zscao. All rights reserved.

import PocketSVG
import KidsDrawingGame

extension Album {
    func addSamples() {
        if let sample = getFreeSample() {
            _collection["sample"] = sample
        }
    }
    
    private func getFreeSample() -> Picture? {
        if let url = Bundle.main.url(forResource: "Freesample", withExtension: "svg") {
            let svgPaths = SVGBezierPath.pathsFromSVG(at: url)
            var paths = [CGPath]()
            
            for (_, path) in svgPaths.enumerated() {
                paths.append(path.cgPath)
            }
            
            let size = CGSize(width: 300, height: 300)
            
            return Picture(size: size, paths: paths, flipped: true)
        }
        return nil
    }
}

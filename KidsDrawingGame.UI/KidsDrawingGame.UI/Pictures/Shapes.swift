//  Copyright © 2019 zscao. All rights reserved.

import UIKit
import KidsDrawingGame


extension Album {
    
    func addShapes() {
        append(name: "square", picture: getSquare())
    }
    
    private func getSquare() -> Picture {
        var paths = [CGPath]()
        let path = CGMutablePath()
        path.addRect(CGRect(x: 20, y: 20, width: 160, height: 160))
        path.addRect(CGRect(x: 40, y: 40, width: 120, height: 120))
        path.addRect(CGRect(x: 60, y: 60, width: 80, height: 80))
        path.addRect(CGRect(x: 80, y: 80, width: 40, height: 40))
        paths.append(path)
        
        let size = CGSize(width: 180, height: 180)
        
        return Picture(viewBox: CGRect(origin: .zero, size: size), paths: paths, flipped: false)
    }
}

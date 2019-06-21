//  Copyright © 2019 zscao. All rights reserved.

import UIKit
import KidsDrawingGame


extension Album {
    
    func addShapes() {
        append(name: "square", picture: getSquare())
        append(name: "circle", picture: getCircle())
    }
    
    private func getSquare() -> Picture {
        var paths = [CGPath]()
        let path = CGMutablePath()
//        path.addRect(CGRect(x: 60, y: 60, width: 480, height: 480))
//        path.addRect(CGRect(x: 120, y: 120, width: 360, height: 360))
//        path.addRect(CGRect(x: 180, y: 180, width: 240, height: 240))
//        path.addRect(CGRect(x: 240, y: 240, width: 120, height: 120))
        paths.append(path)
        
        let size = CGSize(width: 600, height: 600)
        
        return Picture(viewBox: CGRect(origin: .zero, size: size), paths: paths, flipped: true)
    }
    
    private func getCircle() -> Picture {
        var paths = [CGPath]()
        let path = CGMutablePath()
        path.addEllipse(in: CGRect(x: 20, y: 20, width: 160, height: 160))
        path.addEllipse(in: CGRect(x: 40, y: 40, width: 120, height: 120))
        path.addEllipse(in: CGRect(x: 60, y: 60, width: 80, height: 80))
        path.addEllipse(in: CGRect(x: 80, y: 80, width: 40, height: 40))
        paths.append(path)
        
        let size = CGSize(width: 200, height: 200)
        
        return Picture(viewBox: CGRect(origin: .zero, size: size), paths: paths, flipped: true)
    }
}

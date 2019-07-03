//  Copyright © 2019 zscao. All rights reserved.

import Foundation
import KidsDrawingGame

class LineWrapper: NSObject, NSCoding {
    
    var color: UIColor
    var width: CGFloat
    var points: [CGPoint]
    
    var line: Line {
        get {
            return Line(points: self.points, color: self.color.cgColor, width: self.width)
        }
    }
    
    init(line: Line) {
        self.color = UIColor(cgColor: line.color)
        self.width = line.width
        self.points = line.points
    }
    
    init(points: [CGPoint], color: UIColor, width: CGFloat)
    {
        self.color = color
        self.width = width
        self.points = points
    }
    
    // coding support
    private enum CodingKeys: String {
        case color = "color"
        case width = "width"
        case points = "points"
    }
    
    public func encode(with aCoder: NSCoder) {
        aCoder.encode(self.color, forKey: CodingKeys.color.rawValue)
        aCoder.encode(self.width, forKey: CodingKeys.width.rawValue)
        aCoder.encode(self.points, forKey: CodingKeys.points.rawValue)
    }
    
    public required convenience init?(coder aDecoder: NSCoder) {
        let color = aDecoder.decodeObject(forKey: CodingKeys.color.rawValue) as! UIColor
        let width = aDecoder.decodeObject(forKey: CodingKeys.width.rawValue) as! CGFloat
        let points = aDecoder.decodeObject(forKey: CodingKeys.points.rawValue) as! [CGPoint]
        self.init(points: points, color: color, width: width)
    }
}

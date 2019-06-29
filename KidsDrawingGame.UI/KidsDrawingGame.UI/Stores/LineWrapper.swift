//  Copyright © 2019 zscao. All rights reserved.

import Foundation
import KidsDrawingGame

class LineWrapper: NSObject, NSCoding {
    
    var color: UIColor
    var width: CGFloat
    var path: UIBezierPath
    var startPoint: CGPoint
    
    var line: Line {
        get {
            return Line(start: self.startPoint, color: self.color.cgColor, width: self.width, path: self.path.cgPath)
        }
    }
    
    init(line: Line) {
        self.color = UIColor(cgColor: line.color)
        self.width = line.width
        self.path = UIBezierPath.init(cgPath: line.path)
        self.startPoint = line.startPoint
    }
    
    init(start startPoint: CGPoint, color: UIColor, width: CGFloat, path: UIBezierPath)
    {
        self.color = color
        self.width = width
        self.path = path
        self.startPoint = startPoint
    }
    
    // coding support
    private enum CodingKeys: String {
        case color = "color"
        case width = "width"
        case path = "path"
        case startPoint = "startPoint"
    }
    
    public func encode(with aCoder: NSCoder) {
        aCoder.encode(self.color, forKey: CodingKeys.color.rawValue)
        aCoder.encode(self.width, forKey: CodingKeys.width.rawValue)
        aCoder.encode(self.path, forKey: CodingKeys.path.rawValue)
        aCoder.encode(self.startPoint, forKey: CodingKeys.startPoint.rawValue)
    }
    
    public required convenience init?(coder aDecoder: NSCoder) {
        let color = aDecoder.decodeObject(forKey: CodingKeys.color.rawValue) as! UIColor
        let width = aDecoder.decodeObject(forKey: CodingKeys.width.rawValue) as! CGFloat
        let path = aDecoder.decodeObject(forKey: CodingKeys.path.rawValue) as! UIBezierPath
        let startPoint = aDecoder.decodeCGPoint(forKey: CodingKeys.startPoint.rawValue)
        self.init(start: startPoint, color: color, width: width, path: path)
    }
}

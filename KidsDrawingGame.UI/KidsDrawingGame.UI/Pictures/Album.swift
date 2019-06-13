//  Copyright © 2019 zscao. All rights reserved.

import UIKit
import KidsDrawingGame


class Album {
    
    private var _collection = [(name: String, picture: Picture)]()
    
    var count: Int {
        get {
            return _collection.count
        }
    }
    
    func append(name: String, picture: Picture) {
        _collection.append((name: name, picture: picture))
    }
    
    subscript(index: Int) -> (name: String, picture: Picture)? {
        get {
            if index < 0 || index > self.count - 1 { return nil }
            return _collection[index]
        }
    }
    
    subscript(name: String) -> Picture? {
        get {
            return _collection.first(where: { (itemName: String, picture: Picture) -> Bool in
                return name == itemName
            })?.picture
        }
    }
}

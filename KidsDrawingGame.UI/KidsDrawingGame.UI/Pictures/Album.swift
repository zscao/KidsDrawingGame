//  Copyright © 2019 zscao. All rights reserved.

import UIKit
import KidsDrawingGame


class Album {
    
    var _collection: Dictionary<String, Picture>
    
    init() {
        _collection = [String: Picture]()
    }
    
    subscript(name: String) -> Picture? {
        get {
            return _collection[name]
        }
    }
}

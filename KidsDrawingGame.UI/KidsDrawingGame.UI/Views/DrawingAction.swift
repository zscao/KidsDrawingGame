//  Copyright © 2019 zscao. All rights reserved.

import UIKit

enum DrawingAction {
    case drawing
    case clear
    case undo
    case redo
    case pickColor(UIColor)
    case save
}

//  Copyright © 2019 zscao. All rights reserved.

import Foundation

struct RGBColorData {
    var r: UInt8
    var g: UInt8
    var b: UInt8
    var a: UInt8
}

extension RGBColorData {
    static func == (lhs: RGBColorData, rhs: RGBColorData) -> Bool {
        return lhs.r == rhs.r
            && lhs.g == rhs.g
            && lhs.b == rhs.b
            && lhs.a == rhs.a
    }
    
    static func != (lhs: RGBColorData, rhs: RGBColorData) -> Bool {
        return lhs.r != rhs.r
            || lhs.g != rhs.g
            || lhs.b != rhs.b
            || lhs.a != rhs.a
    }
    
    static func FromUnsafeUInt8(data: UnsafePointer<UInt8>, position: Int) -> RGBColorData {
        return RGBColorData(
            r: data[position + 1],
            g: data[position + 2],
            b: data[position + 3],
            a: data[position + 0])
    }
    
    var UInt32Value: UInt32 {
        get {
            return UInt32(a << 24 | r << 16 | g << 8 | b)
        }
    }
    
}

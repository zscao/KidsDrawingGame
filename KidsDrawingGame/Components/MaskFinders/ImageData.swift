//  Copyright © 2019 zscao. All rights reserved.


class ImageData {
    let width: Int
    let height: Int
    
    private var minX: Int, minY: Int, maxX: Int, maxY: Int
    
    private var _data: UnsafeMutablePointer<UInt8>
    
    init(width: Int, height: Int) {
        self.width = width
        self.height = height
        
        self.minX = width - 1
        self.minY = height - 1
        self.maxX = 0
        self.maxY = 0
        
        let capacity = width * height
        _data = UnsafeMutablePointer.allocate(capacity: capacity)
        _data.initialize(repeating: 0, count: capacity)
    }
    
    func setPixelColor(x: Int, y: Int, color: UInt8) {
        // the range is guranteed by the caller
        // the check below slows down the process
        //if x < 0 || y < 0 || x >= self.width || y >= self.height { return }
        
        if x < minX { minX = x }
        if x > maxX { maxX = x }
        if y < minY { minY = y }
        if y > maxY { maxY = y }
        
        let index = y * width + x
        _data[index] = color
    }
    
    func setPixelColor(x1: Int, x2: Int, y: Int, color: UInt8) {
        if x1 < minX { minX = x1 }
        if x2 > maxX { maxX = x2 }
        if y < minY { minY = y }
        if y > maxY { maxY = y }
        
        let index = y * width
        for x in x1 ... x2 {
            _data[index + x] = color
        }
    }
    
    func getPixelColor(x: Int, y: Int) -> UInt8 {
        // the range is guranteed by the caller
        // the check below slows down the process
        //if x < 0 || y < 0 || x >= self.width || y >= self.height { return 0}
        
        let index = y * width + x
        return _data[index]
    }
    
    func getPixelColor(index: Int) -> UInt8 {
        return _data[index]
    }
    
    func getData() -> MaskImageData {
        
        let w = maxX >= minX ? maxX - minX + 1 : 0
        let h = maxY >= minY ? maxY - minY + 1 : 0
        let rect = w * h > 0 ? CGRect(x: minX, y: minY, width: w, height: h) : CGRect.zero
        
        let capacity = w * h
        let data = UnsafeMutablePointer<UInt8>.allocate(capacity: capacity)
        
        let start = DispatchTime.now()
        // copy the mask image
        if w == self.width && h == self.height {
            data.initialize(from: _data, count: capacity)
        }
        else {
            for y in 0 ..< h {
                let oIndex = (y + minY) * width +  minX
                let cIndex = y * w
                for x in 0 ..< w {
                    data[cIndex + x] = _data[oIndex + x]
                }
            }
        }
        let end = DispatchTime.now()
        let elapsed = (end.uptimeNanoseconds - start.uptimeNanoseconds) / 1_000_000
        
        print("copy data elapsed: \(elapsed)")
        
        return MaskImageData(data: data, rect: rect)
    }
    
    deinit {
        _data.deallocate()
    }
    
}



/*
// trying to save image data with lines but the performance is not as good as expected
 
import Foundation

class ImageData {
    
    let width: Int
    let height: Int
    
    private var _lines = Dictionary<Int, ImageDataLine>()
    
    init(width: Int, height: Int) {
        self.width = width
        self.height = height
    }
    
    func setPixelColor(x: Int, y: Int) {
        if x < 0 || x >= width || y < 0 || y >= height { return }
        
        var line = _lines[y]
        if line == nil {
            line = ImageDataLine()
            _lines[y] = line
        }
        line?.setPixelColor(x: x)
    }
    
    func getPixelColor(x: Int, y: Int) -> UInt8 {
        if x < 0 || x >= width || y < 0 || y >= height { return 0 }
        
        if let line = _lines[y] {
            return line.getPixelColor(x: x)
        }
        return 0
    }
    
    func getImageData() -> UnsafeMutablePointer<UInt8> {
        let capacity = self.width * self.height
        let data = UnsafeMutablePointer<UInt8>.allocate(capacity: capacity)
        
        data.initialize(repeating: 0, count: capacity)
        
        for (y, line) in _lines {
            for s in line.segments {
                for x in s.start ... s.end {
                    let p = y * self.width + x
                    data[p] = 0xff
                }
            }
        }
        
        return data
    }
}

fileprivate class ImageDataLine {
    
    // the segments are sorted from small to big
    private var _segments = [(start: Int, end: Int)]()
    
    var segments: [(start: Int, end: Int)] {
        get {
            return _segments
        }
    }
    
    func getPixelColor(x: Int) -> UInt8 {
        for (start, end) in _segments {
            if x >= start && x <= end { return 0xff }
        }
        return 0
    }
    
    func setPixelColor(x: Int) {
        if _segments.count == 0 {
            _segments.append((start: x, end: x))
            return
        }
        
        for i in 0 ..< _segments.count {
            var s = _segments[i]
            if x < s.start {
                // x is the smallest
                if x + 1 == s.start {
                    s.start = x
                    break
                }
                _segments.append((start: x, end: x))
                break
            }
            else if x >= s.start && x <= s.end {
                // x is already set
                break
            }
            else if i == _segments.count - 1 {
                // current segment is the last
                if x == s.end + 1 {
                    s.end = x
                    break
                }
                _segments.append((start: x, end: x))
                break
            }
            else {
                var next = _segments[i + 1]
                if x >= next.start {
                    continue
                }
                if x == s.end + 1 {
                    s.end = x
                    if next.start == s.end + 1 {
                        // joined segment
                        s.end = next.end
                        _segments.remove(at: i + 1)
                        break
                    }
                }
                else if x + 1 == next.start {
                    next.start = x
                    break
                }
                else {
                    _segments.insert((start: x, end: x), at: i + 1)
                    break
                }
            }
        }
        
    }
}

*/

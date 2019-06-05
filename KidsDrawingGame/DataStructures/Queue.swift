//
//  Copyright © 2019 zscao. All rights reserved.
//

import Foundation


public class Queue<T> {
    fileprivate typealias Node = LinkedNode<T>
    
    private var _head: Node?
    private var _tail: Node?
    
    public func enqueue(_ element: T) {
        let node = Node(data: element)
        
        if let t = _tail {
            t.next = node
        }
        else {
            _head = node
        }
        _tail = node
    }
    
    public func dequeue() -> T? {
        if let h = _head {
            _head = h.next
            
            // now the queue is empty, set tail to nil
            if _head == nil {
                _tail = nil
            }
            return h.data
        }
        
        return nil
    }
    
    public var isEmpty: Bool {
        get {
            return _head != nil
        }
    }
}

fileprivate class LinkedNode<T> {
    var data: T
    var next: LinkedNode<T>?
    
    public init(data: T) {
        self.data = data
    }
}



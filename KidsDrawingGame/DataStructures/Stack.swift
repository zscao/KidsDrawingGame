//  Copyright © 2019 zscao. All rights reserved.

import Foundation

class Stack<T> {
    private typealias Node = LinkedNode<T>
    
    private var _head: Node?
    
    func push(data: T) {
        let node = Node(data: data)
        
        node.next = _head
        _head = node
    }
    
    func pop() -> T? {
        if let node = _head {
            _head = node.next
            return node.data
        }
        return nil
    }
    
    func isEmpty() -> Bool {
        return _head == nil
    }
}

fileprivate class LinkedNode<T> {
    let data: T
    var next: LinkedNode<T>?
    
    init(data: T) {
        self.data = data
    }
}


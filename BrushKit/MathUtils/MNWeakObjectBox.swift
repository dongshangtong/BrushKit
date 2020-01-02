//
//  WeakObjectBox.swift
//  BrushSDK
//
//  Created by dongshangtong on 2019/12/31.
//  Copyright © 2019 dongshangtong. All rights reserved.
//

import Foundation

final class MNWeakObjectBox {
    
    weak var unboxed: AnyObject?

    init(_ object: AnyObject?) {
        unboxed = object
    }
}

class MNWeakObjectsPool {
    
    private var boxes: [MNWeakObjectBox] = []
    
    // add a object in to pool
    func addObject(_ object: AnyObject) {
        boxes.append(MNWeakObjectBox(object))
    }
    
    // remove boxes of released object
    func clean() {
        boxes = boxes.compactMap { $0.unboxed == nil ? nil : $0 }
    }
    
    // return unreleased objects
    var aliveObjects: [AnyObject] {
        return boxes.compactMap { $0.unboxed }
    }
}


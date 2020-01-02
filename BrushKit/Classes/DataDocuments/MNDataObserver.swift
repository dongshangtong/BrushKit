//
//  MNDataObserver.swift
//  BrushSDK
//
//  Created by dongshangtong on 2019/12/31.
//  Copyright © 2019 dongshangtong. All rights reserved.
//

import Foundation

/// observers for data on the canvas, will get notification on data change
public protocol MNDataObserver: AnyObject {
    
    /// called when a line strip is begin
    func lineStrip(_ strip: MNLineStrip, didBeginOn data: MNCanvasData)
    
    /// called when a element is finished
    func element(_ element: MNCanvasElement, didFinishOn data: MNCanvasData)
    
    /// called when clear the canvas
    func dataDidClear(_ data: MNCanvasData)
    
    /// called when undo
    func dataDidUndo(_ data: MNCanvasData)
    
    /// called when redo
    func dataDidRedo(_ data: MNCanvasData)
    
    /// called when data of canvas have been reseted
    func data(_ data: MNCanvasData, didResetTo newData: MNCanvasData)
}

// empty implementation
public extension MNDataObserver {
    func lineStrip(_ strip: MNLineStrip, didBeginOn data: MNCanvasData) {}
    func element(_ element: MNCanvasElement, didFinishOn data: MNCanvasData) {}
    func dataDidClear(_ data: MNCanvasData) {}
    func dataDidUndo(_ data: MNCanvasData) {}
    func dataDidRedo(_ data: MNCanvasData) {}
    func data(_ data: MNCanvasData, didResetTo newData: MNCanvasData) {}
}

final class MNDataObserverPool: MNWeakObjectsPool {
    
    func addObserver(_ observer: MNDataObserver) {
        super.addObject(observer)
    }
    
    // return unreleased objects
    var aliveObservers: [MNDataObserver] {
        return aliveObjects.compactMap { $0 as? MNDataObserver }
    }
}

// transform message to elements
extension MNDataObserverPool {
    func lineStrip(_ strip: MNLineStrip, didBeginOn data: MNCanvasData) {
        aliveObservers.forEach {
            $0.lineStrip(strip, didBeginOn: data)
        }
    }
    
    func element(_ element: MNCanvasElement, didFinishOn data: MNCanvasData) {
        aliveObservers.forEach {
            $0.element(element, didFinishOn: data)
        }
    }
    
    func dataDidClear(_ data: MNCanvasData) {
        aliveObservers.forEach {
            $0.dataDidClear(data)
        }
    }
    
    func dataDidUndo(_ data: MNCanvasData) {
        aliveObservers.forEach {
            $0.dataDidUndo(data)
        }
    }
    
    func dataDidRedo(_ data: MNCanvasData) {
        aliveObservers.forEach {
            $0.dataDidRedo(data)
        }
    }
    
    func data(_ data: MNCanvasData, didResetTo newData: MNCanvasData) {
        aliveObservers.forEach {
            $0.data(data, didResetTo: newData)
        }
    }
}


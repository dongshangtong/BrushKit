//
//  MNActionObserver.swift
//  BrushSDK
//
//  Created by dongshangtong on 2019/12/31.
//  Copyright © 2019 dongshangtong. All rights reserved.
//

import Foundation
import UIKit


public protocol MNOriginCanvasRenderingDelegate: AnyObject {
    func originCanvas(_ canvas: MNCanvas, didBeginLineAt point: CGPoint, force: CGFloat)
    func originCanvas(_ canvas: MNCanvas, didMoveLineTo point: CGPoint, force: CGFloat)
    func originCanvas(_ canvas: MNCanvas, didFinishLineAt point: CGPoint, force: CGFloat)
}





/// Delegate for rendering
public protocol MNRenderingDelegate: AnyObject {
    func canvas(_ canvas: MNCanvas, shouldRenderTapAt point: CGPoint) -> Bool
    func canvas(_ canvas: MNCanvas, shouldRenderChartlet chartlet: MNChartlet) -> Bool
    // if returns false, the whole line strip will be skiped
    func canvas(_ canvas: MNCanvas, shouldBeginLineAt point: CGPoint, force: CGFloat) -> Bool
}

public extension MNRenderingDelegate {
    func canvas(_ canvas: MNCanvas, shouldRenderTapAt point: CGPoint) -> Bool {
        return true
    }
    
    func canvas(_ canvas: MNCanvas, shouldRenderChartlet chartlet: MNChartlet) -> Bool {
        return true
    }
    
    func canvas(_ canvas: MNCanvas, shouldBeginLineAt point: CGPoint, force: CGFloat) -> Bool {
        return true
    }
}

/// Observer for canvas actions
public protocol MNActionObserver: AnyObject {
    
    func canvas(_ canvas: MNCanvas, didRenderTapAt point: CGPoint)
    func canvas(_ canvas: MNCanvas, didRenderChartlet chartlet: MNChartlet)

    func canvas(_ canvas: MNCanvas, didBeginLineAt point: CGPoint, force: CGFloat)
    func canvas(_ canvas: MNCanvas, didMoveLineTo point: CGPoint, force: CGFloat)
    func canvas(_ canvas: MNCanvas, didFinishLineAt point: CGPoint, force: CGFloat)
    
    func canvas(_ canvas: MNCanvas, didRedrawOn target: MNRenderTarget)
    
    // Only called on ScrollableCanvas
    
    func canvas(_ canvas: MNScrollableCanvas, didZoomTo zoomLevel: CGFloat)
    func canvasDidScroll(_ canvas: MNScrollableCanvas)
}

/// Observer for canvas actions
public extension MNActionObserver {
    
    func canvas(_ canvas: MNCanvas, didRenderTapAt point: CGPoint) {}
    func canvas(_ canvas: MNCanvas, didRenderChartlet chartlet: MNChartlet) {}
    
    func canvas(_ canvas: MNCanvas, didBeginLineAt point: CGPoint, force: CGFloat) {}
    func canvas(_ canvas: MNCanvas, didMoveLineTo point: CGPoint, force: CGFloat) {}
    func canvas(_ canvas: MNCanvas, didFinishLineAt point: CGPoint, force: CGFloat) {}
    
    func canvas(_ canvas: MNCanvas, didRedrawOn target: MNRenderTarget) {}
    
    // Only called on ScrollableCanvas
    
    func canvas(_ canvas: MNScrollableCanvas, didZoomTo zoomLevel: CGFloat) {}
    func canvasDidScroll(_ MNcanvas: MNScrollableCanvas) {}
}

final class MNActionObserverPool: MNWeakObjectsPool {
    
    func addObserver(_ observer: MNActionObserver) {
        super.addObject(observer)
    }
    
    // return unreleased objects
    var aliveObservers: [MNActionObserver] {
        return aliveObjects.compactMap { $0 as? MNActionObserver }
    }
}

extension MNActionObserverPool: MNActionObserver {
    
    func canvas(_ canvas: MNCanvas, didRenderTapAt point: CGPoint) {
        aliveObservers.forEach { $0.canvas(canvas, didRenderTapAt: point) }
    }
    func canvas(_ canvas: MNCanvas, didRenderChartlet chartlet: MNChartlet) {
        aliveObservers.forEach { $0.canvas(canvas, didRenderChartlet: chartlet) }
    }
    
    func canvas(_ canvas: MNCanvas, didBeginLineAt point: CGPoint, force: CGFloat) {
         print(point)
        aliveObservers.forEach { $0.canvas(canvas, didBeginLineAt: point, force: force) }
    }
    
    func canvas(_ canvas: MNCanvas, didMoveLineTo point: CGPoint, force: CGFloat) {
        
        aliveObservers.forEach { $0.canvas(canvas, didMoveLineTo: point, force: force) }
    }
    
    func canvas(_ canvas: MNCanvas, didFinishLineAt point: CGPoint, force: CGFloat) {
        aliveObservers.forEach { $0.canvas(canvas, didFinishLineAt: point, force: force) }
    }

    func canvas(_ canvas: MNCanvas, didRedrawOn target: MNRenderTarget) {
        aliveObservers.forEach { $0.canvas(canvas, didRedrawOn: target) }
    }
    
    // Only called on ScrollableCanvas
    
    func canvas(_ canvas: MNScrollableCanvas, didZoomTo zoomLevel: CGFloat) {
        aliveObservers.forEach { $0.canvas(canvas, didZoomTo: zoomLevel) }
    }

    func canvasDidScroll(_ canvas: MNScrollableCanvas) {
        aliveObservers.forEach { $0.canvasDidScroll(canvas) }
    }
}


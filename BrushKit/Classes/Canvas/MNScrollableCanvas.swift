//
//  MNScrollableCanvas.swift
//  BrushSDK
//
//  Created by dongshangtong on 2019/12/31.
//  Copyright © 2019 dongshangtong. All rights reserved.
//


import UIKit

open class MNScrollableCanvas: MNCanvas {
    
    open override func setup() {
        super.setup()
        
        setupScrollIndicators()
        
        contentSize = bounds.size
        
        pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(handlePinchGestureRecognizer(_:)))
        addGestureRecognizer(pinchGesture)
        
        moveGesture = UIPanGestureRecognizer(target: self, action: #selector(handleMoveGestureRecognizer(_:)))
        moveGesture.minimumNumberOfTouches = 2
        addGestureRecognizer(moveGesture)
    }
    
    /// 如果新值小于当前值，画布的最大缩放比例将导致重绘
    open var maxScale: CGFloat = 5 {
        didSet {
            if maxScale < zoom {
                self.zoom = maxScale
                self.scale = maxScale
                self.redraw()
            }
        }
    }
    
    /// 帆布的实际大小以点数、包装的内容大小表示
    open override var size: CGSize {
        return contentSize
    }
    
   /// 帆布的实际可画尺寸，可能大于当前的界限
    /// contentSize必须在界限大小和5120x5120之间
    open var contentSize: CGSize = .zero {
        didSet {
            updateScrollIndicators()
        }
    }
    
    /// 获取与内容大小相同的snapthot图像
    open override func snapshot() -> UIImage? {
        /// 创建一个新的渲染目标与相同大小的内容，抓拍
        let target = MNSnapshotTarget(canvas: self)
        return target.getImage()
    }
    
    private var pinchGesture: UIPinchGestureRecognizer!
    private var moveGesture: UIPanGestureRecognizer!
    
    private var currentZoomScale: CGFloat = 1
    private var offsetAnchor: CGPoint = .zero
    private var beginLocation: CGPoint = .zero
    
    @objc private func handlePinchGestureRecognizer(_ gesture: UIPinchGestureRecognizer) {
        let location = gesture.location(in: self)
        switch gesture.state {
        case .began:
            beginLocation = location
            offsetAnchor = location + contentOffset
            showScrollIndicators()
        case .changed:
            guard gesture.numberOfTouches >= 2 else {
                return
            }
            var scale = currentZoomScale * gesture.scale * gesture.scale
            scale = scale.valueBetween(min: 1, max: maxScale)
            self.zoom = scale
            self.scale = zoom
            
            var offset = offsetAnchor * (scale / currentZoomScale) - location
            offset = offset.between(min: .zero, max: maxOffset)
            let offsetChanged = contentOffset == offset
            contentOffset = offset
            
            redraw()
            updateScrollIndicators()
            
            actionObservers.canvas(self, didZoomTo: zoom)
            if offsetChanged {
                actionObservers.canvasDidScroll(self)
            }

        case .ended: fallthrough
        case .cancelled: fallthrough
        case .failed:
            currentZoomScale = zoom
            hidesScrollIndicators()
            actionObservers.canvas(self, didZoomTo: zoom)
        default: break
        }
    }
    
    @objc private func handleMoveGestureRecognizer(_ gesture: UIPanGestureRecognizer) {
        let location = gesture.location(in: self)
        switch gesture.state {
        case .began:
            offsetAnchor = location + contentOffset
            showScrollIndicators()
        case .changed:
            guard gesture.numberOfTouches >= 2 else {
                return
            }
            contentOffset = (offsetAnchor - location).between(min: .zero, max: maxOffset)
            redraw()
            updateScrollIndicators()
            actionObservers.canvasDidScroll(self)
        default: hidesScrollIndicators()
        }
    }
    
    private var maxOffset: CGPoint {
        return CGPoint(x: contentSize.width * zoom - bounds.width, y: contentSize.height * zoom - bounds.height)
    }
    
    // MARK: - 滚动指标
    
    /// 滚动时显示指示器，如UIScrollView
    
    // defaults to true if width of contentSize is larger than bounds
    open var showHorizontalScrollIndicator = true
    
    // defaults to true if height of contentSize is larger than bounds
    open var showVerticalScrollIndicator = true
    
    private weak var horizontalScrollIndicator: UIView!
    private weak var verticalScrollIndicator: UIView!
    
    private func setupScrollIndicators() {
        
        // horizontal scroll indicator
        let horizontalScrollIndicator = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
        horizontalScrollIndicator.layer.cornerRadius = 2
        horizontalScrollIndicator.clipsToBounds = true
        addSubview(horizontalScrollIndicator)
        self.horizontalScrollIndicator = horizontalScrollIndicator
        
        // vertical scroll indicator
        let verticalScrollIndicator = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
        verticalScrollIndicator.layer.cornerRadius = 2
        verticalScrollIndicator.clipsToBounds = true
        addSubview(verticalScrollIndicator)
        self.verticalScrollIndicator = verticalScrollIndicator
        
        hidesScrollIndicators()
    }
    
    private func updateScrollIndicators() {
        
        let showHorizontal = showHorizontalScrollIndicator && contentSize.width > bounds.width
        horizontalScrollIndicator?.isHidden = !showHorizontal
        if showHorizontal {
            updateHorizontalScrollIndicator()
        }
        
        let showVertical = showVerticalScrollIndicator && contentSize.height > bounds.height
        verticalScrollIndicator.isHidden = !showVertical
        if showVertical {
            updateVerticalScrollIndicator()
        }
    }
    
    private func updateHorizontalScrollIndicator() {
        let ratio = bounds.width / contentSize.width / zoom
        let offsetRatio = contentOffset.x / contentSize.width / zoom
        let width = bounds.width - 12
        let frame = CGRect(x: offsetRatio * width + 4, y: bounds.height - 6, width: width * ratio, height: 4)
        horizontalScrollIndicator.frame = frame
    }
    
    private func updateVerticalScrollIndicator() {
        let ratio = bounds.height / contentSize.height / zoom
        let offsetRatio = contentOffset.y / contentSize.height / zoom
        let height = bounds.height - 12
        let frame = CGRect(x: bounds.width - 6, y: height * offsetRatio + 4, width: 4, height: height * ratio)
        verticalScrollIndicator.frame = frame
    }
    
    private func showScrollIndicators() {
        horizontalScrollIndicator.alpha = 0.8
        verticalScrollIndicator.alpha = 0.8
    }
    
    private func hidesScrollIndicators() {
        UIView.animate(withDuration: 0.1, delay: 0, options: [.curveEaseInOut, .beginFromCurrentState], animations: {
            self.horizontalScrollIndicator.alpha = 0
            self.verticalScrollIndicator.alpha = 0
        })
    }
}

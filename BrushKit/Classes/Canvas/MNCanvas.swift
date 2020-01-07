//
//  MNCanvas.swift
//  BrushSDK
//
//  Created by dongshangtong on 2019/12/31.
//  Copyright © 2019 dongshangtong. All rights reserved.
//

import UIKit

open class MNCanvas: MNMetalView {
    // MARK: - Brushes

    /// 默认的圆点笔刷，将不会显示在registeredbrush
    open var defaultBrush: MNBrush!

    /// 打印机在画布上打印图像纹理
    open private(set) var printer: Printer!

    /// 画布的实际大小以点为单位，可能大于当前的边界
    /// 大小必须在界限大小和5120x5120之间
    open var size: CGSize {
        return drawableSize / contentScaleFactor
    }

    // delegate & observers

    open weak var originCanvasDelegate: MNOriginCanvasRenderingDelegate?

    open weak var renderingDelegate: MNRenderingDelegate?

    internal var actionObservers = MNActionObserverPool()

    // 添加一个观察者来观察数据变化，观察者不被保留
    open func addObserver(_ observer: MNActionObserver) {
        // 纯空对象
        actionObservers.clean()
        actionObservers.addObserver(observer)
    }

    /// 用图像数据注册一个笔刷
    ///
    /// - Parameter texture: 画笔纹理数据
    /// - Returns: 注册刷
    @discardableResult open func registerBrush<T: MNBrush>(name: String? = nil, from data: Data) throws -> T {
        let texture = try makeTexture(with: data)
        let brush = T(name: name, textureID: texture.id, target: self)
        registeredBrushes.append(brush)
        return brush
    }

    /// 用图像数据注册一个笔刷
    ///
    /// - Parameter file: 画笔纹理文件
    /// - Returns: 注册刷
    @discardableResult open func registerBrush<T: MNBrush>(name: String? = nil, from file: URL) throws -> T {
        let data = try Data(contentsOf: file)
        return try registerBrush(name: name, from: data)
    }

    /// 注册一个新的画笔与纹理已经注册在这个画布上
    ///
    /// - Parameter textureID: 纹理的id，如果设置为nil或没有找到纹理id，将使用默认的圆形纹理
    open func registerBrush<T: MNBrush>(name: String? = nil, textureID: String? = nil) throws -> T {
        let brush = T(name: name, textureID: textureID, target: self)
        registeredBrushes.append(brush)
        return brush
    }

    /// 用于绘制的当前画笔
    /// 只有注册刷过的才可以设置为当前
    /// 从registeredbrush获取一个笔刷，并调用它的use()方法使其当前
    open internal(set) var currentBrush: MNBrush!

    /// All registered brushes
    open private(set) var registeredBrushes: [MNBrush] = []

    /// 按名字找一把刷子
    /// 如果提供的名称的笔刷不存在，则返回
    open func findBrushBy(name: String?) -> MNBrush? {
        return registeredBrushes.first { $0.name == name }
    }

    /// All textures created by this canvas
    open private(set) var textures: [MNTexture] = []

    /// 创建纹理并用ID缓存它
    ///
    /// - Parameters:
    ///   - data: 纹理的图像数据
    ///   - id: 纹理的id，如果没有提供，将生成
    /// - Returns: 创建的纹理，如果提供的id已经存在，则返回现有的纹理
    @discardableResult
    open override func makeTexture(with data: Data, id: String? = nil) throws -> MNTexture {
        // 如果设置了id，请确保此id不存在
        if let id = id, let exists = findTexture(by: id) {
            return exists
        }
        let texture = try super.makeTexture(with: data, id: id)
        textures.append(texture)
        return texture
    }

    /// find texture by textureID
    open func findTexture(by id: String) -> MNTexture? {
        return textures.first { $0.id == id }
    }

    @available(*, deprecated, message: "this property will be removed soon, set the property forceSensitive on brush to 0 instead, changing this value will cause no affects")
    open var forceEnabled: Bool = true

    // MARK: - Zoom and scale

    /// the scale level of view, all things scales
    open var scale: CGFloat {
        get {
            return screenTarget?.scale ?? 1
        }
        set {
            screenTarget?.scale = newValue
        }
    }

    /// the zoom level of render target, only scale render target
    open var zoom: CGFloat {
        get {
            return screenTarget?.zoom ?? 1
        }
        set {
            screenTarget?.zoom = newValue
        }
    }

    /// the offset of render target with zoomed size
    open var contentOffset: CGPoint {
        get {
            return screenTarget?.contentOffset ?? .zero
        }
        set {
            screenTarget?.contentOffset = newValue
        }
    }

    // setup gestures
    open var paintingGesture: MNPaintingGestureRecognizer?
    open var tapGesture: UITapGestureRecognizer?

    /// 这将设置画布和手势，默认刷
    open override func setup() {
        super.setup()

        /// initialize default brush
        defaultBrush = MNBrush(name: "brush.default", textureID: nil, target: self)
        currentBrush = defaultBrush

        /// initialize printer
        printer = Printer(name: "brush.printer", textureID: nil, target: self)

        data = MNCanvasData()
    }

    /// 获取当前画布上的快照并导出图像
    open func snapshot() -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, contentScaleFactor)
        drawHierarchy(in: bounds, afterScreenUpdates: true)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }

    /// 清除画布上的所有东西
    ///
    /// - Parameter display: 如果此设置为true，则重新绘制画布
    open override func clear(display: Bool = true) {
        super.clear(display: display)

        if display {
            data.appendClearAction()
        }
    }

    open override func layoutSubviews() {
        super.layoutSubviews()
        redraw()
    }

    // MARK: - Document

    public private(set) var data: MNCanvasData!

    /// reset data on canvas, this method will drop the old data object and create a new one.
    /// - Attention: SAVE your data before call this method!
    /// - Parameter redraw: if should redraw the canvas after, defaults to true
    open func resetData(redraw: Bool = true) {
        let oldData = data!
        let newData = MNCanvasData()
        // link registered observers to new data
        newData.observers = data.observers
        data = newData
        if redraw {
            self.redraw()
        }
        data.observers.data(oldData, didResetTo: newData)
    }

    public func undo() {
        if let data = data, data.undo() {
            redraw()
        }
    }

    public func redo() {
        if let data = data, data.redo() {
            redraw()
        }
    }

    /// redraw elemets in document
    /// - Attention: thie method must be called on main thread
    open func redraw(on target: MNRenderTarget? = nil) {
        guard let target = target ?? screenTarget else {
            return
        }

        data.finishCurrentElement()

        target.updateBuffer(with: drawableSize)
        target.clear()

        data.elements.forEach { $0.drawSelf(on: target) }

        /// submit commands
        target.commitCommands()

        actionObservers.canvas(self, didRedrawOn: target)
    }

    // MARK: - Bezier

    // 使用bezier路径优化笔触，默认为true
    // private var enableBezierPath = true
    private var bezierGenerator = MNBezierGenerator()

    // MARK: - Drawing Actions

    private var lastRenderedPan: Pan?

    private func pushPoint(_ point: CGPoint, to bezier: MNBezierGenerator, force: CGFloat, isEnd: Bool = false) {
        var lines: [MNLine] = []
        let vertices = bezier.pushPoint(point)
        guard vertices.count >= 2 else {
            return
        }
        var lastPan = lastRenderedPan ?? Pan(point: vertices[0], force: force)
        let deltaForce = (force - (lastRenderedPan?.force ?? force)) / CGFloat(vertices.count)
        for i in 1 ..< vertices.count {
            let p = vertices[i]
            let pointStep = currentBrush.pointStep
            if // end point of line
                (isEnd && i == vertices.count - 1) ||
                // ignore step
                pointStep <= 1 ||
                // distance larger than step
                (pointStep > 1 && lastPan.point.distance(to: p) >= pointStep) {
                let force = lastPan.force + deltaForce
                let pan = Pan(point: p, force: force)
                let line = currentBrush.makeLine(from: lastPan, to: pan)
                lines.append(contentsOf: line)
                lastPan = pan
                lastRenderedPan = pan
            }
        }
        render(lines: lines)
    }

    // MARK: - 呈现, 渲染

    open func render(lines: [MNLine]) {
        data.append(lines: lines, with: currentBrush)
        // 创建一个临时的线带，并绘制在画布上
        MNLineStrip(lines: lines, brush: currentBrush).drawSelf(on: screenTarget)
        /// 提交命令
        screenTarget?.commitCommands()
    }

    open func renderTap(at point: CGPoint, to: CGPoint? = nil) {
        guard renderingDelegate?.canvas(self, shouldRenderTapAt: point) ?? true else {
            return
        }

        let brush = currentBrush!
        let lines = brush.makeLine(from: point, to: to ?? point)
        render(lines: lines)
    }

    /// 在画布上画一张图表
    ///
    /// - Parameters:
    ///   - point: 绘制图表的位置
    ///   - size:  大小的纹理
    ///   - textureID: 用于绘图的纹理id
    ///   - rotation: 绘制纹理的旋转角度
    open func renderChartlet(at point: CGPoint, size: CGSize, textureID: String, rotation: CGFloat = 0) {
        let chartlet = MNChartlet(center: point, size: size, textureID: textureID, angle: rotation, canvas: self)

        guard renderingDelegate?.canvas(self, shouldRenderChartlet: chartlet) ?? true else {
            return
        }

        data.append(chartlet: chartlet)
        chartlet.drawSelf(on: screenTarget)
        screenTarget?.commitCommands()
        setNeedsDisplay()

        actionObservers.canvas(self, didRenderChartlet: chartlet)
    }

    // MARK: - Touches

    open override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let pan = Pan(touch: touch, on: self)
        originTouchesBegan(pan, with: false)
    }

    open override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let pan = Pan(touch: touch, on: self)
        originTouchesMoved(pan, with: false)
    }

    open override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let pan = Pan(touch: touch, on: self)
        originTouchesEnded(pan, with: false)
    }

    // 原点开始 --
    // offline -- 是否是离线笔记 ; false 表示离线笔记
    open func originTouchesBegan(_ pan: Pan, with offline: Bool) {
        lastRenderedPan = pan
        guard renderingDelegate?.canvas(self, shouldBeginLineAt: pan.point, force: pan.force) ?? true else {
            return
        }

        bezierGenerator.begin(with: pan.point)
        pushPoint(pan.point, to: bezierGenerator, force: pan.force)
        actionObservers.canvas(self, didBeginLineAt: pan.point, force: pan.force)

        if (originCanvasDelegate != nil) && offline == false {
            originCanvasDelegate?.originCanvas(self, didBeginLineAt: pan.point, force: pan.force)
        }
    }

    // 原点移动过程
    // offline -- 是否是离线笔记 ; false 表示离线笔记
    open func originTouchesMoved(_ pan: Pan, with offline: Bool) {
        guard bezierGenerator.points.count > 0 else { return }
        guard pan.point != lastRenderedPan?.point else { return }
        pushPoint(pan.point, to: bezierGenerator, force: pan.force)
        actionObservers.canvas(self, didMoveLineTo: pan.point, force: pan.force)
        if (originCanvasDelegate != nil) && offline == false {
            originCanvasDelegate?.originCanvas(self, didMoveLineTo: pan.point, force: pan.force)
        }
    }

    // 原点结束
    // offline -- 是否是离线笔记 ; false 表示离线笔记
    open func originTouchesEnded(_ pan: Pan, with offline: Bool) {
        defer {
            bezierGenerator.finish()
            lastRenderedPan = nil
            data.finishCurrentElement()
        }

        let count = bezierGenerator.points.count

        if count >= 3 {
            pushPoint(pan.point, to: bezierGenerator, force: pan.force, isEnd: true)
        } else if count > 0 {
            renderTap(at: bezierGenerator.points.first!, to: bezierGenerator.points.last!)
        }

        let unfishedLines = currentBrush.finishLineStrip(at: Pan(point: pan.point, force: pan.force))
        if unfishedLines.count > 0 {
            render(lines: unfishedLines)
        }
        actionObservers.canvas(self, didFinishLineAt: pan.point, force: pan.force)

        if (originCanvasDelegate != nil) && offline == false {
            originCanvasDelegate?.originCanvas(self, didFinishLineAt: pan.point, force: pan.force)
        }
    }
}

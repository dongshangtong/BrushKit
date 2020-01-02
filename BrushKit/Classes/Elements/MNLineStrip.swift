//
//  MNLineStrip.swift
//  BrushSDK
//
//  Created by dongshangtong on 2019/12/31.
//  Copyright © 2019 dongshangtong. All rights reserved.
//

import Foundation
import Metal
import UIKit

/// a line strip with lines and brush info
open class MNLineStrip: MNCanvasElement {
    
    /// element index
    public var index: Int = 0
    
    /// identifier of bursh used to render this line strip
    public var brushName: String?
    
    /// default color
    // this color will be used when line's color not set
    public var color: MNColor
    
    /// line units of this line strip, avoid change this value directly when drawing.
    public var lines: [MNLine] = []
    
    /// brush used to render this line strip
    open weak var brush: MNBrush? {
        didSet {
            brushName = brush?.name
        }
    }
    
    public init(lines: [MNLine], brush: MNBrush) {
        self.lines = lines
        self.brush = brush
        self.brushName = brush.name
        self.color = brush.renderingColor
        remakBuffer(rotation: brush.rotation)
    }
    
    open func append(lines: [MNLine]) {
        self.lines.append(contentsOf: lines)
        vertex_buffer = nil
    }
    
    public func drawSelf(on target: MNRenderTarget?) {
        brush?.render(lineStrip: self, on: target)
    }
    
    /// get vertex buffer for this line strip, remake if not exists
    open func retrieveBuffers(rotation: MNBrush.Rotation) -> MTLBuffer? {
        if vertex_buffer == nil {
            remakBuffer(rotation: rotation)
        }
        return vertex_buffer
    }
    
    /// count of vertexes, set when remake buffers
    open private(set) var vertexCount: Int = 0
    
    private var vertex_buffer: MTLBuffer?
    
    private func remakBuffer(rotation: MNBrush.Rotation) {
        
        guard lines.count > 0 else {
            return
        }
        
        var vertexes: [Point] = []
        
        lines.forEach { (line) in
            let scale = brush?.target?.contentScaleFactor ?? UIScreen.main.nativeScale
            var line = line
            line.begin = line.begin * scale
            line.end = line.end * scale
            let count = max(line.length / line.pointStep, 1)
            
            for i in 0 ..< Int(count) {
                let index = CGFloat(i)
                let x = line.begin.x + (line.end.x - line.begin.x) * (index / count)
                let y = line.begin.y + (line.end.y - line.begin.y) * (index / count)
                
                var angle: CGFloat = 0
                switch rotation {
                case let .fixed(a): angle = a
                case .random: angle = CGFloat.random(in: -CGFloat.pi ... CGFloat.pi)
                case .ahead: angle = line.angle
                }
                
                vertexes.append(Point(x: x, y: y, color: line.color ?? color, size: line.pointSize * scale, angle: angle))
            }
        }
        
        vertexCount = vertexes.count
        vertex_buffer = sharedDevice?.makeBuffer(bytes: vertexes, length: MemoryLayout<Point>.stride * vertexCount, options: .cpuCacheModeWriteCombined)
    }
    
    // MARK: - Coding

    enum CodingKeys: String, CodingKey {
        case index
        case brush
        case lines
        case color
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        index = try container.decode(Int.self, forKey: .index)
        brushName = try container.decode(String.self, forKey: .brush)
        lines = try container.decode([MNLine].self, forKey: .lines)
        color = try container.decode(MNColor.self, forKey: .color)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(index, forKey: .index)
        try container.encode(brushName, forKey: .brush)
        try container.encode(lines, forKey: .lines)
        try container.encode(color, forKey: .color)
    }
}


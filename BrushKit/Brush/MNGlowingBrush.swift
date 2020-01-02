//
//  MNGlowingBrush.swift
//  BrushSDK
//
//  Created by dongshangtong on 2019/12/31.
//  Copyright © 2019 dongshangtong. All rights reserved.
//

import Foundation
import CoreGraphics
import Metal
import UIKit

public final class MNGlowingBrush: MNBrush {
        
    /// size proportion of the core line, must be set between 0 ~ 1, defaults to 0.5
    public var coreProportion: CGFloat = 0.25

    /// color of core lines, defaults to white
    public var coreColor: UIColor = .white {
        didSet {
            subBrush.color = coreColor
        }
    }
    
    // MARK: - Overrides
    // make properties of subbrush synch with it's parent
    
    public override var pointSize: CGFloat {
        didSet {
            subBrush.pointSize = pointSize * coreProportion
        }
    }
    public override var pointStep: CGFloat {
        didSet {
            subBrush.pointStep = 1
        }
    }
    public override var forceSensitive: CGFloat {
        didSet {
            subBrush.forceSensitive = forceSensitive
        }
    }
    public override var scaleWithCanvas: Bool {
        didSet {
            subBrush.scaleWithCanvas = scaleWithCanvas
        }
    }
    public override var forceOnTap: CGFloat {
        didSet {
            subBrush.forceOnTap = forceOnTap
        }
    }


    // sub brush to render core white line
    private var subBrush: MNBrush!

    private var pendingCoreLines: [MNLine] = []
    
    // designed initializer, will be called by target when reigster called
    // identifier is not necessary if you won't save the content of your canvas to file
    required public init(name: String?, textureID: String?, target: MNCanvas) {
        super.init(name: name, textureID: textureID, target: target)
        subBrush = MNBrush(name: self.name + ".sub", textureID: nil, target: target)
        subBrush.color = coreColor
        subBrush.opacity = 1
    }

    /// get a line with specified begin and end location
    public override func makeLine(from: CGPoint, to: CGPoint, force: CGFloat? = nil, uniqueColor: Bool = false) -> [MNLine] {
        let shadowLines = super.makeLine(from: from, to: to, force: force)
        let delta = (pointSize * (1 - coreProportion)) / 2
        var coreLines: [MNLine] = []
        
        while let first = pendingCoreLines.first?.begin, first.distance(to: from) >= delta {
            coreLines.append(pendingCoreLines.removeFirst())
        }
        let lines = subBrush.makeLine(from: from, to: to, force: force, uniqueColor: true)
        pendingCoreLines.append(contentsOf: lines)
        return shadowLines + coreLines
    }
    
    public override func finishLineStrip(at end: Pan) -> [MNLine] {
        let lines = pendingCoreLines
        pendingCoreLines.removeAll()
        return lines
    }
}



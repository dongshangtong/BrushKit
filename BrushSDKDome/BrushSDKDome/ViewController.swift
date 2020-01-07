//
//  ViewController.swift
//  BrushSDKDome
//
//  Created by dongshangtong on 2020/1/2.
//  Copyright © 2020 dongshangtong. All rights reserved.
//

import SnapKit
import UIKit
//import BrushKit

class ViewController: UIViewController {
    var canvas = MNScrollableCanvas(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))

    private func registerBrush(with imageName: String) throws -> MNBrush {
        let texture = try canvas.makeTexture(with: UIImage(named: imageName)!.pngData()!)
        return try canvas.registerBrush(name: imageName, textureID: texture.id)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        view.addSubview(canvas)
        canvas.data.addObserver(self)
        canvas.originCanvasDelegate = self
        
        do {
//            let pen = canvas.defaultBrush!
//            pen.name = "Pen"
//            pen.opacity = 0.1
//            pen.pointSize = 5
//            pen.pointStep = 0.5
//            pen.color = .blue
//            pen.use()
            
            
            let pencil = try registerBrush(with: "pencil")
               pencil.rotation = .random
               pencil.pointSize = 10
               pencil.pointStep = 5
               pencil.forceSensitive = 0.3
               pencil.opacity = 0.5
               pencil.color = .gray
               pencil.use()

        } catch {
            print("KKK")
        }
    }
}



extension ViewController: MNDataObserver {
    /// called when a line strip is begin -- 当线段开始时调用
    func lineStrip(_ strip: MNLineStrip, didBeginOn data: MNCanvasData) {
//        self.redoButton.isEnabled = false
        
//        print(strip.lines)
    }
    
    /// called when a element is finished -- 在元素完成时调用
    func element(_ element: MNCanvasElement, didFinishOn data: MNCanvasData) {
//        self.undoButton.isEnabled = true
        
//        print(element.self)
//
//        print(data.elements.count)
    }
    
    /// callen when clear the canvas -- 当清除画布时调用
    func dataDidClear(_ data: MNCanvasData) {
        
    }
    
    /// callen when undo -- callen当撤销
    func dataDidUndo(_ data: MNCanvasData) {
//        self.undoButton.isEnabled = true
//        self.redoButton.isEnabled = data.canRedo
    }
    
    /// callen when redo --callen当重做
    func dataDidRedo(_ data: MNCanvasData) {
//        self.undoButton.isEnabled = true
//        self.redoButton.isEnabled = data.canRedo
    }
}






extension  ViewController: MNOriginCanvasRenderingDelegate {

    func originCanvas(_ canvas: MNCanvas, didBeginLineAt point: CGPoint, force: CGFloat) {
        
        print("didBeginLineAt")
    }
    
    
    func originCanvas(_ canvas: MNCanvas, didMoveLineTo point: CGPoint, force: CGFloat) {
        
        print(point)
    }
    
    func originCanvas(_ canvas: MNCanvas, didFinishLineAt point: CGPoint, force: CGFloat) {
        
           print("didFinishLineAt")
    }


}


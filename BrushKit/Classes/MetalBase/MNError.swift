//
//  MNError.swift
//  BrushSDK
//
//  Created by dongshangtong on 2019/12/31.
//  Copyright © 2019 dongshangtong. All rights reserved.
//

import Foundation

public enum MLError: Error {
    
    /// the requested file does not exists
    case fileNotExists(String)
    
    /// file is damaged
    case fileDamaged
    
    /// directory for saving must not have any ohter contents
    case directoryNotEmpty(URL)
    
    /// running MaLiang on a Similator
    case simulatorUnsupported
}

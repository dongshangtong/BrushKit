//
//  MNDocument.swift
//  BrushSDK
//
//  Created by dongshangtong on 2019/12/31.
//  Copyright © 2019 dongshangtong. All rights reserved.
//

import Foundation
import CoreGraphics

/// base infomation for saved documents
public struct MNDocumentInfo: Codable {
    
    /// default infomation read form info.plist
    public static let `default` = MNDocumentInfo()
    
    /// identifier for this file
    public var identifier: String?
    
    /// format version of this document, equal to the library version
    public let version: String
    
    /// the app whitch uses MaLiang to generate this file
    public let app: BundleInfo?
    
    /// library info of MaLiang used in current app
    public let library: BundleInfo?
    
    /// number of lines in document
    public var lines: Int = 0
    
    /// number of chartlets in document
    public var chartlets: Int = 0
    
    /// number of custom textures used for chartlets and so on
    public var textures: Int = 0
    
    /// initialize a document info with specified identifier, an uuid will be used if passed nil
    public init(identifier: String? = nil) {
        self.identifier = identifier ?? UUID().uuidString
        library = try? Bundle(for: MNCanvas.classForCoder()).readInfo()
        app = try? Bundle.main.readInfo()
        version = library?.version ?? "unknown"
    }
}

/// contents' vector data on the canvas
public struct MNCanvasContent: Codable {
    
    /// content size of canvas
    public var size: CGSize?
    
    /// all linestrips
    public var lineStrips: [MNLineStrip] = []
    
    /// chatlets
    public var chartlets: [MNChartlet] = []
    
    public init(size: CGSize?, lineStrips: [MNLineStrip], chartlets: [MNChartlet]) {
        self.size = size
        self.lineStrips = lineStrips
        self.chartlets = chartlets
    }
}

/// base infomation for bundle from info.plist
public struct BundleInfo: Codable {
    public var name: String
    public var version: String
    public var identifier: String
}

extension Bundle {
    /// read base infomation from info.plist
    func readInfo() throws -> BundleInfo {
        guard let file = url(forResource: "Info", withExtension: "plist") else {
            throw MLError.fileNotExists("Info.plist")
        }
        let data = try Data(contentsOf: file)
        let info = try PropertyListDecoder().decode(__Info.self, from: data)
        return info.makePublic()
    }
    
    private struct __Info: Codable {
        var name: String
        var version: String
        var identifier: String
        
        enum CodingKeys: String, CodingKey {
            case name = "CFBundleName"
            case version = "CFBundleShortVersionString"
            case identifier = "CFBundleIdentifier"
        }
        
        func makePublic() -> BundleInfo {
            return BundleInfo(name: name, version: version, identifier: identifier)
        }
    }
}


//
//  TilePosition.swift
//  TiledLayerFlashingDemo
//
//  Created by Mario Galijot on 30.05.2025..
//

import Foundation

struct TilePosition: Hashable {
    let row: Int
    let col: Int
    let lod: Int
}

extension TilePosition: CustomDebugStringConvertible {
    var debugDescription: String {
        "(X:\(col), Y:\(row), LOD:\(lod))"
    }
}

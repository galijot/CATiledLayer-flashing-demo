//
//  TileProvider.swift
//  TiledLayerFlashingDemo
//
//  Created by Mario Galijot on 30.05.2025..
//

import UIKit
import os

protocol TileProviderDelegate: AnyObject {
    func reloadTile(at position: TilePosition)
}

final class TileProvider {
    // MARK: - Properties
    private var preparedTiles: OSAllocatedUnfairLock<Set<TilePosition>> = .init(initialState: [])
    
    weak var delegate: TileProviderDelegate?
}

// MARK: - Controls
extension TileProvider {
    func tile(at position: TilePosition) -> UIImage? {
        if !preparedTiles.withLock({ $0.contains(position) }) {
            let delay = DispatchTimeInterval
                .milliseconds(Int.random(in: 200...1000))
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
                _ = self?.preparedTiles.withLock { $0.insert(position) }
                self?.delegate?.reloadTile(at: position)
            }
            
            return nil
        }
        
        let color: UIColor = switch position.lod {
        case 0: .blue
        case 1: .brown
        case 2: .gray
        case 3: .green
        case 4: .yellow
        default: .magenta
        }
        
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 1, height: 1))
        return renderer.image { context in
            color.set()
            context.fill(CGRect(x: 0, y: 0, width: 1, height: 1))
        }
    }
}

//
//  TiledView.swift
//  TiledLayerFlashingDemo
//
//  Created by Mario Galijot on 30.05.2025..
//

import UIKit

final class TiledView: UIView {
    // MARK: - Properties
    private static let tileSize = CGSize(width: 400, height: 400)
    
    private let tileProvider: TileProvider
    private var boundsCopy: CGRect = .zero
    
    override static var layerClass: AnyClass {
        return CATiledLayer.self
    }
    
    var tiledLayer: CATiledLayer {
        return self.layer as! CATiledLayer
    }
    
    override var contentScaleFactor: CGFloat {
        didSet {
            super.contentScaleFactor = 1
        }
    }
    
    // MARK: - Init
    init(tileProvider: TileProvider) {
        self.tileProvider = tileProvider
        
        // This is needed so that `boundsCopy` could be populated with the
        // correct value in `didMoveToSuperview`, and this **needs** to match
        // the constraint constants in `ViewController`.
        // This is needed just in this demo project; my production app uses a
        // pre-calculated size based on the size of the full-resolution image,
        // but I'm simplifying things here for demo purposes.
        let frame = CGRect(x: 0, y: 0, width: 2000, height: 2000)
        super.init(frame: frame)
        
        tileProvider.delegate = self
        
        tiledLayer.levelsOfDetail = 1
        tiledLayer.levelsOfDetailBias = 5
        tiledLayer.tileSize = Self.tileSize
    }
    
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        self.boundsCopy = bounds
    }
    
    override func draw(_ rect: CGRect) {
        guard
            let currentContext = UIGraphicsGetCurrentContext(),
            boundsCopy != .zero
        else { return }
        
        let scale: CGFloat = currentContext.ctm.a
        let lod = Int(log2(scale))
        
        var tileSize = Self.tileSize
        tileSize.width /= scale
        tileSize.height /= scale
        
        let firstColumn = Int(floor(rect.minX / tileSize.width))
        let lastColumn = Int(floor((rect.maxX - 1) / tileSize.width))
        let firstRow = Int(floor(rect.minY / tileSize.height))
        let lastRow = Int(floor((rect.maxY - 1) / tileSize.height))
        
        guard lastRow >= firstRow && lastColumn >= firstColumn else { return }
        
        for row in firstRow...lastRow {
            for col in firstColumn...lastColumn {
                let position = TilePosition(row: row, col: col, lod: lod)
                
                guard let tile = tileProvider.tile(at: position) else { return }
                
                var tileRect = CGRect(
                    x: tileSize.width * CGFloat(col),
                    y: tileSize.height * CGFloat(row),
                    width: tileSize.width,
                    height: tileSize.height
                )
                tileRect = boundsCopy.intersection(tileRect)
                
                print("draw at position: \(position), tile rect: \(tileRect)")
                
                tile.draw(in: tileRect)
            }
        }
    }
}

// MARK: - TileProviderDelegate
extension TiledView: TileProviderDelegate {
    func reloadTile(at position: TilePosition) {
        // ensuring that, once a reload was requested, tile surely exists.
        assert(tileProvider.tile(at: position) != nil)
        
        let tileSize: CGSize = Self.tileSize
        let lodScale: CGFloat = pow(2.0, CGFloat(position.lod))
        let scaledTileWidth: CGFloat = tileSize.width / lodScale
        let scaledTileHeight: CGFloat = tileSize.height / lodScale
        
        var tileRect = CGRect(
            x: scaledTileWidth * CGFloat(position.col),
            y: scaledTileHeight * CGFloat(position.row),
            width: scaledTileWidth,
            height: scaledTileHeight
        )
        tileRect = boundsCopy.intersection(tileRect)
        
        print("reload at position: \(position), tile rect: \(tileRect)")
        
        if tileRect.isEmpty {
            return assertionFailure()
        }
        
        // FIXME
        
        /* Option 1: reload specific rect
         This causes whole view to reload, as if calling setNeedsDisplay() */
        
        tiledLayer.setNeedsDisplay(tileRect)
        
        /* Option 2: cut 1x1 rect in the center of the `tileRect`.
         
         If the issue is in the `tileRect` covering a large area,
         which thus results in whole view reloading, then using such a
         small rect shouldn't cause it, but it does. */
        
//        let centerRect = CGRect(
//            origin: CGPoint(x: tileRect.midX, y: tileRect.midY),
//            size: CGSize(width: 1, height: 1)
//        )
//        tiledLayer.setNeedsDisplay(centerRect)
        
        
        /* Option 3: re-apply layer's contents after setNeedsDisplay(_:)
         This solves the issue, but by modifying `contents` property,
         which docs clearly state we shouldn't do. */
        
//        let c = tiledLayer.contents
//        tiledLayer.setNeedsDisplay(tileRect)
//        tiledLayer.contents = c
        
        
        /* Option 4: re-apply layer's contents after setNeedsDisplay().
         Demonstrates how setNeedsDisplay() behaves same as setNeedsDisplay(_:). */
        
//        let c = tiledLayer.contents
//        tiledLayer.setNeedsDisplay()
//        tiledLayer.contents = c
    }
}

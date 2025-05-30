//
//  ViewController.swift
//  TiledLayerFlashingDemo
//
//  Created by Mario Galijot on 30.05.2025..
//

import UIKit

final class ViewController: UIViewController {
    // MARK: - Properties
    private let scrollView = UIScrollView()
    private let tileProvider = TileProvider()
    private let tiledView: TiledView
    
    init() {
        tiledView = TiledView(tileProvider: tileProvider)
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        prepareUI()
        setupUI()
    }
}

// MARK: - UI
private extension ViewController {
    func prepareUI() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        
        tiledView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(tiledView)
        
        let contentGuide: UILayoutGuide = scrollView.contentLayoutGuide
        
        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: scrollView.topAnchor),
            view.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            view.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            
            tiledView.widthAnchor.constraint(equalToConstant: 2000),
            tiledView.heightAnchor.constraint(equalToConstant: 2000),
            
            tiledView.topAnchor.constraint(equalTo: contentGuide.topAnchor),
            tiledView.leadingAnchor.constraint(equalTo: contentGuide.leadingAnchor),
            tiledView.trailingAnchor.constraint(equalTo: contentGuide.trailingAnchor),
            tiledView.bottomAnchor.constraint(equalTo: contentGuide.bottomAnchor)
        ])
    }
    
    func setupUI() {
        scrollView.zoomScale = 1
        scrollView.maximumZoomScale = 500
        scrollView.bounces = false
        scrollView.scrollsToTop = false
        scrollView.delegate = self
    }
}

// MARK: - UIScrollViewDelegate
extension ViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return tiledView
    }
}

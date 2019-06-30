//
//  Copyright © 2019 zscao. All rights reserved.
//

import UIKit
import KidsDrawingGame

class ViewController: UIViewController {
    
    private var album = Album()
    
    private var viewMode = ViewMode(color: UIColor.black, backgroundColor: UIColor.white)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        album.addShapes()
        album.addSamples()
        
        setupGalleryView()
    }
    
    private func setupGalleryView() {
        
        let galleryView = GalleryView(frame: self.view.frame)
        galleryView.setup(album: album, viewMode: viewMode)
        
        galleryView.onSelection = { [unowned self, weak galleryView] name in
            galleryView?.removeFromSuperview()
            self.setupDrawingView(pictureName: name)
        }
        self.view.addSubview(galleryView)
//        galleryView.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor, constant: 10)
//        galleryView.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor, constant: 10)
//        galleryView.leftAnchor.constraint(equalTo: view.layoutMarginsGuide.leftAnchor, constant: 10)
//        galleryView.rightAnchor.constraint(equalTo: view.layoutMarginsGuide.rightAnchor, constant: 10)
    }
    
    
    private func setupDrawingView(pictureName: String) {
        
        if let picture = album[pictureName] {
        
            let drawingView = DrawingView(frame: self.view.frame)
            drawingView.setup(picture: picture)
            
            drawingView.onHome = { [unowned self, weak drawingView] in
                drawingView?.removeFromSuperview()
                self.setupGalleryView()
            }
            
            drawingView.alpha = 0
            self.view.addSubview(drawingView)
            UIView.animate(withDuration: 0.5) { [weak drawingView] in
                drawingView?.alpha = 1.0
            }
        }
    }
}


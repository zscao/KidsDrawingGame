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
        
        var galleryView: GalleryView! = GalleryView(frame: self.view.frame)
        galleryView.setup(album: album, viewMode: viewMode)
        
        galleryView.onSelection = { [unowned self] name in
            galleryView.removeFromSuperview()
            galleryView = nil
            self.setupDrawingView(pictureName: name)
        }
        
        self.view.addSubview(galleryView)
    }
    
    
    private func setupDrawingView(pictureName: String) {
        
        if let picture = album[pictureName] {
        
            var drawingView: DrawingView! = DrawingView(frame: self.view.frame)
            drawingView.setup(picture: picture)
            
            drawingView.onHome = { [unowned self] () in
                drawingView.removeFromSuperview()
                drawingView = nil
                self.setupGalleryView()
            }
            
            self.view.addSubview(drawingView)
        }
    }
}


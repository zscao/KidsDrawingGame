//
//  Copyright © 2019 zscao. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    private var album = Album()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        album.addShapes()
        album.addSamples()
        
        setupGalleryView()
    }
    
    private func setupGalleryView() {
        let galleryView = GalleryView(frame: self.view.frame)
        
        galleryView.onSelection = { [unowned self] name in
            galleryView.removeFromSuperview()
            self.setupDrawingView(pictureName: name)
        }
        
        self.view.addSubview(galleryView)
    }
    
    
    private func setupDrawingView(pictureName: String) {
        
        if let picture = album[pictureName] {
        
            let drawingView = DrawingView(frame: self.view.frame)
            drawingView.setup(picture: picture)
            drawingView.onHome = { [unowned self] () in
                drawingView.removeFromSuperview()
                self.setupGalleryView()
            }
            
            self.view.addSubview(drawingView)
        }
    }
}


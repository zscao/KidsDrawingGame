//  Copyright © 2019 zscao. All rights reserved.

import UIKit
import KidsDrawingGame

class GalleryView: UIView, UICollectionViewDataSource, UICollectionViewDelegate {

    private let reuseIdentifier = "galleryItem"
    private var images = [(name: String, image: CALayer)]()
    private var backgroundLayer: BubbleLayer?
    
    var onSelection: ((_ picture: String) -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func willMove(toSuperview newSuperview: UIView?) {
        if newSuperview == nil {
            backgroundLayer?.stop()
        }
        else {
            backgroundLayer?.start()
        }
    }
    
    
    func setup(album: Album, viewMode: ViewMode)
    {
        //self.layer.contents = UIImage(named: "sample1")?.cgImage
        //self.backgroundColor = .blue
        
        setupBackground()
        
        let length = self.frame.width / 3 - 30
        let imageSize = CGSize(width: length, height: length)
        
        for index in 0 ..< album.count {
            let item = album[index]!
            let sketch = Sketch(picture: item.picture)
            
            let scale = sketch.getScale(width: 200, height: 200)
            let layer = sketch.getSketchLayer(strokeColor: viewMode.color.cgColor, lineWidth: 3)
            layer.transform = CATransform3DMakeScale(scale, scale, 1)
            layer.position = CGPoint(x: 100, y: 100)
            images.append((name: item.name, image: layer))            
        }
        
        setupCollectionView(imageSize: imageSize)
    }
    
    private func setupBackground() {
        let bgLayer = BubbleLayer(frame: self.frame)
        self.layer.addSublayer(bgLayer)
        
        backgroundLayer = bgLayer
    }
    
    
    private func setupCollectionView(imageSize: CGSize) {
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 20, left: 10, bottom: 10, right: 10)
        layout.scrollDirection = .vertical
        layout.itemSize = imageSize
        
        let frame = CGRect(origin: CGPoint(x: 0, y: 100), size: CGSize(width: self.frame.width, height: self.frame.height - 200))
        let collectionView = UICollectionView(frame: frame, collectionViewLayout: layout)
        
        collectionView.backgroundColor = .clear
        
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(GalleryItemCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        
        self.addSubview(collectionView)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath as IndexPath) as! GalleryItemCell
        
        let item = images[indexPath.item]
        cell.imageView.layer.addSublayer(item.image)
        cell.name = item.name
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = images[indexPath.item]
        self.onSelection?(item.name)
    }
    
}

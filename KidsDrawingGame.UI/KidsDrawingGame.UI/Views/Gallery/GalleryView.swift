//  Copyright © 2019 zscao. All rights reserved.

import UIKit
import KidsDrawingGame

class GalleryView: UIView, UICollectionViewDataSource, UICollectionViewDelegate {

    private let reuseIdentifier = "galleryItem"
    private var images = [(name: String, image: UIImage)]()
    
    var onSelection: ((_ picture: String) -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func setup(album: Album, viewMode: ViewMode)
    {
        self.backgroundColor = .blue
        
        let scratchImage = ScratchImage(size: CGSize(width: 200, height: 200), viewMode: viewMode)
        for index in 0 ..< album.count {
            let item = album[index]!
            if let pic = scratchImage.getImage(picture: item.picture) {
                images.append((name: item.name, image: UIImage(cgImage: pic)))
            }
        }
        
        setupCollectionView()
    }
    
    private func setupCollectionView() {
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 20, left: 10, bottom: 10, right: 10)
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 200, height: 200)
        
        let frame = CGRect(origin: CGPoint(x: 0, y: 100), size: CGSize(width: self.frame.width, height: 500))
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
        cell.imageView.image = item.image
        cell.name = item.name
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = images[indexPath.item]
        self.onSelection?(item.name)
    }
    
}

//  Copyright © 2019 zscao. All rights reserved.

import UIKit

class GalleryItemCell: UICollectionViewCell {
    weak var imageView: UIImageView!
    var name: String?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let view = UIImageView(frame: CGRect(origin: .zero, size: CGSize(width: 200, height: 200)))
        self.contentView.addSubview(view)
        
        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: self.contentView.topAnchor),
            view.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor),
            view.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor),
        ])
        
        self.imageView = view
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.imageView.image = nil
    }
}

//
//  FeedCell.swift
//  Margo
//
//  Created by Lenovo on 01/05/25.
//

import UIKit
import CollectionViewSlantedLayout

class FeedCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    
    var imageHeight: CGFloat {
        return imageView.bounds.height
    }
    
    var imageWidth: CGFloat {
        return imageView.bounds.width
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        contentView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 10
    }
    
    func offset(_ offset: CGPoint) {
        imageView.frame = imageView.bounds.offsetBy(dx: offset.x * 10, dy: offset.y * 10)
    }
}

//
//  FeedViewCell.swift
//  Margo
//
//  Created by Lenovo on 12/05/25.
//

import UIKit
import CollectionViewSlantedLayout
import TagListView

let yOffsetSpeed: CGFloat = 150.0
let xOffsetSpeed: CGFloat = 100.0

class FeedViewCell: CollectionViewSlantedCell {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var backGroundView: UIView!
    @IBOutlet weak var btnBlco: UIButton!
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var detailsLabel: UILabel!
    @IBOutlet weak var vwTag: TagListView!
    
    private var gradient = CAGradientLayer()
    var blockUser: (()->())?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        gradient.colors = [UIColor.clear.cgColor, UIColor.black.cgColor]
        gradient.locations = [0.0, 1.0]
        gradient.frame = backGroundView.bounds
       // backGroundView.layer.addSublayer(gradient)
        vwTag.textFont = UIFont(name:"Futura", size: 14)!
        vwTag.alignment = .left
    }
    
    func configure(with profile: QRUserData) {
        
        if profile.profileImage?.count != 0{
            let urls = URL(string: profile.profileImage?[0] ?? "")
            imageView.sd_setImage(with: urls, placeholderImage: UIImage(named: "ic_profile"))
        }
        nameLabel.text = profile.name
//        locationLabel.text = profile.dob
        if let ages = profile.dob , ages != "" {
            locationLabel.text = "\(SBUtill.calcAge(birthday: ages)) age"
        }
        let gender = profile.gender == 0 ? "Male" : "Female"
        let height = profile.height == "" ? "" : "/\(profile.height ?? "")"
        detailsLabel.text = gender + height
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        //gradient.frame = backGroundView.bounds
        
    }
    var image: UIImage = UIImage() {
        didSet {
            imageView.image = image
        }
    }

    var imageHeight: CGFloat {
        return (imageView?.image?.size.height) ?? 0.0
    }

    var imageWidth: CGFloat {
        return (imageView?.image?.size.width) ?? 0.0
    }

    func offset(_ offset: CGPoint) {
        imageView.frame = imageView.bounds.offsetBy(dx: offset.x, dy: offset.y)
    }
    
    @IBAction func blockUserAction(_ sender: UIButton) {
        blockUser?()
    }
}

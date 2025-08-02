//
//  ProfileCardView.swift
//  Margo
//
//  Created by Only Mac on 11/01/25.
//

import UIKit
import TagListView

class ProfileCardView: UIView {
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var detailsLabel: UILabel!
    @IBOutlet weak var vwTag: TagListView!
    
    var buttonLikeAction : (() -> ()) = {}
    var buttonDisLikeAction : (() -> ()) = {}
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
        vwTag.textFont = UIFont(name:"Futura", size: 14)!
        vwTag.alignment = .left
    }
    
    private func setupUI() {
//        profileImageView.layer.cornerRadius = 10
//        profileImageView.clipsToBounds = true
    }
    
    func configure(with profile: QRUserData) {
        
        if profile.profileImage?.count != 0{
            let urls = URL(string: profile.profileImage?[0] ?? "")
            profileImageView.sd_setImage(with: urls, placeholderImage: UIImage(named: "ic_profile"))
        }
        nameLabel.text = profile.name
        locationLabel.text = profile.address
        let gender = profile.gender == 0 ? "Male" : "Female"
        let height = profile.height == "" ? "" : "/\(profile.height ?? "")"
        detailsLabel.text = gender + height
//        let tags = profile.datingIntentions?.components(separatedBy: ",")
//        tags?.forEach { tag in
//            vwTag.addTag(tag)
        //}
    }
    
    private func createTagLabel(with text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .white
        label.backgroundColor = UIColor(hexString: "#FFFFFF", alpha: 0.2)
        label.layer.cornerRadius = 15
        label.clipsToBounds = true
        label.textAlignment = .center
        label.setContentHuggingPriority(.required, for: .horizontal)
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.heightAnchor.constraint(equalToConstant: 20).isActive = true
        label.widthAnchor.constraint(greaterThanOrEqualToConstant: 20).isActive = true
        return label
    }
    @IBAction func btnLikeAction(_ sender: Any) {
        buttonLikeAction()
    }
    
    @IBAction func btnDisLikeAction(_ sender: Any) {
        buttonDisLikeAction()
    }
}



//
//  MatchesCVCell.swift
//  Margo
//
//  Created by Dharmesh A Nagvadia on 23/01/25.
//

import UIKit

class MatchesCVCell: UICollectionViewCell {

    @IBOutlet weak var imgProfile: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var btnLike: UIButton!
    @IBOutlet weak var btnDislike: UIButton!
    @IBOutlet weak var btnMessage: UIButton!
    
    @IBOutlet weak var vwLike: UIView!
    var messageAction : (() -> ()) = {}
    var likeAction : (() -> ()) = {}
    var unLikeAction : (() -> ()) = {}
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    @IBAction func btnMessageAction(_ sender: Any) {
        messageAction()
    }
    @IBAction func btnLikeUserAction(_ sender: Any) {
        likeAction()
    }
    @IBAction func btnUserUnLikeAction(_ sender: Any) {
        unLikeAction()
    }
}

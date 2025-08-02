//
//  RestaurantDetailsTblCell.swift
//  Margo
//
//  Created by xuser on 07/02/25.
//

import UIKit
import SDWebImage

class RestaurantDetailsTblCell: UITableViewCell {

    @IBOutlet weak var Restimg: SDAnimatedImageView!
    @IBOutlet weak var lblRestName: UILabel!
    @IBOutlet weak var lblAddress: UILabel!
    var joinRoomAction : (() -> ()) = {}
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func btnJoinRoomAction(_ sender: Any) {
        joinRoomAction()
    }
    
    
}

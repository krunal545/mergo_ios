//
//  NotificationListTblCell.swift
//  Margo
//
//  Created by Lenovo on 02/04/25.
//

import UIKit

class NotificationListTblCell: UITableViewCell {

    @IBOutlet weak var vwLikeImg: UIView!
    @IBOutlet weak var vwClose: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        vwLikeImg.cornerRadius = vwLikeImg.bounds.height / 2
        vwClose.cornerRadius = vwClose.bounds.height / 2
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}

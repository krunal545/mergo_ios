//
//  ConversionsListCell.swift
//  FirebaseChat
//
//  Created by Techavtra's Mac Mini on 27/02/24.
//

import UIKit


let placeholderguest = UIImage(named: "placeHolder")!

class ConversionsListCell: UITableViewCell {
    
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var lblDateTime: UILabel!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var lblReadCount: UILabel!
    @IBOutlet weak var viewOnline: UIView!
    @IBOutlet weak var VWmain: UIView!
    @IBOutlet weak var btnCellTap: UIButton!
    
    var btnCellTp : (()->())?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    var roomInfo:RoomInfo?{
        didSet{
            //            lblDescription.attributedText = self.roomInfo?.message?.html2AttributedString
            print(roomInfo)
            if self.roomInfo?.isStaticData == true{
                lblDateTime.isHidden = true
            }else{
                lblDateTime.isHidden = false
                lblDateTime.text = self.roomInfo?.messgaeTime
            }
            
            lblTitle.text = self.roomInfo?.otherUserName
            if roomInfo?.ClearFor?["TAU\(getUserID())"] == false{
                if roomInfo?.DeleteFor?["TAU\(getUserID())"] == true{
                    let message = self.roomInfo?.message
                    if message?.contains("https") == true{
                        lblDescription.text = "Image.png"
                    }else{
                        lblDescription.text = self.roomInfo?.message
                    }
                    
                   
                }else{
                    lblDescription.text = "This message was deleted"
                }
            }else{
                lblDescription.text = ""
            }
            
            imgView.loadImageFromURL(url: self.roomInfo?.otherUserProfile, placeholderImage: placeholderguest)
            if(self.roomInfo?.unReadMessageCount != 0){
                lblReadCount.text = "\(self.roomInfo?.unReadMessageCount ?? 0)"
                lblReadCount.isHidden = false
            }
            else{
                lblReadCount.isHidden = true
            }
            if(roomInfo?.otherUserStatus?.lowercased() == "online"){
              //  viewOnline.isHidden = false
                viewOnline.isHidden = true
            }
            else{
                viewOnline.isHidden = true
            }
        }
    }
    
    
    @IBAction func btnCellTapAction(_ sender: UIButton) {
        self.btnCellTp?()
    }
    
}

//
//  ProfileNavView.swift
//  TilesWale
//
//  Created by MacCatalina on 21/07/22.
//  Copyright © 2022 Techavtra. All rights reserved.
//

import UIKit

protocol ProfileNavViewDelegate: AnyObject {
    func didTapProfile()
}

class ProfileNavView: UIView {

    @IBOutlet weak var imgProfile: UIImageView!
    
    @IBOutlet weak var lblUserName: UILabel!
    @IBOutlet weak var lblOnline: UILabel!
    
    var btnProfileTap:(()->())?
    
    var btProfileTap:(()->())?
    weak var delegate: ProfileNavViewDelegate?
    
    class func instanceFromNib() -> ProfileNavView {
        guard let view = Bundle.main.loadNibNamed("ProfileNavView", owner: nil, options: nil)?.first as? ProfileNavView else {
            fatalError("Could not load ProfileNavView from nib")
        }
        return view
    }

    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        print("ProfileNavView loaded")
        print("imgProfile is nil? \(imgProfile == nil)")
        print("lblUserName is nil? \(lblUserName == nil)")
        print("lblOnline is nil? \(lblOnline == nil)")
    }
    
    @IBAction func btnProfile(_ sender: Any) {
        btnProfileTap?()
    }
    
    
    
    @IBAction func btnProfileTapAction(_ sender: UIButton) {
      //  btnProfileTap?()
     //   delegate?.didTapProfile()
        NotificationCenter.default.post(name: .profileButtonTapped, object: nil)


        
        guard let action = btnProfileTap else {
            print("btnProfileTap closure not set!")
            return
        }
      //  btnProfileTap?()
    }
}

extension Notification.Name {
    static let profileButtonTapped = Notification.Name("profileButtonTapped")
}

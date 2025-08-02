//
//  OtherProfileVC.swift
//  Margo
//
//  Created by Dharmesh A Nagvadia on 29/01/25.
//

import UIKit
import ImageSlideshow

enum NavigationFrom:Int {
    case chatDetailScreen = 0
    case matchProfileScreen = 1
    case feedTab = 2
}

class OtherProfileVC: UIViewController, ReportVCDelegate {
  

    @IBOutlet weak var lblUserName: UILabel!
    @IBOutlet weak var lblEmail: UILabel!
    @IBOutlet weak var imgSlideShow: ImageSlideshow!{
        didSet {
            imgSlideShow.slideshowInterval = 4.0
            imgSlideShow?.contentScaleMode = .scaleToFill
        }
    }
    @IBOutlet weak var likeDisLikeStackView: UIStackView! {
        didSet {
            likeDisLikeStackView.isHidden = true
        }
    }
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var lblDatingIntention: UILabel!
    @IBOutlet weak var lblGender: UILabel!
    @IBOutlet weak var lblBirthDate: UILabel!
    @IBOutlet weak var lblHeight: UILabel!
    
    @IBOutlet weak var btnClose: UIButton!
    
    @IBOutlet weak var btnLike: UIButton!
    
    @UserDefaultss(.blockedUser, defaultValue: [])
    var blockedUsers: [Int]?

    var user_id = Int()
    var userProfile:QRUserData?
    var navigateFrom: NavigationFrom?
    var qr_code: String?
    var is_user_like = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if userProfile == nil {
            callGetProfileApi()
        }else{
            setData()
        }
    
        switch navigateFrom {
        case .chatDetailScreen:
            self.likeDisLikeStackView.isHidden = true
        case .matchProfileScreen:
            self.likeDisLikeStackView.isHidden = false
        case .feedTab:
            self.likeDisLikeStackView.isHidden = false
        default:
            self.likeDisLikeStackView.isHidden = true
        }
        
    }
    
    func callGetProfileApi(){
        if SBUtill.reachable() {
            SBUtill.showProgress()
            
            let params = ["user_id":user_id]
            
            ClSApi.GetJsonModelValue(completion: { (data) in
                DispatchQueue.main.async { [self] in
                    SBUtill.dismissProgress()
                    if data["data"].dictionary != nil {
                        userProfile = QRUserData(data["data"])
                        setData()
                    }else {
                        SBUtill.showToastWith(data["message"].stringValue)
                    }
                }
            }, Tag: ClS.API.get_profile, Prams: params, Method: ClS.post)
        }else {
            SBUtill.showToastWith(SBText.Message.noInternet)
        }
    }
    
    func callLikeDeslikeApi(user_id:Int,like_deslike:Int,qr_code:String){
        if SBUtill.reachable() {
            SBUtill.showProgress()
            
            let params = ["second_user":user_id,
                          "like_dislike":like_deslike,
                          "qr_code":qr_code] as [String : Any]
            
            ClSApi.GetJsonModelValue(completion: { (data) in
                DispatchQueue.main.async { [self] in
                    SBUtill.dismissProgress()
                     if let profileData = data["data"].dictionary {
                         SBUtill.showToastWith(data["message"].stringValue)
                         self.likeDisLikeStackView.isHidden = true
                         self.navigationController?.popViewController(animated: true)
                    }else {
                        SBUtill.showToastWith(data["message"].stringValue)
                    }
                }
            }, Tag: ClS.API.swipe_create, Prams: params, Method: ClS.post)
        }else {
            SBUtill.showToastWith(SBText.Message.noInternet)
        }
    }

    func setData(){
        var userImages = [AlamofireSource]()
        for prImage in userProfile!.profileImage!{
            userImages.append(AlamofireSource(url: URL(string: prImage)!, placeholder: UIImage(named: "placeHolder")))
        }
        self.imgSlideShow.setImageInputs(userImages)
        self.imgSlideShow.contentScaleMode = .scaleAspectFill
        lblUserName.text = "\(userProfile?.name ?? "") \(userProfile?.lastName ?? "")"
        lblEmail.text = "\(userProfile?.email ?? "")"
        lblDescription.text = userProfile?.description != "" ? userProfile?.description : "No Bio"
        lblDatingIntention.text = userProfile?.datingIntentions != "" ? userProfile?.datingIntentions : "No mention"
        var userAge = ""
        if let ages = userProfile?.dob , ages != "" {
            userAge = "| \(SBUtill.calcAge(birthday: ages)) age"
        }
        
        let userGender = userProfile?.gender == 0 ? "Male" : "Female"
        let userHeight = userProfile?.height != "" ? " | \(userProfile?.height ?? "")" : ""
        
        var userBio = "\(userGender) \(userAge) \(userHeight)"
        lblGender.text = userBio
        lblBirthDate.text = userProfile?.dob != "" ? userProfile?.dob : "Not set"
        lblHeight.text = userProfile?.height != "" ? userProfile?.height : "Not set"
        likeDisLikeStackView.isHidden = false
//        btnClose.isHidden = is_user_like ? true : false
        btnLike.isHidden = false
        print(is_user_like)
    }

    func alertBlockUser(id:Int) {
        let alert = UIAlertController(title: "Block User", message: "Are you sure you want to block this user?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { alert in
            self.blockedUsers?.append(id)
            SBUtill.showToastWith("Blocked successfully, User will be removed from your feed")
            //self.navigationController?.popViewController(animated: true)
        }))
        alert.addAction(UIAlertAction(title: "No", style: .destructive))
        self.present(alert, animated: true)
    }
                                      
    @IBAction func btnBackAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnDislike(_ sender: UIButton) {
        callLikeDeslikeApi(user_id: user_id, like_deslike: 0, qr_code: qr_code!)
    }
    
    @IBAction func btnLikeAction(_ sender: UIButton) {
        if is_user_like{
            SBUtill.showToastWith("You have already waved at this user, wait for them to respond")
        }else{
            callLikeDeslikeApi(user_id: user_id, like_deslike: 1, qr_code: qr_code!)
            
        }
    }
    
    @IBAction func blockUser(_ sender: UIButton) {
        //        self.alertBlockUser(id: user_id)
        let userSelectionVC = self.storyboard?.instantiateViewController(withIdentifier: "ReportVC") as! ReportVC
        userSelectionVC.modalTransitionStyle = .crossDissolve
        userSelectionVC.modalPresentationStyle = .overFullScreen
        userSelectionVC.otherUserID = user_id
        userSelectionVC.delegate = self
        self.present(userSelectionVC, animated: true)
    }
    
    func didTapReport(userID: Int) {
        self.alertBlockUser(id: userID)
    }
    
}

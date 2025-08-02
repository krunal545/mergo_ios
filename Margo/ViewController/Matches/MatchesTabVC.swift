//
//  MatchesTabVC.swift
//  Margo
//
//  Created by Only Mac on 11/01/25.
//

import UIKit

class MatchesTabVC: UIViewController {
    
    @IBOutlet weak var clvMatches: UICollectionView!{
        didSet {
            self.clvMatches.register(UINib(nibName: "MatchesCVCell", bundle: nil), forCellWithReuseIdentifier: "MatchesCVCell")
        }
    }
    @IBOutlet weak var lblNoDataFound: UILabel!{
        didSet{
            lblNoDataFound.isHidden = true
        }
    }
    @IBOutlet weak var btnAwaiting: UIButton!
    @IBOutlet weak var btnMatched: UIButton!
    
    var userProfiles = [QRUserData]()
    var awaiting = true
    
    @UserDefaultss(.blockedUser, defaultValue: [])
    var blockedUsers: [Int]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = false
        callGetMatchesApi(matches: awaiting ? 2 : 1)
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
    @IBAction func btnAwaitingAction(_ sender: UIButton) {
        sender.setBackgroundImage(UIImage(named: "button_gradient"), for: .normal)
        sender.setTitleColor(.white, for: .normal)
        btnMatched.setBackgroundImage(nil, for: .normal)
        btnMatched.setTitleColor(.accent, for: .normal)
        userProfiles.removeAll()
        clvMatches.reloadData()
        callGetMatchesApi(matches: 2)
        awaiting = true
    }
    
    @IBAction func btnMatchedAction(_ sender: UIButton) {
        sender.setBackgroundImage(UIImage(named: "button_gradient"), for: .normal)
        sender.setTitleColor(.white, for: .normal)
        btnAwaiting.setBackgroundImage(nil, for: .normal)
        btnAwaiting.setTitleColor(.accent, for: .normal)
        userProfiles.removeAll()
        clvMatches.reloadData()
        callGetMatchesApi(matches: 1)
        awaiting = false
    }
    
    func callGetMatchesApi(matches: Int){
        if SBUtill.reachable() {
            //SBUtill.showProgress()
            
            let params = ["match" : matches]
            
            ClSApi.GetJsonModelValue(completion: { (data) in
                DispatchQueue.main.async { [self] in
                    //  SBUtill.dismissProgress()
                    //                    data["success"].boolValue,
                    
                    if let profileData = data["data"].array {
                        userProfiles.removeAll()
                        for profile in profileData{
                            self.userProfiles.append(QRUserData(profile))
                        }
                        for blockUser in self.blockedUsers ?? [] {
                            if let userInd = self.userProfiles.firstIndex(where: {$0.id == blockUser}) {
                                self.userProfiles.remove(at: userInd)
                            }
                        }
                        
                        if userProfiles.count == 0 {
                            lblNoDataFound.isHidden = false
                            clvMatches.isHidden = true
                        }else{
                            lblNoDataFound.isHidden = true
                            clvMatches.isHidden = false
                        }
                        self.clvMatches.reloadData()
                    }else {
                        SBUtill.showToastWith(data["message"].stringValue)
                    }
                }
            }, Tag: ClS.API.matches, Prams: params, Method: ClS.post)
        }else {
            SBUtill.showToastWith(SBText.Message.noInternet)
        }
    }
    
    func callLikeDislikeApi(user_id:Int,like_deslike:Int,qr_code:String){
        if SBUtill.reachable() {
            SBUtill.showProgress()
            //6787756607bd0
            let params = ["second_user":user_id,
                          "like_dislike":like_deslike,
                          "qr_code":qr_code] as [String : Any]
            
            ClSApi.GetJsonModelValue(completion: { (data) in
                DispatchQueue.main.async { [self] in
                    SBUtill.dismissProgress()
                    if let profileData = data["data"].dictionary {
                        callGetMatchesApi(matches: awaiting ? 2 : 1)
                        SBUtill.showToastWith(data["message"].stringValue)
                    }else {
                        SBUtill.showToastWith(data["message"].stringValue)
                    }
                }
            }, Tag: ClS.API.swipe_create, Prams: params, Method: ClS.post)
        }else {
            SBUtill.showToastWith(SBText.Message.noInternet)
        }
    }
    
}

extension MatchesTabVC : UICollectionViewDelegate,UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if awaiting{
            return userProfiles.count
        }else{
            return userProfiles.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MatchesCVCell", for: indexPath) as! MatchesCVCell
        
        let profile = userProfiles[indexPath.row]
        cell.lblName.text = profile.name
        if profile.profileImage?.count != 0{
            let urls = URL(string: profile.profileImage?[0] ?? "")
            cell.imgProfile.sd_setImage(with: urls, placeholderImage: UIImage(named: "ic_profile"))
        }
        
        if awaiting{
            cell.vwLike.isHidden = false
            cell.btnDislike.isHidden = false
            cell.btnMessage.isHidden = true
        }else{
            cell.vwLike.isHidden = true
            cell.btnDislike.isHidden = true
            cell.btnMessage.isHidden = false
        }
        cell.messageAction = {
            let currentUser = "TAU" + "\(Global.user!.id!)"
            let otherUser = "TAU" + "\(profile.id!)"
            let roomid = "TAU" + "\(Global.user!.id!)" + "_" + "TAU" + "\(profile.id!)"
            
            let objChat = ChatDetailViewController(with: profile.email!, id: currentUser, otherUserId: otherUser)
            objChat.otherUserID = otherUser
            objChat.roomID = roomid
            objChat.userData = profile
            self.navigationController?.pushViewController (objChat, animated: false)
        }
        cell.likeAction = { [self] in
            callLikeDislikeApi(user_id: profile.id ?? 0, like_deslike: 1, qr_code: Global.saveQRCode ?? "")
        }
        cell.unLikeAction = { [self] in
            callLikeDislikeApi(user_id: profile.id ?? 0, like_deslike: 0, qr_code: Global.saveQRCode ?? "")
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let UserSelectionVC = self.storyboard?.instantiateViewController(withIdentifier: "OtherProfileVC") as! OtherProfileVC
        UserSelectionVC.userProfile = userProfiles[indexPath.row]
        if awaiting{
            UserSelectionVC.navigateFrom = .matchProfileScreen
        }else{
            UserSelectionVC.navigateFrom = .chatDetailScreen

        }
        self.navigationController?.pushViewController(UserSelectionVC, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: ((collectionView.bounds.width-25)/2), height:((collectionView.bounds.width-25)/2 + 40))
    }
    
}

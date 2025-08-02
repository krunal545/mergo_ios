//
//  FeedTabVC.swift
//  Margo
//
//  Created by Only Mac on 11/01/25.
//

import UIKit
import Koloda
import MercariQRScanner
import AVFoundation
import CollectionViewPagingLayout
import CollectionViewSlantedLayout

struct Profile {
    let imageName: String
    let name: String
    let location: String
    let details: String
    let tags: [String]
}

class FeedTabVC: UIViewController, ReportVCDelegate{
  

    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var collectionViewLayout: CollectionViewSlantedLayout!
    @IBOutlet weak var kolodaView: KolodaView!{
        didSet{
            self.kolodaView.isHidden = true
        }
    }
    @IBOutlet weak var vwScanner: QRScannerView!
    @IBOutlet weak var lblNoDataFound: UILabel!{
        didSet{
            self.lblNoDataFound.isHidden = true
        }
    }

    @IBOutlet weak var lblUserName: UILabel!
    @IBOutlet weak var btnJoinRoom: UIButton!{
        didSet{
            self.btnJoinRoom.isHidden = true
        }
    }
    
    @IBOutlet weak var vwMap: UIView!
    var profiles: [Profile] = [
        Profile(imageName: "D2", name: "Sophia Marie Johnson", location: "Los Angeles, USA", details: "5'6 / 60 Kg / Hindu / Never married", tags: ["Art", "Loving", "Caring", "Humoristic"]),
        Profile(imageName: "Dhyara", name: "John Doe", location: "New York, USA", details: "6'0 / 70 Kg / Christian / Single", tags: ["Kind", "Friendly", "Sporty", "Intelligent"]),

    ]
    var userProfilesToDisplay = [QRUsers]()
    internal var covers = [[String: String]]()
    
    @UserDefaultss(.blockedUser, defaultValue: [])
    var blockedUsers: [Int]?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        lblUserName.text = Global.user?.name
        collectionViewLayout.isFirstCellExcluded = true
        collectionViewLayout.isLastCellExcluded = true
        collectionViewLayout.slantingSize = UInt(30)
        collectionViewLayout.lineSpacing = CGFloat(0)
        collectionViewLayout.slantingDirection = .upward
        collectionViewLayout.scrollDirection = .vertical
        collectionViewLayout.zIndexOrder = .ascending
        collectionView.delegate = self
        collectionView.dataSource = self
        self.collectionView.register(UINib(nibName: "FeedViewCell", bundle: nil), forCellWithReuseIdentifier: "FeedViewCell")
    }

    
    override func viewWillAppear(_ animated: Bool) {
        callGetQrProfilesApi()
        vwScanner.reloadInputViews()
        self.vwScanner.isHidden = true
    }
    
    @IBAction func btnNotificationList(_ sender: Any) {
        let NotificationVC = self.storyboard?.instantiateViewController(withIdentifier: "NotificationVC") as! NotificationVC
        self.navigationController?.pushViewController(NotificationVC, animated: true)
    }
    @IBAction func btnScanAction(_ sender: Any) {
        let userSelectionVC = self.storyboard?.instantiateViewController(withIdentifier: "ScannerVC") as! ScannerVC
        self.navigationController?.pushViewController(userSelectionVC, animated: true)
    }
    
    private func setupQRScanner() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            setupQRScannerView()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                if granted {
                    DispatchQueue.main.async {
                        self?.setupQRScannerView()
                    }
                } else {
                    self?.showPermissionAlert()
                }
            }
        default:
            showPermissionAlert()
        }
    }
    
    private func showPermissionAlert() {
        let alert = UIAlertController(
            title: "Camera Permission Required",
            message: "Please enable camera access in Settings to scan QR codes.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    private func setupQRScannerView() {
        vwScanner.configure(delegate: self, input: .init(isBlurEffectEnabled: true))
        vwScanner.startRunning()
    }
    
    func alertBlockUser(id:Int) {
        let alert = UIAlertController(title: "Block User", message: "Are you sure you want to block this user?", preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { _ in
            self.blockedUsers?.append(id)
            SBUtill.showToastWith("Blocked successfully, User will be removed from your feed")
            
            var indexPathsToDelete: [IndexPath] = []

            for (index, user) in self.userProfilesToDisplay.enumerated() {
                if self.blockedUsers?.contains(user.userId ?? 0) == true {
                    TAChatManager.shared.deleteRoomData(userId: "TAU\(Global.user!.id ?? 0)", otherUserId: "TAU\(user.userId ?? 0)",isFromChatDetails: false)
                    indexPathsToDelete.append(IndexPath(item: index, section: 0))
                }
            }
            self.collectionView.performBatchUpdates({
                for indexPath in indexPathsToDelete.sorted(by: { $0.item > $1.item }) {
                    self.userProfilesToDisplay.remove(at: indexPath.item)
                }
                self.collectionView.deleteItems(at: indexPathsToDelete)
            }, completion: { _ in
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                    self.collectionView.setNeedsLayout()
                    self.collectionView.layoutIfNeeded()
                    self.collectionView.setCollectionViewLayout(self.collectionView.collectionViewLayout, animated: false)
                    self.collectionViewLayout.invalidate()
                    self.collectionView.layoutIfNeeded()
                }
            })

        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    func addMapVCInContainer() {
        if let mapVC = self.storyboard?.instantiateViewController(withIdentifier: "MapVC") as? MapVC {
            self.addChild(mapVC)
            mapVC.view.frame = self.vwMap.bounds
            self.vwMap.addSubview(mapVC.view)
            mapVC.didMove(toParent: self)
        }
    }
    
    func callGetQrProfilesApi(){
        if SBUtill.reachable() {
            SBUtill.showProgress()
            
            let params = [String:Any]()
            
            ClSApi.GetJsonModelValue(completion: { (data) in
                DispatchQueue.main.async { [self] in
                    SBUtill.dismissProgress()
                    //                    data["success"].boolValue,
                    
                    if let profileData = data["data"].array {
                        userProfilesToDisplay.removeAll()
                        
                        for profile in profileData{
                            userProfilesToDisplay.append(QRUsers(profile))
                        }
                        userProfilesToDisplay.removeAll { $0.user?.is_liked == true }
                        
                        for blockUser in self.blockedUsers ?? [] {
                            if let userInd = userProfilesToDisplay.firstIndex(where: {$0.userId == blockUser}) {
                                self.userProfilesToDisplay.remove(at: userInd)
                            }
                        }
                        
                        if userProfilesToDisplay.count == 0 {
                            self.addMapVCInContainer()
                            if data["status"].intValue == 0{
                                self.vwMap.isHidden = false
                                lblNoDataFound.isHidden = true
                                self.collectionView.isHidden = true
                            }else{
                                lblNoDataFound.isHidden = false
                                lblNoDataFound.text = "the room does not have any more users, wait for users to join"
                                self.vwMap.isHidden = true
                                self.collectionView.isHidden = true
                            }
                        }else{
                            lblNoDataFound.isHidden = true
                            self.collectionView.isHidden = false
                            self.vwMap.isHidden = true
                        }
                        self.collectionView.reloadData()
                        self.collectionView.collectionViewLayout.invalidateLayout()
                        self.collectionView.layoutIfNeeded()
                        
                    }else {
                     
                        SBUtill.showToastWith(data["message"].stringValue)
                    }
                }
            }, Tag: ClS.API.qr_Code_User_List, Prams: params, Method: ClS.post)
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
                     if let profileData = data["data"].array {
//                         SBUtill.showToastWith(data["message"].stringValue)
                    }else {
//                        SBUtill.showToastWith(data["message"].stringValue)
                    }
                }
            }, Tag: ClS.API.swipe_create, Prams: params, Method: ClS.post)
        }else {
            SBUtill.showToastWith(SBText.Message.noInternet)
        }
    }
    
    func callScanAPI(qr_code:String){
        if SBUtill.reachable() {
            SBUtill.showProgress()
            let params = ["qr_code":qr_code] as [String : Any]
            
            ClSApi.GetJsonModelValue(completion: { (data) in
                DispatchQueue.main.async { [self] in
                    Global.saveQRCode = qr_code
                    SBUtill.dismissProgress()
                    if (data["data"].dictionary != nil) {
                        self.callGetQrProfilesApi()
                        self.btnJoinRoom.isHidden = true
                        SBUtill.showToastWith(data["message"].stringValue)
                    }else {
                        SBUtill.showToastWith(data["message"].stringValue)
                    }
                }
            }, Tag: ClS.API.qr_code_scan, Prams: params, Method: ClS.post)
        }else {
            SBUtill.showToastWith(SBText.Message.noInternet)
        }
    }
    @IBAction func btnJoinRoomAction(_ sender: Any) {
//        self.callScanAPI(qr_code: "6787756607bd0")
        let userSelectionVC = self.storyboard?.instantiateViewController(withIdentifier: "ScannerVC") as! ScannerVC
        self.navigationController?.pushViewController(userSelectionVC, animated: true)
    }
}


//extension FeedCell: ScaleTransformView {
//    var scaleOptions: ScaleTransformViewOptions {
//        ScaleTransformViewOptions(
//            minScale: 0.6,
//            scaleRatio: 0.4,
//            translationRatio: CGPoint(x: 0.66, y: 0.2),
//            maxTranslationRatio: CGPoint(x: 2, y: 0)
//        )
//    }
//}
//
//extension FeedCell: TransformableView {
//    func transform(progress: CGFloat) {
//        let scale = 1 - abs(progress) * 0.4 // 0.6 to 1.0 scale range
//        contentView.transform = CGAffineTransform(scaleX: scale, y: scale)
//        contentView.alpha = 1 - abs(progress) * 0.5
//    }
//
//}

extension FeedTabVC:UICollectionViewDataSource, CollectionViewDelegateSlantedLayout{
  
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print(userProfilesToDisplay.count)
        return userProfilesToDisplay.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FeedViewCell", for: indexPath) as! FeedViewCell
        cell.image = UIImage(named: "4") ?? UIImage(named: "D2")!
      
        if let user = userProfilesToDisplay[indexPath.row].user{
            cell.configure(with: user)
        }
        
        if let layout = collectionView.collectionViewLayout as? CollectionViewSlantedLayout {
            cell.contentView.transform = CGAffineTransform(rotationAngle: layout.slantingAngle)
        }
        
        cell.blockUser = { () in
            if let userId =  self.userProfilesToDisplay[indexPath.row].userId {
//                self.alertBlockUser(id: userId)
                let userSelectionVC = self.storyboard?.instantiateViewController(withIdentifier: "ReportVC") as! ReportVC
                userSelectionVC.modalTransitionStyle = .crossDissolve
                userSelectionVC.modalPresentationStyle = .overFullScreen
                userSelectionVC.otherUserID = userId
                userSelectionVC.delegate = self
                self.present(userSelectionVC, animated: true)
                
            }
        }
        
        return cell
    }
    
    func didTapReport(userID: Int) {
        self.alertBlockUser(id: userID)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("Did select item at indexPath: [\(indexPath.section)][\(indexPath.row)]")

        if let userData = userProfilesToDisplay[indexPath.row].user{
            let userSelectionVC = self.storyboard?.instantiateViewController(withIdentifier: "OtherProfileVC") as! OtherProfileVC
            userSelectionVC.user_id = userData.id!
            userSelectionVC.userProfile = userData
            userSelectionVC.navigateFrom = .feedTab
            userSelectionVC.is_user_like = userData.is_liked!
            userSelectionVC.qr_code = userProfilesToDisplay[indexPath.row].qrCode!
            print(userData.is_liked!)
            self.navigationController?.pushViewController(userSelectionVC, animated: true)
            //
    //                userProfilesToDisplay.remove(at: indexPath.row)
    //                DispatchQueue.main.async {
    //                    self.collectionView.reloadData()
    //                    self.collectionView.setNeedsLayout()
    //                    self.collectionView.layoutIfNeeded()
    //                    self.collectionView.setCollectionViewLayout(self.collectionView.collectionViewLayout, animated: false)
    //                    self.collectionViewLayout.invalidate()
    //                    self.collectionView.layoutIfNeeded()
    //                    if self.userProfilesToDisplay.isEmpty {
    //                        self.lblNoDataFound.isHidden = false
    //                        self.btnJoinRoom.isHidden = false
    //                    } else {
    //                        self.lblNoDataFound.isHidden = true
    //                        self.btnJoinRoom.isHidden = true
    //                    }
    //                }
        }
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: CollectionViewSlantedLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGFloat {
        let screenHeight = UIScreen.main.bounds.height
        return screenHeight * 0.6
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return .zero
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }

}
extension FeedTabVC: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard let collectionView = collectionView else { return }
        guard let visibleCells = collectionView.visibleCells as? [FeedViewCell] else { return }
        for parallaxCell in visibleCells {
            let yOffset = (collectionView.contentOffset.y - parallaxCell.frame.origin.y) / parallaxCell.imageHeight
            let xOffset = (collectionView.contentOffset.x - parallaxCell.frame.origin.x) / parallaxCell.imageWidth
            parallaxCell.offset(CGPoint(x: xOffset * xOffsetSpeed, y: yOffset * yOffsetSpeed))
        }
    }
}


//extension FeedTabVC: KolodaViewDelegate {
//    func kolodaDidRunOutOfCards(_ koloda: KolodaView) {
//        // Reload cards or fetch more data when cards run out
//        callGetQrProfilesApi()
////        kolodaView.resetCurrentCardIndex()
////        kolodaView.reloadData()
//    }
//    
//    func koloda(_ koloda: KolodaView, didSelectCardAt index: Int) {
//        print("Card selected at index: \(index)")
//        let userSelectionVC = self.storyboard?.instantiateViewController(withIdentifier: "OtherProfileVC") as! OtherProfileVC
//        userSelectionVC.user_id = userProfilesToDisplay[index].user!.id!
//        userSelectionVC.userProfile = userProfilesToDisplay[index].user!
//        userSelectionVC.navigateFrom = .feedTab
//        userSelectionVC.qr_code = userProfilesToDisplay[index].qrCode!
//        
//        self.navigationController?.pushViewController(userSelectionVC, animated: true)
//    }
//    
//    func koloda(_ koloda: KolodaView, didSwipeCardAt index: Int, in direction: SwipeResultDirection) {
//        callLikeDeslikeApi(user_id: userProfilesToDisplay[index].user!.id!, like_deslike: direction == .right ? 1 : 0,qr_code:userProfilesToDisplay[index].qrCode!)
//    }
//    
//}

//extension FeedTabVC: KolodaViewDataSource {
//    func kolodaNumberOfCards(_ koloda: KolodaView) -> Int {
//        return userProfilesToDisplay.count
//    }
//    
//    func koloda(_ koloda: KolodaView, viewForCardAt index: Int) -> UIView {
//        // Load your custom ProfileCardView
//        let cardView = Bundle.main.loadNibNamed("ProfileCardView", owner: self, options: nil)!.first as! ProfileCardView
//        if userProfilesToDisplay.count != 0{
//                cardView.configure(with: userProfilesToDisplay[index].user!)
//        }
//        cardView.buttonLikeAction = {
//            self.kolodaView.swipe(.right)
//        }
//        cardView.buttonDisLikeAction = {
//            self.kolodaView.swipe(.left)
//        }
//        return cardView
//    }
//}

extension FeedTabVC: QRScannerViewDelegate {
   
    func qrScannerView(_ qrScannerView: QRScannerView, didFailure error: QRScannerError) {
        DispatchQueue.main.async {
            self.vwScanner.stopRunning()
            print("QRScanner Error: \(error.localizedDescription)")
            let alert = UIAlertController(
                title: "Scan Failed",
                message: "Unable to process the QR code. Please try again.",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alert, animated: true)
        }
        view.reloadInputViews()
    }

    func qrScannerView(_ qrScannerView: QRScannerView, didSuccess code: String) {
        SBUtill.showToastWith(code)
        vwScanner.rescan()
            self.vwScanner.stopRunning()
        vwScanner.reloadInputViews()
        self.vwScanner.isHidden = true
    }
    
}

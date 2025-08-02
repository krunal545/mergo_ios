//
//  RestarauntVC.swift
//  Margo
//
//  Created by Only Mac on 11/01/25.
//

import UIKit
import FirebaseAuth
import Firebase
class RestarauntVC: UIViewController {

    @IBOutlet weak var tblRest: UITableView!{
        didSet{
            self.tblRest.register(cellType:RestaurantDetailsTblCell.self)
        }
    }
    @IBOutlet weak var lblNoDataFound: UILabel!{
        didSet{
            self.lblNoDataFound.isHidden = true
        }
    }
    @IBOutlet weak var btnEvent: UIButton!
    @IBOutlet weak var btnUnivercity: UIButton!
    @IBOutlet weak var btnRestaurant: UIButton!
    @IBOutlet weak var lblTitle: UILabel!
    
    var arrRestaurantList = [MDRestaurantList]()
    var arrUniversity = [MDRestaurantList]()
    var arrEvent = [MDRestaurantList]()
    var arrAllValues = [MDRestaurantList]()
    
    let db = Firestore.firestore()
    var userProfile: User?
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        TAChatManager.shared.InitializeUser()
        
        guard let userID = Auth.auth().currentUser?.uid else {
            print("User not authenticated. Please log in.")
            return
        }
       
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        callGetRestaurantApi()
        setupUnreadChatCountListener()
        callGetProfileApi()
    }
    
    @IBAction func btnFilterAction(_ sender: UIButton) {
        let selectedTag = sender.tag
        
        let buttons: [UIButton] = [btnRestaurant, btnUnivercity, btnEvent]
        self.lblTitle.text = sender.titleLabel?.text
        for button in buttons {
            if button.tag == selectedTag {
                if sender.tag == 0{
                    arrAllValues = arrRestaurantList
                    
                }else if sender.tag == 1{
                    arrAllValues = arrUniversity
                }else{
                    arrAllValues = arrEvent
                }
                if arrAllValues.count == 0 {
                    lblNoDataFound.isHidden = false
                    tblRest.isHidden = true
                }else{
                    lblNoDataFound.isHidden = true
                    tblRest.isHidden = false
                    tblRest.reloadData()
                }
                
                button.setBackgroundImage(UIImage(named: "button_gradient"), for: .normal)
                button.setTitleColor(.white, for: .normal)
            } else {
                button.setBackgroundImage(nil, for: .normal)
                button.setTitleColor(.accent, for: .normal)
            }
        }
    }

    
    func callGetProfileApi(){
        if SBUtill.reachable() {
            //SBUtill.showProgress()
            
            let params = ["user_id":Global.user?.id]
            
            ClSApi.GetJsonModelValue(completion: { (data) in
                DispatchQueue.main.async { [self] in
                  //  SBUtill.dismissProgress()
                    //                    data["success"].boolValue,
                    if data["data"].dictionary != nil {
                        userProfile = User(data["data"])
                        Global.saveQRCode = userProfile?.scaned_qr_code
                        if let userData = self.userProfile{
                            userData.saveInUserDefaults()
                        }
                    }else {
                        SBUtill.showToastWith(data["message"].stringValue)
                    }
                }
            }, Tag: ClS.API.get_profile, Prams: params, Method: ClS.post)
        }else {
            SBUtill.showToastWith(SBText.Message.noInternet)
        }
    }
    
    
    
    func setupUnreadChatCountListener() {
        if getUserID() != "" || getUserID() != nil {
            let myFireBaseId = "TAU\(getUserID())"
            let roomsQuery = db.collection("rooms").whereField("ids", arrayContains: myFireBaseId)
           TAChatManager.shared.unReadCountListener = roomsQuery.addSnapshotListener { [weak self] (snapshot, error) in
                guard let self = self else { return }
                
                if let error = error {
                    print("Error fetching unread counts: \(error)")
                    return
                }

                guard let snapshot = snapshot else {
                    print("No room data available")
                    return
                }
               var roomInfo:[RoomInfo] = []
                var totalUnreadCount = 0
               for document in snapshot.documents {
                   if let roomId = document.data()["roomId"] as? String {
                       if roomId.contains("TAU\(getUserID())") {
                           if let roomDetail = RoomInfo(document: document) {
                               roomInfo.append(roomDetail)
                           }
                       }
                   }
               }
               for info in roomInfo {
                   if let unreadCount = info.unReadMessageCount, unreadCount > 0 {
                       totalUnreadCount += unreadCount
                   }
               }
               DispatchQueue.main.async {
                   if let tabBarItems = self.tabBarController?.tabBar.items {
                       if totalUnreadCount > 0 {
                           tabBarItems[3].image = UIImage(named: "ic_chat_unread")
                       } else {
                           tabBarItems[3].image = UIImage(named: "ic_chat")
                       }
                       self.tabBarController?.tabBar.setNeedsDisplay()
                   }
                   print("\(totalUnreadCount > 0 ? "\(totalUnreadCount)" : "")")
               }
           }
        }
    }
    func setupUnreadCountListener() {
         let myFireBaseId = "TAU\(getUserID())"
         let roomsQuery = db.collection("rooms").whereField("ids", arrayContains: myFireBaseId)
        TAChatManager.shared.unReadCountListener = roomsQuery.addSnapshotListener { [weak self] (snapshot, error) in
             guard let self = self else { return }
             
             if let error = error {
                 print("Error fetching unread counts: \(error)")
                 return
             }

             guard let snapshot = snapshot else {
                 print("No room data available")
                 return
             }
            var roomInfo:[RoomInfo] = []
             var totalUnreadCount = 0
            for document in snapshot.documents {
                if let roomId = document.data()["roomId"] as? String {
                    if roomId.contains("TAU\(getUserID())") {
                        if let roomDetail = RoomInfo(document: document) {
                            roomInfo.append(roomDetail)
                        }
                    }
                }
            }
            for info in roomInfo {
                if let unreadCount = info.unReadMessageCount, unreadCount > 0 {
                    totalUnreadCount += unreadCount
                }
            }
            DispatchQueue.main.async {
                if let tabBarItems = self.tabBarController?.tabBar.items {
                    if totalUnreadCount > 0 {
                        tabBarItems[3].image = UIImage(named: "ic_chat_unread")
                    } else {
                        tabBarItems[3].image = UIImage(named: "ic_chat")
                    }
                    self.tabBarController?.tabBar.setNeedsDisplay()
                }
                
                print("\(totalUnreadCount > 0 ? "\(totalUnreadCount)" : "")")
            }
        }
    }
//    MARK: - Methods
    func callGetRestaurantApi(){
        if SBUtill.reachable() {
         //   SBUtill.showProgress()
            
            let params = [String : Any]()
            
            ClSApi.GetJsonModelValue(completion: { (data) in
                DispatchQueue.main.async { [self] in
               //     SBUtill.dismissProgress()
                    
                    if let profileData = data["data"].array {
                        arrAllValues.removeAll()
                        for profile in profileData{
                            self.arrAllValues.append(MDRestaurantList(profile))
                        }
                        
                        arrRestaurantList = arrAllValues.filter { $0.type == 1 }
                        arrUniversity = arrAllValues.filter { $0.type == 2 }
                        arrEvent = arrAllValues.filter { $0.type == 3 }
                        
                        arrAllValues = arrRestaurantList
                        
                        
                        if arrAllValues.count == 0 {
                            lblNoDataFound.isHidden = false
                            tblRest.isHidden = true
                        }else{
                            lblNoDataFound.isHidden = true
                            tblRest.isHidden = false
                        }
                        self.tblRest.reloadData()
                    }else {
                        SBUtill.showToastWith(data["message"].stringValue)
                    }
                }
            }, Tag: ClS.API.get_restaurant, Prams: params, Method: ClS.get)
        }else {
            SBUtill.showToastWith(SBText.Message.noInternet)
        }
    }
}

extension RestarauntVC : UITableViewDelegate , UITableViewDataSource{
  
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrAllValues.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(with: RestaurantDetailsTblCell.self, for: indexPath)
        let data = arrAllValues[indexPath.row]
        cell.lblRestName.text = data.title
        cell.lblAddress.text = data.address
        let imageURL = URL(string: data.image ?? "img_PlaceHolder")
        cell.Restimg.sd_setImage(with: imageURL)
        cell.joinRoomAction = {
            let userSelectionVC = self.storyboard?.instantiateViewController(withIdentifier: "ScannerVC") as! ScannerVC
            userSelectionVC.isFromHome = true
            self.navigationController?.pushViewController(userSelectionVC, animated: true)
        }
        
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 210
    }
}

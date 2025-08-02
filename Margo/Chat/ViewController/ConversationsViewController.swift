//
//  ViewController.swift
//  Messenger
//
//  Created by Afraz Siddiqui on 6/6/20.
//  Copyright © 2020 ASN GROUP LLC. All rights reserved.
//

import UIKit
import JGProgressHUD
import FirebaseAuth
import FirebaseFirestore


import Firebase
import FirebaseStorage
import FirebaseDatabase
var  lastDocumentIDs = String()

/// Controller that shows list of conversations
final class ConversationsViewController: UIViewController, UITableViewDataSource {

    private let spinner = JGProgressHUD(style: .dark)
    var arrFilterRoomList :[RoomInfo]? = []
    var arrRoomList:[RoomInfo]? = []
    let db = Firestore.firestore()
    var userProfiles = [QRUserData]()
    
    @UserDefaultss(.blockedUser, defaultValue: [])
    var blockedUsers: [Int]?
    
    @IBOutlet weak var noDataView: UILabel!{
        didSet{
            self.noDataView.isHidden = true
        }
    }
    @IBOutlet weak var tblView: UITableView! {
        didSet{
            tblView.register(UINib(nibName: "ConversionsListCell", bundle: nil), forCellReuseIdentifier: "ConversionsListCell")
        }
    }
    
    @IBOutlet weak var lblTitle: UILabel!
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tblView.showsVerticalScrollIndicator = false
        tblView.showsHorizontalScrollIndicator = false
        tblView.dataSource = self
       // tblView.isSkeletonable = true
        tblView.rowHeight = UITableView.automaticDimension
        tblView.rowHeight = 75
        tblView.estimatedRowHeight = 75
      
//        self.executeChat()
        
        tblView.addInfiniteScrolling{
            
            TAChatManager.shared.fetchMoreRooms(lastDocumentTimestamp: Timestamp(date: Date()), lastDocumentID: lastDocumentIDs, completion: { _ in
            })
            self.tblView.infiniteScrollingView.stopAnimating()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        executeChat()
        callGetMatchesApi(matches: 1)
        NotificationCenter.default.addObserver(self, selector: #selector(handleRoomDeletion(_:)), name: NSNotification.Name("RoomDeleted"), object: nil)
        self.lblTitle.text = "Chat"
        noDataView.text = "Sorry, You don't have any chat."
        setupUnreadCountListener()
        self.tabBarController?.tabBar.isHidden = false
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
    @objc func handleRoomDeletion(_ notification: Notification) {
        executeChat()
    }

    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name("RoomDeleted"), object: nil)
    }

    //MARK:- Methods
    func executeChat() {
        
          TAChatManager.shared.seenUserIDs.removeAll()
          TAChatManager.shared.resetAllRoomData()
          arrRoomList?.removeAll()
          arrFilterRoomList?.removeAll()
          TAChatManager.shared.fetchInitialRoomList()
          
          TAChatManager.shared.roomlistNoDataBlock = { message in
              if(self.arrRoomList?.count == 0){
                  self.noDataView.isHidden = false
              }else{
                  self.noDataView.isHidden = true
              }
          }
          TAChatManager.shared.roomlistReceivedBlock = { roomList in
              var profileFetchArr:[RoomInfo] = []
              self.tblView.removeNoDataView()
              
              if(self.arrRoomList?.count == 0 && roomList.count == 1) {
                  self.arrRoomList?.append(contentsOf: roomList)
                  profileFetchArr = roomList
              }
              else{
                  if(self.arrRoomList?.count == 0){
                      self.arrRoomList = roomList.sorted(by:{
                          $0.messgaeDateTime!.compare($1.messgaeDateTime!) == .orderedDescending
                      })
                      profileFetchArr = self.arrRoomList!
                  }
                  else{
                      if(roomList.count == 1){
                          self.arrRoomList?.insert(roomList.first!, at: 0)
                          profileFetchArr = roomList
                      }
                      else{
                          self.arrRoomList?.append(contentsOf: roomList)
                          self.arrRoomList = self.arrRoomList!.sorted(by:{
                              $0.messgaeDateTime!.compare($1.messgaeDateTime!) == .orderedDescending
                          })
                          profileFetchArr = roomList
                      }
                      
                  }
              }
              self.arrFilterRoomList = self.arrRoomList
              self.tblView.reloadData()
              
              TAChatManager.shared.fetchUserProfiles(userArray: profileFetchArr)
          }
        
        TAChatManager.shared.updateExistingRoomInfo = { [weak self] roomList in
            guard let self = self else { return }
            
            // 1. Update the matching room
            if let index = self.arrRoomList?.firstIndex(where: { $0.otherUserID == roomList.otherUserID }) {
                self.arrRoomList?[index] = roomList
            } else {
                return
            }
            
            guard let allRooms = self.arrRoomList else {
                self.arrFilterRoomList = []
                return
            }
            
            var filteredRooms = allRooms
            filteredRooms.removeAll(where: { $0.deleteConversationFor?["TAU\(getUserID())"] == false })
            
            var uniqueRooms = [String: RoomInfo]()
            var orderedRooms = [RoomInfo]()
            
            for room in filteredRooms {
                if let userId = room.otherUserID, uniqueRooms[userId] == nil {
                    uniqueRooms[userId] = room
                    orderedRooms.append(room)
                }
            }
            
            orderedRooms.sort { ($0.isStaticData ?? false) && !($1.isStaticData ?? false) }
            
            self.arrFilterRoomList = orderedRooms
            
            self.tblView.reloadData()
            TAChatManager.shared.fetchUserProfiles(userArray: [roomList])
        }
          
          TAChatManager.shared.roomlistModifiedBlock = { [self] modifiedRecord in
   
              if((self.arrRoomList?.contains(where: {
                  $0.roomID == modifiedRecord.roomID
              }))!){
                  for (index,record) in self.arrRoomList!.enumerated(){
                      if(record.roomID == modifiedRecord.roomID){
                          
                          modifiedRecord.otherUserName = record.otherUserName
                          modifiedRecord.otherUserProfile = record.otherUserProfile
                          modifiedRecord.otherUserStatus = record.otherUserStatus
                          self.arrRoomList?[index] = modifiedRecord
                          //                        self.arrRoomList?.insert(modifiedRecord, at: 0)
                          break;
                      }
                  }
                  self.arrRoomList = self.arrRoomList!.sorted(by:{
                      $0.messgaeDateTime!.compare($1.messgaeDateTime!) == .orderedDescending
                  })
                  if self.arrRoomList?.count != 0{
                      self.arrFilterRoomList?.append(contentsOf: self.arrRoomList!)
                  }
//                  callGetMatchesApi(matches: 1)
                  self.tblView.reloadData()
                   
              }
              else{
                  self.arrRoomList?.insert(modifiedRecord, at: 0)
                  self.arrRoomList = self.arrRoomList!.sorted(by:{
                      $0.messgaeDateTime!.compare($1.messgaeDateTime!) == .orderedDescending
                  })
                  if arrRoomList?.count != 0{
                      self.arrFilterRoomList?.append(contentsOf:arrRoomList!)
                  }
//                  callGetMatchesApi(matches: 1)
                  self.tblView.reloadData()
                  
                  TAChatManager.shared.fetchUserProfiles(userArray: [modifiedRecord])
              }
          }
          
          TAChatManager.shared.profilelistReceivedBlock = { profileList in
   
              for profileData in profileList{
                  for roomData in self.arrRoomList!{
                      if(roomData.otherUserID == (profileData["fireBaseId"] as! String)){
                          roomData.otherUserName = profileData["userName"] as? String
                          roomData.otherUserProfile = profileData["userProfilePic"] as? String
                          roomData.otherUserStatus = profileData["status"] as? String
                          
                          let dateValue = (profileData["lastSeenDate"] as? Int64) ?? 1590135471
                          let time = profileData["lastSeen"]as? String ?? ""
                          let newDate = Date.init(milliseconds: dateValue)
                          let previousDay = Calendar.current.date(byAdding: .day, value: -1, to: Date())
                          if(Calendar.current.isDate( newDate, inSameDayAs:Date())){
                              roomData.lastOnlieDateTime = "\("Today") at \(time)"
                             
                          }else if(Calendar.current.isDate( newDate, inSameDayAs:previousDay!)){
                              roomData.lastOnlieDateTime = "\("Yesterday") at \(time)"
                              
                          }else{
                              let date =  TAChatManager.shared.getStringDate(targetDate: newDate)
                              roomData.lastOnlieDateTime = "\(date) at \(time)"
                          }
                          
                          break;
                      }
                  }
              }
              
              self.tblView.reloadData()
          }
          self.tblView.reloadData()
      }
    
    
    func callGetMatchesApi(matches: Int){
        if SBUtill.reachable() {
            //SBUtill.showProgress()
            
            let params = ["match" : matches]
            
            ClSApi.GetJsonModelValue(completion: { (data) in
                DispatchQueue.main.async { [self] in
                    if let profileData = data["data"].array {
                        userProfiles.removeAll()
                        for profile in profileData{
                            let user = QRUserData(profile)
                            
//                            if blockedUsers?.contains(user.id ?? 0) == true {
//                                continue
//                            }
                            self.userProfiles.append(user)
                            let obj = createDummy(obj: user)
                            arrFilterRoomList?.append(obj)
                            arrRoomList?.append(obj)
                        }
                    }else {
                        SBUtill.showToastWith(data["message"].stringValue)
                    }
                }
            }, Tag: ClS.API.matches, Prams: params, Method: ClS.post)
        }else {
            SBUtill.showToastWith(SBText.Message.noInternet)
        }
    }
    
    
    func createDummy(obj: QRUserData) -> RoomInfo {
          let roomInfo = RoomInfo()
          let roomid = "TAU" + "\(Global.user!.id!)" + "_"  + "TAU\(obj.id ?? 0)"
          roomInfo.roomID = roomid
          roomInfo.messgaeDateTime = Date()
          roomInfo.messgaeTime = "10:30 AM"
          roomInfo.otherUserID = "TAU\(obj.id ?? 0)"
        
        let inviteMessage = obj.name
          roomInfo.otherUserName = inviteMessage
          roomInfo.otherUserStatus = "Online"
          roomInfo.otherUserProfile = obj.profileImage?.first
          let name = obj.name ?? ""
          let localizedText = String(format: NSLocalizedString("say_hi", comment: ""), name)
          roomInfo.message = localizedText
          roomInfo.seenByReceipent = false
          roomInfo.unReadMessageCount = 0
          roomInfo.lastOnlieDateTime = ""
          roomInfo.imgBGColor = UIColor.systemBlue
          roomInfo.isStaticData = true
  //        roomInfo.deleteConversationFor = ["user1": false, "user2": true]
  //        roomInfo.ClearFor = ["user1": true, "user2": false]
  //        roomInfo.DeleteFor = ["user1": false, "user2": false]
          
          return roomInfo
      }
    
    
    //MARK:- Action Methods
    @IBAction func btnNavigation(_ sender: Any) {
//        var vc = ChatDetailViewController(with: "tes@gmail.com", id: "12")
//        vc.hidesBottomBarWhenPushed = true
//        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
    
}

extension ConversationsViewController {

//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        
//        if self.arrFilterRoomList != nil{
//           // self.arrFilterRoomList?.removeAll(where: {$0.deleteConversationFor?["TAU\(getUserID())"] == false})
//            if self.arrFilterRoomList?.count == 0{
//                self.noDataView.isHidden = false
//                self.tblView.isHidden = true
//            }else{
//                self.noDataView.isHidden = true
//                self.tblView.isHidden = false
//            }
//        }
//        return self.arrFilterRoomList?.count ?? 0
//    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard var filteredRooms = self.arrFilterRoomList else { return 0 }
        
        filteredRooms.removeAll(where: { $0.deleteConversationFor?["TAU\(getUserID())"] == false })
        
        var uniqueRooms = [String: RoomInfo]()
        var orderedRooms = [RoomInfo]()
      
        for room in filteredRooms {
            guard var userId = room.otherUserID else { continue }

            // Remove "TAU" prefix if present
            if userId.hasPrefix("TAU") {
                userId = String(userId.dropFirst(3))
            }

            // Skip if already processed
            if uniqueRooms[userId] != nil {
                continue
            }

            // Skip if blocked
            if self.blockedUsers?.contains(Int(userId) ?? 0) == true {
                continue
            }

            uniqueRooms[userId] = room
            orderedRooms.append(room)

            print(room.otherUserName ?? "")
            print(room.isStaticData ?? false)
        }

        
        orderedRooms.sort { ($0.isStaticData ?? false) && !($1.isStaticData ?? false) }
        
        self.arrFilterRoomList = orderedRooms
        
        let isEmpty = self.arrFilterRoomList?.isEmpty ?? true
        self.noDataView.isHidden = !isEmpty
        self.tblView.isHidden = isEmpty
        
        return self.arrFilterRoomList?.count ?? 0
    }
    
//    func collectionSkeletonView(_ skeletonView: UITableView, cellIdentifierForRowAt indexPath: IndexPath) -> ReusableCellIdentifier {
//        return "ConversionsListCell"
//    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ConversionsListCell", for: indexPath) as! ConversionsListCell
       // cell.configure(with: model)
        cell.roomInfo = self.arrFilterRoomList?[indexPath.row]
        
        cell.btnCellTp = { () in
            let roomDetail = self.arrFilterRoomList![indexPath.row]
            let currentUser = "TAU" + "\(Global.user?.id ?? 0)"
            let otherUser = roomDetail.otherUserID
            let roomid = "TAU" + "\(Global.user?.id ?? 0)" + "_"  + (roomDetail.otherUserID ?? "")
        
            let objChat = ChatDetailViewController(with: roomDetail.otherUserName ?? "", id: currentUser, otherUserId: roomDetail.otherUserID)
            objChat.roomInfoData = roomDetail
            objChat.otherUserID = roomDetail.otherUserID ?? ""
            objChat.roomID = roomid
            self.navigationController?.pushViewController (objChat, animated: false)
        }
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let roomDetail = self.arrFilterRoomList![indexPath.row]
        
        if roomDetail.isStaticData == true{
            let currentUser = "TAU" + "\(Global.user!.id!)"
            let otherUser = "\(roomDetail.otherUserID ?? "")"
            
            let roomid = "TAU" + "\(Global.user!.id!)" + "_" + "\(roomDetail.otherUserID ?? "")"
            
            let objChat = ChatDetailViewController(with: Global.user!.email!, id: currentUser, otherUserId: otherUser)
            objChat.otherUserID = otherUser
            objChat.roomID = roomid
            self.navigationController?.pushViewController (objChat, animated: false)
        }else{
            let currentUser = "TAU" + "\(Global.user!.id!)"
            let otherUser = roomDetail.otherUserID
            let roomid = "TAU" + "\(Global.user!.id!)" + "_"  + (roomDetail.otherUserID ?? "")
            
            let objChat = ChatDetailViewController(with: roomDetail.otherUserName ?? "", id: currentUser, otherUserId: roomDetail.otherUserID)
            objChat.roomInfoData = roomDetail
            objChat.otherUserID = roomDetail.otherUserID ?? ""
            objChat.roomID = roomid
            self.navigationController?.pushViewController (objChat, animated: false)
        }
    }
//    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
//        return .delete
//    }
//
//    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
//        if editingStyle == .delete {
//            tableView.deleteRows(at: [indexPath], with: .left)
//            tableView.endUpdates()
//        }
//    }
    
    
}

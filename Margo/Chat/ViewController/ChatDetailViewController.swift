//
//  ChatDetailViewController.swift
//  FirebaseChat
//
//  Created by Techavtra's Mac Mini on 23/02/24.
//

import UIKit
import MessageKit
//import MessageInputBar
import InputBarAccessoryView
import SDWebImage
import AVFoundation
import AVKit
import CoreLocation
import FirebaseFirestore
import FirebaseStorage
import IQKeyboardManagerSwift
//import Localize_Swift

var Get_Other_User_Name_For_Chat = String()

class ChatDetailViewController: MessagesViewController, MessageCellDelegate {
    

    public var otherUserEmail: String = "test@gmail.com"
    
    public static let dateFormatter: DateFormatter = {
        let formattre = DateFormatter()
        formattre.dateStyle = .medium
        formattre.timeStyle = .long
        formattre.locale = .current
        return formattre
    }()
    
    var messages: [Message] = [Message]() // Your message data model
    var messagestype: [Messagetype] = [Messagetype]() // Your message data model
    
    private var selfSender: Sender? {
        let email = getEmail()
        let safeEmail = self.safeEmail(emailAddress: email)
        return Sender(photoURL: "",
                      senderId: safeEmail,
                      displayName: "Me")
    }
    
    init(with othoreUseremail: String, id: String?, otherUserId: String?) {
        self.otherUserEmail = othoreUseremail
        self.otherUserID = otherUserId ?? ""
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
//    private(set) lazy var refreshControl: UIRefreshControl = {
//      let control = UIRefreshControl()
//      control.addTarget(self, action: #selector(loadMoreMessages), for: .valueChanged)
//      return control
//    }()
    
    private let formatter: DateFormatter = {
      let formatter = DateFormatter()
      formatter.dateStyle = .medium
      return formatter
    }()
    
    //Firebaese Chat

    var otherUserUnReadCount = 0
    var mineUnReadCount = 0
    var roomID = "TAU0_TAU1"
    var otherUserID = "TAU1"
    var profileUserId = "0"
    var roomInfoData :RoomInfo?
    var btnProfile = UIButton()
    var btnMore : UIButton!
    let NavProfileView = ProfileNavView.instanceFromNib()
    var topSafeArea: CGFloat = 0
    var bottomSafeArea: CGFloat = 0
    var unReadMessageArray:[Message] = []
    var roomDetails:[String:Any]?
    let db = Firestore.firestore()
    var firstCharacterOfName : UILabel!
    var isMoreData = true
    var messageRead = ""
    var isLoadingMoreMessages = false
    var isFirstTimeLoad = true
    var userData: QRUserData?
    var otherUserActualId: Int?
    @UserDefaultss(.blockedUser, defaultValue: [])
    var blockedUsers: [Int]?
    
    let labelUserName:UILabel={
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textAlignment = .left
        label.textColor = .black
        label.numberOfLines = 1
        label.adjustsFontSizeToFitWidth = true
        label.text = ""
        return label
    }()
    
    let labelUserStatus:UILabel={
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 10)
        label.textAlignment = .left
        label.textColor = .black
        label.numberOfLines = 0
        label.layer.cornerRadius = 8
        label.layer.masksToBounds = true
        label.text = ""
        return label
    }()
    
    let userImage:UIImageView={
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.layer.masksToBounds = true
        iv.layer.cornerRadius = 15
        iv.clipsToBounds = true
        iv.image = UIImage(named: "placeHolder")
        return iv
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        NotificationCenter.default.addObserver(self, selector: #selector(profileTapped), name: .profileButtonTapped, object: nil)
        messageInputBar.delegate = self
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messagesCollectionView.messageCellDelegate = self
        showMessageTimestampOnSwipeLeft = true
        scrollsToLastItemOnKeyboardBeginsEditing = true
        messagesCollectionView.scrollToLastItem()
        messagesCollectionView.scrollsToTop = false
        messagesCollectionView.delegate = self
        messagesCollectionView.collectionViewLayout.invalidateLayout()
        messagesCollectionView.messagesDisplayDelegate = self
        messagesCollectionView.contentInsetAdjustmentBehavior = .always 
        messagesCollectionView.messagesCollectionViewFlowLayout.setMessageIncomingMessageBottomLabelAlignment(LabelAlignment(textAlignment: .left, textInsets: .zero))
        messagesCollectionView.messagesCollectionViewFlowLayout.setMessageOutgoingMessageBottomLabelAlignment(LabelAlignment(textAlignment: .right, textInsets: .zero))
        if let chatLayouts = messagesCollectionView.collectionViewLayout as? MessagesCollectionViewFlowLayout {
            chatLayouts.textMessageSizeCalculator.outgoingAvatarSize = .zero
            chatLayouts.textMessageSizeCalculator.incomingAvatarSize = .zero
            chatLayouts.textMessageSizeCalculator.incomingMessageLabelInsets = UIEdgeInsets(top: 12, left: 14, bottom: 12, right: 14)
            chatLayouts.textMessageSizeCalculator.outgoingMessageLabelInsets = UIEdgeInsets(top: 12, left: 14, bottom: 12, right: 14)
            chatLayouts.textMessageSizeCalculator.messageLabelFont = UIFont(name: "Outfit-Regular", size: 15) ?? UIFont.systemFont(ofSize: 14)
            chatLayouts.photoMessageSizeCalculator.incomingAvatarSize = .zero
            chatLayouts.photoMessageSizeCalculator.outgoingAvatarSize = .zero
        }

        setupInputButton()
        self.setUpViews()
        resetUserWith()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        TAChatManager.shared.resetAllData()
        // Show the navigation bar on other view controllers
        let navigationBarAppearance = UINavigationBarAppearance()
        navigationBarAppearance.configureWithOpaqueBackground()
        navigationBarAppearance.titleTextAttributes = [
            NSAttributedString.Key.foregroundColor : UIColor.black
        ]
        navigationBarAppearance.backgroundColor = UIColor.white
        UINavigationBar.appearance().standardAppearance = navigationBarAppearance
        UINavigationBar.appearance().compactAppearance = navigationBarAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navigationBarAppearance
        
        self.tabBarController?.tabBar.isHidden = true
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        IQKeyboardManager.shared.isEnabled = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // MARK: Navigation bar appearance
        let navigationBarAppearance = UINavigationBarAppearance()
        navigationBarAppearance.configureWithOpaqueBackground()
        navigationBarAppearance.titleTextAttributes = [
            NSAttributedString.Key.foregroundColor : UIColor.black
        ]
        navigationBarAppearance.backgroundColor = UIColor.white
        UINavigationBar.appearance().standardAppearance = navigationBarAppearance
        UINavigationBar.appearance().compactAppearance = navigationBarAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navigationBarAppearance
        
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        self.tabBarController?.tabBar.isHidden = true
        IQKeyboardManager.shared.isEnabled = false
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //messageInputBar.inputTextView.becomeFirstResponder()
        
    }
    
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        TAChatManager.shared.resetAllData()
    }
    
       
     func safeEmail(emailAddress: String) -> String {
        var safeEmail = emailAddress.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        return safeEmail
    }

    private func setupInputButton() {
        let button = InputBarButtonItem()
                button.setSize(CGSize(width: 0, height: 0), animated: false)
//        button.setSize(CGSize(width: 35, height: 35), animated: false)
        button.setImage(UIImage(systemName: "paperclip"), for: .normal)
        button.onTouchUpInside { [weak self] _ in
            self?.view.endEditing(true)
            self?.presentInputActionSheet()
        }
        messageInputBar.setLeftStackViewWidthConstant(to: 0, animated: false)
        messageInputBar.sendButton.tintColor = UIColor(named: "AccentColor")
        messageInputBar.sendButton.setTitleColor(UIColor(named: "AccentColor"), for: .normal)
        messageInputBar.setStackViewItems([button], forStack: .left, animated: false)
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y <= 0 && !isLoadingMoreMessages && isMoreData && !isFirstTimeLoad {
            loadMoreMessages()
        }
    }

    func loadMoreMessages() {
        isLoadingMoreMessages = true
        TAChatManager.shared.fetchMessages()
    }
    

    func setUpViews(){
        if #available(iOS 11.0, *) {
            let window = UIApplication.shared.keyWindow
            topSafeArea = window?.safeAreaInsets.top ?? 0
            bottomSafeArea = window?.safeAreaInsets.bottom ?? 0
        }
        self.view.backgroundColor = .white
        let naVview = UIView()
        naVview.addSubview(userImage)
        naVview.addSubview(labelUserName)
        naVview.addSubview(labelUserStatus)
        
        userImage.setHieghtOrWidth(height: 30, width: 30)
        userImage.centerOnYOrX(x: nil, y: true)
//        userImage.leftAnchor.constraint(equalTo: naVview.leftAnchor, constant: -10).isActive = true
        userImage.leadingAnchor.constraint(equalTo:naVview.leadingAnchor , constant: 10).isActive = true
        userImage.backgroundColor = .lightGray
        userImage.image = UIImage(named: "img_PlaceHolder")
        labelUserName.anchors(left: userImage.rightAnchor, right: naVview.rightAnchor, top: userImage.topAnchor, bottom: nil, leftConstant: 5, rightConstant: -5, topConstant: 0, bottomCosntant: 0)
        
        labelUserStatus.anchors(left: userImage.rightAnchor, right: naVview.rightAnchor, top: labelUserName.bottomAnchor, bottom: nil, leftConstant: 5, rightConstant: -5, topConstant: 0, bottomCosntant: 0)
        
        let item2 = UIBarButtonItem(customView: naVview)
        btnMore = UIButton(type: .system)
        btnMore.setImage(UIImage(named: "more"), for: .normal)
        btnMore.imageEdgeInsets = UIEdgeInsets(top: 2, left: 3, bottom: 2, right: 3)
        
        btnProfile = UIButton(type: .system)
        btnProfile.setImage(UIImage(named: "more"), for: .normal)
        btnProfile.layer.backgroundColor = UIColor.cyan.cgColor

        btnProfile.frame = CGRect(x: 10, y: 10, width: 50, height: 30)
        btnProfile.addTarget(self, action: #selector(redirectProfileScreen(_:)), for: .touchUpInside)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(redirectProfileScreen(_:)))
        NavProfileView.addGestureRecognizer(tap)
        NavProfileView.isUserInteractionEnabled = true
        
        
        NavProfileView.btnProfileTap = { [weak self] in
            guard let self = self else { return }
            
            let storyboard = UIStoryboard(name: "TabBar", bundle: nil)
            guard let userSelectionVC = storyboard.instantiateViewController(withIdentifier: "OtherProfileVC") as? OtherProfileVC else {
                return
            }
            if let numberPart = otherUserID.replacingOccurrences(of: "TAU", with: "") as? String,
               let id = Int(numberPart) {
                userSelectionVC.user_id = id
            }
            userSelectionVC.navigateFrom = .chatDetailScreen
            self.navigationController?.pushViewController(userSelectionVC, animated: true)
        }
        
        let leftItem1:UIBarButtonItem = UIBarButtonItem.init(customView:  NavProfileView)
        self.navigationItem.leftBarButtonItems = [leftItem1]
        let rightChat = UIBarButtonItem.init(customView: btnMore)
        self.navigationItem.rightBarButtonItems = [rightChat]
        self.addBackButton()
        self.addMoreButton()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func profileTapped() {
        let userSelectionVC = self.storyboard?.instantiateViewController(withIdentifier: "OtherProfileVC") as! OtherProfileVC
        userSelectionVC.user_id = (userData?.id)!
        userSelectionVC.userProfile = userData
        self.navigationController?.pushViewController(userSelectionVC, animated: true)
    }
  
    func addBackButton(){
        let backButton = UIButton(type: .custom)
        backButton.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        backButton.setImage(UIImage(named: "ic_back"), for: .normal)
        backButton.addTarget(self, action: #selector(btnBackTap), for: .touchUpInside)
        var arrayLeftButtons = self.navigationItem.leftBarButtonItems ?? []
        arrayLeftButtons.insert(UIBarButtonItem(customView: backButton), at: 0)
        let item = self.navigationItem
        self.navigationController?.navigationBar.tintColor = .black
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor:UIColor.black]
        item.leftBarButtonItems = arrayLeftButtons
        
    }
    
    func addMoreButton(){
        let backButton = UIButton(frame: CGRect(x: 0, y: 0, width: 30, height: 40))
        backButton.adjustsImageWhenHighlighted = false
        backButton.titleEdgeInsets = UIEdgeInsets(top: 0,left:0, bottom: 0, right: 0)
        backButton.imageEdgeInsets = UIEdgeInsets(top: 10,left:04, bottom: 10, right: 04)
        backButton.setImage(UIImage(named: "ic_more"), for: .normal)
        backButton.addTarget(self, action: #selector(btnMoreTap), for: .touchUpInside)
        var arrayLeftButtons = self.navigationItem.rightBarButtonItems ?? []
        arrayLeftButtons.insert(UIBarButtonItem(customView: backButton), at: 0)
        let item = self.navigationItem
        self.navigationController?.navigationBar.tintColor = .black
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor:UIColor.black]
        item.rightBarButtonItems = arrayLeftButtons
    }
    
    @objc func btnBackTap(){
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func btnMoreTap(){
        self.moreDeatilsFuncation()
    }
    
    @objc func redirectProfileScreen(_ sender: UIButton) {
        print("Navigation Profile")
    }
    
    func moreDeatilsFuncation(){
        let actionSheet = UIAlertController()
//        actionSheet. = .actionSheet
//        let actionSheet = UIAlertController(title: "",
//                                            message: "",
//                                            preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Unmatch", style: .default, handler: { [weak self] _ in
            print("Hello")
            self?.deleteRoom()
            self?.navigationController?.popViewController(animated: true)
//                self?.callDeleteUserAPI(isreported: false)
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Unmatch and Report", style: .default, handler: { [weak self] _ in
            print("Hello")
            self?.deleteRoom()
            self?.navigationController?.popViewController(animated: true)
//            self?.callDeleteUserAPI(isreported: true)
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

        present(actionSheet, animated: true)
    }
    
    func callDeleteUserAPI(isreported: Bool) {
           if SBUtill.reachable() {
               SBUtill.showProgress()
               var userId = otherUserID
               if userId.hasPrefix("TAU") {
                   userId = String(userId.dropFirst(3))
               }

               var params = ["user_id": userId] as [String : Any]
               ClSApi.GetJsonModelValue(completion: {
                   data in
                   SBUtill.dismissProgress()
                   DispatchQueue.main.async {
                       if let dataUser = data["data"].dictionary {
                           SBUtill.showToastWith("The user was blocked successfully.")
                           self.navigationController?.popViewController(animated: true)
                           self.deleteRoom()
                       } else {
                           SBUtill.showToastWith(data["message"].stringValue)
                       }
                   }
               }, Tag: ClS.API.post_report_post, Prams: params as [String : Any], Method: ClS.post)
           } else {
               SBUtill.showToastWith(SBText.Message.NoInternetSnack)
           }
       }
    
    func deleteRoom(){
        TAChatManager.shared.deleteRoomData(userId: "TAU\(Global.user!.id ?? 0)", otherUserId: otherUserID, isFromChatDetails: true)
        var userId = otherUserID
        if userId.hasPrefix("TAU") {
            userId = String(userId.dropFirst(3))
            callUserBlockApi(userId: userId)
        }
//        self.blockedUsers?.append(Int(userId) ?? 0)
    }
    
    
    func callUserBlockApi(userId:String){
        if SBUtill.reachable() {
            SBUtill.showProgress()
            let params = ["second_user":userId] as [String : Any]
            ClSApi.GetJsonModelValue(completion: { (data) in
                DispatchQueue.main.async { [self] in
                    SBUtill.showToastWith(data["message"].stringValue)
                }
            }, Tag: ClS.API.unmatch, Prams: params, Method: ClS.post)
        }else {
            SBUtill.showToastWith(SBText.Message.noInternet)
        }
    }
    
    
    func convertDate(dateValue: Int64) -> Date {
        let truncatedTime = Int(dateValue)
        let date = Date(timeIntervalSince1970: TimeInterval(truncatedTime))
        let formatter = DateFormatter()
        formatter.timeZone = .current
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        let strDate = formatter.string(from: date)
        
        let dateString = strDate

        let dateFormatter = DateFormatter()

        // Set the date format according to the format of your input string
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"

        // Convert the string to a Date object
        if let date = dateFormatter.date(from: dateString) {
            print(date) // This will print the date in its default format
            return date
        } else {
            print("Unable to parse date string.")
        }
        return Date()
    }
    
    func setMessageKitArray(data:Message,isSender:Bool) -> Messagetype {
        var messagestype: Messagetype?
        let text = data.text ?? ""
        let selfSender = self.selfSender
        let messageId = data.messageID ?? "0"
        messageRead = data.messageRead ?? "0"
        let messageStatus = data.messageStatus
        let otherUser: Sender = Sender(photoURL: "", senderId: "Other", displayName: "Buddy")
        
        let sender: Sender = isSender == true ? selfSender! : otherUser
            messagestype = Messagetype(sender: sender,
                                       messageId: messageId,
                                       sentDate: data.messageTimeStamp ?? Date(),
                                       kind: .text(text))
        print(data.messagecontentType)
        
        switch data.messagecontentType {
        case .text:
            messagestype = Messagetype(sender: sender,
                                       messageId: messageId,
                                       sentDate: data.messageTimeStamp ?? Date(),
                                       kind: .text(text))
            break
        case .post:
            
            break
        case .document:
            
            break
        case .image:
            let media = Media(url: URL(string:data.text ?? "www.google.com"),
                              image: nil,
                              placeholderImage: UIImage(named: "placeHolder")!,
                              size: CGSize(width: 300, height: 300))
            
            
            messagestype = Messagetype(sender: sender,
                                       messageId: messageId,
                                       sentDate: data.messageTimeStamp ?? Date(),
                                       kind: .photo(media))
            break
        case .video:
            
            break
        case .time:
            
            break
        case .attributedText:
            
            break
        case .location:
            
            break
        case .emoji:
            
            break
        case .audio:
            
            break
        case .contact:
            
            break
        case .custom:
        
            break
        case .linkPreview:
        
            break
        case .none:
            messagestype = Messagetype(sender: sender,
                                       messageId: messageId,
                                       sentDate: convertDate(dateValue: data.timeStamp ?? Int64(currentTimeInMilliSeconds())),
                                       kind: .text(text))
        }
        return messagestype!
    }
    
    func currentTimeInMilliSeconds()-> Int {
        let currentDate = Date()
        let since1970 = currentDate.timeIntervalSince1970
        return Int(since1970 * 1000)
    }
    
    
    func resetUserWith() {
        self.roomID = ""
        self.messages.removeAll()
        self.messagestype.removeAll()
        
        mineUnReadCount = 0
        otherUserUnReadCount = 0
        
        TAChatManager.shared.resetAllData()
        
        TAChatManager.shared.otherUserID = otherUserID
        

        
        TAChatManager.shared.getUserDetailFromID(userID: otherUserID)
        
        TAChatManager.shared.profileInfoReceivedBlock = { [self] profileInfo in
            let userName = profileInfo["userName"] as? String
            let profilePic = profileInfo["userProfilePic"] as? String
            let status = profileInfo["status"] as? String
            
            self.profileUserId = profileInfo["TAUid"] as? String ?? "0"
            TAChatManager.shared.otherUserToken = (profileInfo["token"] as? String)!
            if status == "offline" {
                if let data = self.roomInfoData {
                    if data.lastOnlieDateTime == "" || data.lastOnlieDateTime == nil{
                        self.NavProfileView.lblOnline.text = status
                    }else{
                        self.NavProfileView.lblOnline.text = data.lastOnlieDateTime
                    }
                    
                    //self.labelUserStatus.text = data.lastOnlieDateTime
                }else {
                    self.NavProfileView.lblOnline.text = status
                    //self.labelUserStatus.text = status
                }
            }else {
                self.NavProfileView.lblOnline.text = status
                //self.labelUserStatus.text = status
            }
            
            self.NavProfileView.lblOnline.isHidden = true
            
            self.NavProfileView.lblUserName.text = userName
            Get_Other_User_Name_For_Chat = userName ?? ""
            if profilePic == "" {
                self.NavProfileView.imgProfile.image = placeholderguest
            }else{
                self.NavProfileView.imgProfile.loadImageFromURL(url: profilePic, placeholderImage: placeholderguest)
            }
        }
        roomID = ""
        TAChatManager.shared.fetchRoom(ID:roomID)
        
        TAChatManager.shared.roomUnReadCountReceivedBlock = { roomData in
            
            self.roomDetails = roomData
            
            let userDetails = self.roomDetails!["users"]! as! [String:Any]
            
            self.otherUserUnReadCount = userDetails[self.otherUserID] as! Int
            
            self.mineUnReadCount = userDetails["TAU\(getUserID())"] as! Int
            print("From Notification")
            print(self.mineUnReadCount)
            print(self.unReadMessageArray.count)
            if(self.unReadMessageArray.count > 0){
                TAChatManager.shared.readAllMessage(allMessage: self.unReadMessageArray, userUnReadCount: self.mineUnReadCount)
                self.mineUnReadCount = 0
                self.unReadMessageArray.removeAll()
            }
        }
        
        //        TAChatManager.shared.addReadCountListner()
        // message recived latest
        TAChatManager.shared.messageModifiedBlock = { dataReturned in
            if(self.messages.count > 1){
                for (index,messageInfo) in self.messages.reversed().enumerated() {
                    if(messageInfo.messageID == dataReturned.messageID){
                        if messageInfo.ClearFor?["TAU\(getUserID())"] == false{
                            self.messages[((self.messages.count-1) - index)] = dataReturned
                            if let index = self.messagestype.firstIndex(where: { $0.messageId == dataReturned.messageID }) {
                                self.messagestype[index] = self.setMessageKitArray(data: dataReturned, isSender: dataReturned.isSender)
                            } else {
                                print("Not found")
                            }
                        }
                    }
                }
            }
            else{
                //Set
                self.messages = [dataReturned]
                self.messagestype = [self.setMessageKitArray(data: dataReturned, isSender: dataReturned.isSender)]
            }
            self.messagesCollectionView.reloadDataAndKeepOffset()
 
        }
        
        TAChatManager.shared.messageReceivedBlock = {[weak self] dataReturned in
            print(dataReturned)
            if let lastMessage = self?.messages.first{
                if(dataReturned.messageID != lastMessage.messageID){
                    if(Calendar.current.isDate( (lastMessage.messageTimeStamp!), inSameDayAs:dataReturned.messageTimeStamp!)){
                        if dataReturned.ClearFor?["TAU\(getUserID())"] == false{
                            self!.messages.insert(dataReturned, at: 0)
                            self!.messagestype.append(self!.setMessageKitArray(data: dataReturned, isSender: dataReturned.isSender))
                            
                            DispatchQueue.main.async {
                                self!.messagesCollectionView.scrollToItem(at: IndexPath(row: 0, section: self!.messagestype.count - 1), at: .top, animated: false)
                                self!.messagesCollectionView.scrollToLastItem()

                               }
                        }
                    }else{
                        let timeMessage = Message()
                        let previousDay = Calendar.current.date(byAdding: .day, value: -1, to: Date())
                        if(Calendar.current.isDate( (dataReturned.messageTimeStamp)!, inSameDayAs:Date())){
                            timeMessage.messageTime = "today"
                            timeMessage.messageType = .time
                        }
                        else if(Calendar.current.isDate( (dataReturned.messageTimeStamp)!, inSameDayAs:previousDay!)){
                            timeMessage.messageTime = "yesterday"
                            timeMessage.messageType = .time
                        }
                        else{
                            timeMessage.messageTime = self!.getStringDate(targetDate: (dataReturned.messageTimeStamp)!)
                            timeMessage.messageType = .time
                        }
                        if dataReturned.ClearFor?["TAU\(getUserID())"] == false{
                            self?.messages.insert(dataReturned, at: 0)
                            self!.messagestype.append(self!.setMessageKitArray(data: dataReturned, isSender: dataReturned.isSender))
//                            self!.messagestype.insert(self!.setMessageKitArray(data: dataReturned, isSender: dataReturned.isSender), at: 0)
                        }
                    }
                    
                    //self!.tableView.reloadData()
                    self!.messagesCollectionView.reloadDataAndKeepOffset()
                }
            }else{
                let timeMessage = Message()
                let previousDay = Calendar.current.date(byAdding: .day, value: -1, to: Date())
                if(Calendar.current.isDate( (dataReturned.messageTimeStamp)!, inSameDayAs:Date())){
                    timeMessage.messageTime = "today"
                    timeMessage.messageType = .time
                }
                else if(Calendar.current.isDate( (dataReturned.messageTimeStamp)!, inSameDayAs:previousDay!)){
                    timeMessage.messageTime = "yesterday"
                    timeMessage.messageType = .time
                }
                else{
                    timeMessage.messageTime = self!.getStringDate(targetDate: (dataReturned.messageTimeStamp)!)
                    timeMessage.messageType = .time
                }
                if dataReturned.ClearFor?["TAU\(getUserID())"] == false{
                    self?.messages.insert(timeMessage, at: 0)
                    self?.messages.insert(dataReturned, at: 0)
//                    self?.messages.insert(dataReturned, at: 0)
                    self?.messagestype.append(self!.setMessageKitArray(data: dataReturned, isSender: dataReturned.isSender))
//                    self!.messagestype.insert(self!.setMessageKitArray(data: dataReturned,isSender: dataReturned.isSender), at: 0)
                }
                //self!.tableView.reloadData()
                self!.messagesCollectionView.reloadDataAndKeepOffset()
            }
            
            if(dataReturned.isSender == false){
                if(self?.mineUnReadCount != 0){
                    TAChatManager.shared.readAllMessage(allMessage: [dataReturned], userUnReadCount: self!.mineUnReadCount)
                    self!.unReadMessageArray.removeAll()
                    self!.mineUnReadCount =  self!.mineUnReadCount - [dataReturned].count
                }
            }else{
                self!.messagesCollectionView.scrollsToTop = false
                //                self!.tableView.scrollToRow(at: IndexPath(item: 0, section: self!.messages.count-1), at: .bottom, animated: false)
            }
            
            //self?.tableView.infiniteScrollingView.stopAnimating()
            //self!.messagesCollectionView.stopAnimating()
        }
        
        TAChatManager.shared.stopLoadingBlock = {
     //       self.messagesCollectionView.reloadData()
        }
        
        TAChatManager.shared.messageArrayReceivedBlock = {[weak self] dataReturned in
            //Data is returned **Do anything with it **

            print("chats \(dataReturned)")
            let lastMsg = dataReturned.last?.messageID ?? ""
            
            if(dataReturned.count == 0){
                self!.isMoreData = false
            }
            
            for messageInfo in dataReturned{
                if(messageInfo.isSender == false){
                    if(messageInfo.messageRead == "0"){
                        self!.unReadMessageArray.append(messageInfo)
                    }
                }
                if((self?.messages.count)! > 0){
                    let previousMessage = self?.messages.last
                    if(previousMessage?.messageTimeStamp != nil && messageInfo.messageTimeStamp != nil){
                        if(Calendar.current.isDate( (previousMessage?.messageTimeStamp!)!, inSameDayAs:messageInfo.messageTimeStamp!)){
//                            if messageInfo.ClearFor?["TAU\(getUserID())"] == false{
//                            }
                            if messageInfo.ClearFor?["TAU\(getUserID())"] == false{

                                self?.messages.append(messageInfo)
//                                self!.messages.insert(messageInfo, at: 0)
                                self!.messagestype.insert(self!.setMessageKitArray(data: messageInfo,isSender: messageInfo.isSender), at: 0)
                                
                                
                                if messageInfo.messageID == lastMsg{
                                    let timeMessage2 = Message()
                                    if(Calendar.current.isDate( (messageInfo.messageTimeStamp)!, inSameDayAs:Date())){
                                        timeMessage2.messageTime = "today"
                                        timeMessage2.messageType = .time
                                    }
                                    else{
                                        let previousDay = Calendar.current.date(byAdding: .day, value: -1, to: Date())
                                        if(Calendar.current.isDate( (messageInfo.messageTimeStamp)!, inSameDayAs:previousDay!)){
                                            timeMessage2.messageTime = "yesterday"
                                            timeMessage2.messageType = .time
                                        }
                                        else{
                                            timeMessage2.messageTime = self!.getStringDate(targetDate: (messageInfo.messageTimeStamp)!)
                                            timeMessage2.messageType = .time
                                        }
                                    }
//                                    self?.messages.append(timeMessage2)
//                                    self!.messagestype.insert(self!.setMessageKitArray(data: timeMessage2,isSender: timeMessage2.isSender), at: 0)

                                }
                            }
                        }
                        else{
                            let timeMessage = Message()
                            if(Calendar.current.isDate( (previousMessage?.messageTimeStamp)!, inSameDayAs:Date())){
                                timeMessage.messageTime = "today"
                                timeMessage.messageType = .time
                            }
                            else{
                                let previousDay = Calendar.current.date(byAdding: .day, value: -1, to: Date())
                                if(Calendar.current.isDate( (previousMessage?.messageTimeStamp)!, inSameDayAs:previousDay!)){
                                    timeMessage.messageTime = "yesterday"
                                    timeMessage.messageType = .time
                                }
                                else{
                                    timeMessage.messageTime = self!.getStringDate(targetDate: (previousMessage!.messageTimeStamp)!)
                                    timeMessage.messageType = .time
                                }
                            }
                            if messageInfo.ClearFor?["TAU\(getUserID())"] == false{
//                                self?.messages.append(timeMessage)
//                                self!.messagestype.append(self!.setMessageKitArray(data: timeMessage,isSender: timeMessage.isSender))

                                if messageInfo.messageID == lastMsg{
                                    let timeMessage1 = Message()
                                    if(Calendar.current.isDate( (messageInfo.messageTimeStamp)!, inSameDayAs:Date())){
                                        timeMessage1.messageTime = "today"
                                        timeMessage1.messageType = .time
                                    }
                                    else{
                                        let previousDay = Calendar.current.date(byAdding: .day, value: -1, to: Date())
                                        if(Calendar.current.isDate( (messageInfo.messageTimeStamp)!, inSameDayAs:previousDay!)){
                                            timeMessage1.messageTime = "yesterday"
                                            timeMessage1.messageType = .time
                                        }
                                        else{
                                            timeMessage1.messageTime = self!.getStringDate(targetDate: (messageInfo.messageTimeStamp)!)
                                            timeMessage1.messageType = .time
                                        }
                                    }
                                    self?.messages.append(timeMessage1)
//                                    self?.messages.insert(timeMessage, at: 0)

                                }
                                self?.messages.append(messageInfo)
                                self!.messagestype.insert(self!.setMessageKitArray(data: messageInfo,isSender: messageInfo.isSender), at: 0)
                            }
                        }
                    }else{
                        if messageInfo.ClearFor?["TAU\(getUserID())"] == false{
                            self?.messages.append(messageInfo)
                            self?.messagestype.append(self!.setMessageKitArray(data: messageInfo,isSender: messageInfo.isSender))
//
//                            self!.messages.append(messageInfo)
//                            self!.messagestype.append(self!.setMessageKitArray(data: messageInfo,isSender: messageInfo.isSender))
                            
                            if messageInfo.messageID == lastMsg{
                                let timeMessage3 = Message()
                                if(Calendar.current.isDate( (messageInfo.messageTimeStamp)!, inSameDayAs:Date())){
                                    timeMessage3.messageTime = "today"
                                    timeMessage3.messageType = .time
                                }
                                else{
                                    let previousDay = Calendar.current.date(byAdding: .day, value: -1, to: Date())
                                    if(Calendar.current.isDate( (messageInfo.messageTimeStamp)!, inSameDayAs:previousDay!)){
                                        timeMessage3.messageTime = "yesterday"
                                        timeMessage3.messageType = .time
                                    }
                                    else{
                                        timeMessage3.messageTime = self!.getStringDate(targetDate: (messageInfo.messageTimeStamp)!)
                                        timeMessage3.messageType = .time
                                    }
                                }
//                                self?.messages.append(timeMessage3)
                                print("last Msg\(self?.messages.count ?? 0)")
//                                self?.messagestype.append(self!.setMessageKitArray(data: messageInfo, isSender: messageInfo.isSender))
//                                self?.messagestype.append(self!.setMessageKitArray(data: messageInfo, isSender: messageInfo.isSender))
                            }
                        }
//                        if messageInfo.ClearFor?["TAU\(getUserID())"] == false{
//                            self?.messages.append(messageInfo)
//                        }
                    }
                }
                else{
                    if messageInfo.ClearFor?["TAU\(getUserID())"] == false{
                        self?.messages.append(messageInfo)
                        self?.messagestype.append(self!.setMessageKitArray(data: messageInfo, isSender: messageInfo.isSender))
                        
                        if messageInfo.messageID == lastMsg{
                            let timeMessage1 = Message()
                            if(Calendar.current.isDate( (messageInfo.messageTimeStamp)!, inSameDayAs:Date())){
                                timeMessage1.messageTime = "today"
                                timeMessage1.messageType = .time
                            }
                            else{
                                let previousDay = Calendar.current.date(byAdding: .day, value: -1, to: Date())
                                if(Calendar.current.isDate( (messageInfo.messageTimeStamp)!, inSameDayAs:previousDay!)){
                                    timeMessage1.messageTime = "yesterday"
                                    timeMessage1.messageType = .time
                                }
                                else{
                                    timeMessage1.messageTime = self!.getStringDate(targetDate: (messageInfo.messageTimeStamp)!)
                                    timeMessage1.messageType = .time
                                }
                            }
                            self?.messages.append(timeMessage1)
                        }
                        
                        if (self?.isFirstTimeLoad == true) {
                            DispatchQueue.main.async {
                                self!.messagesCollectionView.scrollToItem(at: IndexPath(row: 0, section: self!.messagestype.count - 1), at: .top, animated: false)
                                self!.messagesCollectionView.scrollToLastItem()
                                self!.isFirstTimeLoad = false
                            }
                        }
                    }
                }
            }
            //                    print("From Loop")
            //                    print(self?.mineUnReadCount)
            //                    print(self?.unReadMessageArray.count)
            if(self?.mineUnReadCount ?? 0 > 0){
                TAChatManager.shared.readAllMessage(allMessage: self!.unReadMessageArray, userUnReadCount: self!.mineUnReadCount)
                self!.unReadMessageArray.removeAll()
                self!.mineUnReadCount = 0
            }
            self?.isLoadingMoreMessages = false
            self!.messagesCollectionView.reloadDataAndKeepOffset()
            //self?.tableView.infiniteScrollingView.stopAnimating()
        }
    }
    
    
    func getStringDate(targetDate:Date) -> String {
        let formatter = DateFormatter()
        // initially set the format based on your datepicker date / server String
        formatter.dateFormat = "dd-MMM-yyyy"
        let myString = formatter.string(from: targetDate)
        return myString
    }
        
    func readAllMessage(allMessage:[Message], userUnReadCount:Int) {
        var unReadCount = 0
        if(userUnReadCount > 0){
            unReadCount = userUnReadCount - allMessage.count
            if(unReadCount < 0){
                unReadCount = 0
            }
        }
        
        // Get new write batch
        let batch = db.batch()
        
        let docRef = db.collection("rooms").document(roomID)
        batch.updateData(["users.TAU\(getUserID())" : unReadCount], forDocument: docRef)
        
        for messageInfo in allMessage{
            
            let users = [
                otherUserID,
                "TAU\(getUserID())"
            ]
            
            let messageRef = db.collection("rooms").document(roomID).collection("messages").document(messageInfo.messageID!)
            batch.updateData(["msgtype": "1" ], forDocument: messageRef)
            batch.updateData(["readUsers":users], forDocument: messageRef)
        }
        
        // Commit the batch
        batch.commit() { err in
            if let err = err {
                print("Error writing batch \(err)")
            } else {
                print("Batch write succeeded.")
            }
        }
    }
 
    private func presentInputActionSheet() {
        let actionSheet = UIAlertController(title: "Attach Media",
                                            message: "Select your Photo",//What would you like to attach?
                                            preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Photo", style: .default, handler: { [weak self] _ in
            self?.presentPhotoInputActionsheet()
        }))
//        actionSheet.addAction(UIAlertAction(title: "Video", style: .default, handler: { [weak self]  _ in
//            self?.presentVideoInputActionsheet()
//        }))
//        actionSheet.addAction(UIAlertAction(title: "Audio", style: .default, handler: {  _ in
//
//        }))
//        actionSheet.addAction(UIAlertAction(title: "Location", style: .default, handler: { [weak self]  _ in
//            self?.presentLocationPicker()
//        }))
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

        present(actionSheet, animated: true)
    }
    
    private func presentLocationPicker() {
       
    }

    private func presentPhotoInputActionsheet() {
        let actionSheet = UIAlertController(title: "Attach Photo",
                                            message: "Where would you like to attach a photo from",
                                            preferredStyle: .actionSheet)
//        actionSheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: { [weak self] _ in
//
//            let picker = UIImagePickerController()
//            picker.sourceType = .camera
//            picker.delegate = self
//            picker.allowsEditing = true
//            self?.present(picker, animated: true)
//
//        }))
        actionSheet.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: { [weak self] _ in

            let picker = UIImagePickerController()
            picker.sourceType = .photoLibrary
            picker.delegate = self
            picker.allowsEditing = true
            self?.present(picker, animated: true)

        }))
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

        present(actionSheet, animated: true)
    }

    private func presentVideoInputActionsheet() {
        let actionSheet = UIAlertController(title: "Attach Video",
                                            message: "Where would you like to attach a video from?",
                                            preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: { [weak self] _ in

            let picker = UIImagePickerController()
            picker.sourceType = .camera
            picker.delegate = self
            picker.mediaTypes = ["public.movie"]
            picker.videoQuality = .typeMedium
            picker.allowsEditing = true
            self?.present(picker, animated: true)

        }))
        actionSheet.addAction(UIAlertAction(title: "Library", style: .default, handler: { [weak self] _ in

            let picker = UIImagePickerController()
            picker.sourceType = .photoLibrary
            picker.delegate = self
            picker.allowsEditing = true
            picker.mediaTypes = ["public.movie"]
            picker.videoQuality = .typeMedium
            self?.present(picker, animated: true)

        }))
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

        present(actionSheet, animated: true)
    }
    
    
    private func createMessageId() -> String? {
        // date, otherUesrEmail, senderEmail, randomInt
        guard let currentUserEmail = UserDefaults.standard.value(forKey: "email") as? String else {
            return "12"
        }

        let safeCurrentEmail = self.safeEmail(emailAddress: currentUserEmail)

        let dateString = Self.dateFormatter.string(from: Date())
        let newIdentifier = "\(otherUserEmail)_\(safeCurrentEmail)_\(dateString)"

        print("created message id: \(newIdentifier)")

        return newIdentifier
    }
}

extension ChatDetailViewController: InputBarAccessoryViewDelegate {
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        
        guard !text.replacingOccurrences(of: " ", with: "").isEmpty,
            let selfSender = self.selfSender,
            let messageId = createMessageId() as? String else {
                return
        }

        print("Sending: \(text)")
        
        let mmessage = Messagetype(sender: selfSender,
                                   messageId: messageId,
                                   sentDate: Date(),
                                   kind: .text(text))

        //self.messagestype.append(mmessage)
        if roomDetails?.count != nil {
            let userDetails = self.roomDetails!["users"]! as! [String:Any]
            self.otherUserUnReadCount = userDetails[self.otherUserID] as! Int
        }
        
        
        TAChatManager.shared.sendMessageToRoom(msgType: .text, text: text,withUnReadCount: self.otherUserUnReadCount + 1, typeDataType: mmessage)
        var userId = otherUserID
        if userId.hasPrefix("TAU") {
            userId = String(userId.dropFirst(3))
        }
        let user_id = Int(userId) ?? 0
        self.messageInputBar.inputTextView.text = nil
        self.messagesCollectionView.reloadDataAndKeepOffset()
        
        let contentHeight = messagesCollectionView.contentSize.height
        let visibleHeight = messagesCollectionView.frame.height - messagesCollectionView.contentInset.top - messagesCollectionView.contentInset.bottom
        let shouldScroll = contentHeight > visibleHeight
        
        if shouldScroll {
            messagesCollectionView.scrollToLastItem(animated: true)
        }
    }
}
//MARK: - MessagesLayoutDelegate Method
extension ChatDetailViewController: MessagesDataSource, MessagesLayoutDelegate, MessagesDisplayDelegate {
   
    func currentSender() -> any MessageKit.SenderType {
        if let sender = selfSender {
            return sender
        }
        fatalError("Self Sender is nil, email should be cached")
    }
    
    var currentSenders: MessageKit.SenderType {
        if let sender = selfSender {
            return sender
        }
        fatalError("Self Sender is nil, email should be cached")
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
       // return messages[indexPath.section]
         return messagestype[indexPath.section]
    }
    
    func messageTimestampLabelAttributedText(for message: MessageType, at _: IndexPath) -> NSAttributedString? {
      let sentDate = message.sentDate
      let sentDateString = MessageKitDateFormatter.shared.string(from: sentDate)
      let timeLabelFont: UIFont = .boldSystemFont(ofSize: 10)
      let timeLabelColor: UIColor = .systemGray
      return NSAttributedString(
        string: sentDateString,
        attributes: [NSAttributedString.Key.font: timeLabelFont, NSAttributedString.Key.foregroundColor: timeLabelColor])
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messagestype.count
    }
    
    func messageColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return UIColor(named: "AccentColor") ?? .systemPink
    }

    
    func textColor(for message: MessageType, at _: IndexPath, in _: MessagesCollectionView) -> UIColor {
         isFromCurrentSender(message: message) ? .black : .white
     }
    
    func messageTopLabelAttributedText(for message: MessageType, at _: IndexPath) -> NSAttributedString? {
      let name = message.sender.displayName
      return NSAttributedString(
        string: name,
        attributes: [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .caption1)])
    }
    
    func cellTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 20
    }
    
    func messageBottomLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        let isCurrentUser = message.sender.senderId == selfSender?.senderId
        return isCurrentUser && messageRead == "1" && messagestype.count - 1 == indexPath.section ? 15 : 0
    }
    
    func messageBottomLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        
//        let isLastMessage = indexPath.section == messages.endIndex
        let isCurrentUser = message.sender.senderId == selfSender?.senderId
        if messageRead == "1" && isCurrentUser{
            if (messagestype.count - 1 == indexPath.section) {
                return NSAttributedString(
//                    string: "read",
                    string: "",
                    attributes: [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .caption1)])
            }else{
                return NSAttributedString(
                    string: "",
                    attributes: [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .caption2)])
            }
             
            } else {
                return NSAttributedString(
                    string: "",
                    attributes: [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .caption2)])
            }

        return NSAttributedString(
            string: "",
            attributes: [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .caption2)])
    }
    
    func messageStyle(for message: MessageType, at _: IndexPath, in _: MessagesCollectionView) -> MessageStyle {
        let tail: MessageStyle.TailCorner = isFromCurrentSender(message: message) ? .bottomRight : .bottomLeft
        return .bubbleTail(tail, .pointedEdge)
    }
    
    func cellTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
      if indexPath.section % 10 == 0 {
        return NSAttributedString(
          string: MessageKitDateFormatter.shared.string(from: message.sentDate),
          attributes: [
            NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 10),
            NSAttributedString.Key.foregroundColor: UIColor.darkGray,
          ])
      }
      return nil
    }
    
    func configureMediaMessageImageView(_ imageView: UIImageView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        guard let message = message as? Messagetype else {
            return
        }
        
        switch message.kind {
        case .photo(let media):
            guard let imageUrl = media.url else {
                return
            }
            imageView.sd_setImage(with: imageUrl, completed: nil)
        default:
            break
        }
    }

    func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        let sender = message.sender
        if sender.senderId == selfSender?.senderId {
            // our message that we've sent
            return UIColor(hex: "#F2F6F9")
        }else {
            return UIColor(named: "AccentColor")!
        }

        return .secondarySystemBackground
    }
}

extension ChatDetailViewController {
    func avatarSize(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGSize {
        return CGSize(width: 0, height: 0)
    }
    
    func messagePadding(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIEdgeInsets {
        
        guard let message = message as? Messagetype else {
            return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        }
        
        switch message.kind {
        case .photo(let media):
            return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        default:
            break
        }
        
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
            avatarView.isHidden = true
    }
    
    func configureAccessoryView(_ accessoryView: UIView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
         // Hide the accessory view (read/unread label)
         accessoryView.isHidden = true
     }
}

extension ChatDetailViewController {
    func didTapBackground(in cell: MessageKit.MessageCollectionViewCell) {
    
    }
    
    func didTapMessage(in cell: MessageKit.MessageCollectionViewCell) {
        
    }
    
    func didTapAvatar(in cell: MessageKit.MessageCollectionViewCell) {
        
    }
    
    func didTapCellTopLabel(in cell: MessageKit.MessageCollectionViewCell) {
        
    }
    
    func didTapCellBottomLabel(in cell: MessageKit.MessageCollectionViewCell) {
        
    }
    
    func didTapMessageTopLabel(in cell: MessageKit.MessageCollectionViewCell) {
        
    }
    
    func didTapMessageBottomLabel(in cell: MessageKit.MessageCollectionViewCell) {
        
    }
    
    func didTapAccessoryView(in cell: MessageKit.MessageCollectionViewCell) {
        
    }
    
    func didTapImage(in cell: MessageKit.MessageCollectionViewCell) {
        print("Hello")
        
    }
    
    func didTapPlayButton(in cell: MessageKit.AudioMessageCell) {
        
    }
    
    func didStartAudio(in cell: MessageKit.AudioMessageCell) {
        
    }
    
    func didPauseAudio(in cell: MessageKit.AudioMessageCell) {
        
    }
    
    func didStopAudio(in cell: MessageKit.AudioMessageCell) {
        
    }
}


extension ChatDetailViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
    
          guard let selectedImage = (info[.editedImage] as? UIImage) ?? (info[.originalImage] as? UIImage) else {
              print("No valid image found.")
              return
          }

          self.uploadSavedData(img: selectedImage) { url in
              guard let url = url else {
                  print("Failed to upload image and retrieve URL.")
                  return
              }
              
              let media = Media(url: url,
                                image: nil,
                                placeholderImage: UIImage(named: "placeHolder")!,
                                size: CGSize(width: 130, height: 130))
              
              let mmessage = Messagetype(sender: self.selfSender!,
                                         messageId: self.createMessageId() ?? "12",
                                         sentDate: Date(),
                                         kind: .photo(media))
              
              TAChatManager.shared.sendMessageToRoom(msgType: .image, text: url.absoluteString, withUnReadCount: self.otherUserUnReadCount + 1, typeDataType: mmessage)
              self.messagesCollectionView.reloadDataAndKeepOffset()
          }
    }
    
    func uploadSavedData(img: UIImage, completion: @escaping (URL?) -> Void) {
        guard let data = img.pngData() else {
            print("Error: Could not convert image to data")
            completion(nil)
            return
        }
        
        let storageRef = Storage.storage().reference()
        let filePath = "userUID/files/TAU\(getUserID())_\(Date().millisecondsSince1970).png"
        let fileRef = storageRef.child(filePath)
        
        let metadata = StorageMetadata()
        metadata.contentType = "image/png"
        
        fileRef.putData(data, metadata: metadata) { (metadata, error) in
            if let error = error {
                print("Error during upload: \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            fileRef.downloadURL { (url, error) in
                if let error = error {
                    print("Error retrieving download URL: \(error.localizedDescription)")
                    completion(nil)
                    return
                }
                guard let downloadURL = url else {
                    print("Download URL is nil")
                    completion(nil)
                    return
                }
                print(downloadURL) // Prints the URL to the newly uploaded data.
                completion(downloadURL)
            }
        }
    }

}

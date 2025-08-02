//
//  TAChatModels.swift
//  Messenger
//
//  Created by Krunal Nagvadia on 01/03/24.
//  Copyright © 2024 Techavtra. All rights reserved.
//

import Foundation
import CoreLocation
import MessageKit
import UIKit
import FirebaseFirestore


class Message: NSObject{
   
    var image:UIImage?
    var text:String?
    var isSender:Bool = true
    var messageType:chatMessageType?
    var mediaUrl:URL?
    var documentData:Data?
    var messageStatus:MessageStatus?
    var messageID:String?
    var messageTime:String?
    var messageTimeStamp:Date?
    var messageRead:String?
    var timeStamp:Int64?
    var postId: String?
    var postMsg: String?
    var postImg:String?
    var postType : String?
    var ClearFor : [String:Bool]?
    var DeleteConversationFor : [String:Bool]?
    var DeleteFor : [String:Bool]?
    var messagecontentType : MessageContentType?
    
    init?(document: QueryDocumentSnapshot) {
        
        let data = document.data()
        
        messageID = document.documentID
        //        self.sentDate = sentDate.dateValue()
        text = dataDetector(message: data["msg"] as? String ?? "")
        
        timeStamp = (data["timestamp"] as? Int64) ?? 1590135471
        
        let dateValue = (data["timestamp"] as? Int64) ?? 1590135471
    
        if let rawValue = data["msgContentType"] as? String {
            messagecontentType =  MessageContentType(rawValue: rawValue)
        }
        
        let newDate = Date.init(milliseconds: dateValue)
        messageTimeStamp = newDate
        if(messageTimeStamp != nil){
            messageTime = TAChatManager.shared.convertDateToTime(date: messageTimeStamp!)
        }
        
        if let sharedPostData = data["sharedPostDetails"] as? [String:Any] {
            postImg = sharedPostData["imageUrl"] as? String
            postId = sharedPostData["postID"] as? String
            postMsg = sharedPostData["postMessage"] as? String
            postType = sharedPostData["postType"] as? String
            if postType != "" {
                messageType = .post
            }else {
                messageType = .text
            }
        }else {
            messageType = .text
        }
        
        if(data["uid"] as? String == "TAU\(getUserID())"){
            isSender = true
        }else{
            isSender = false
        }
        ClearFor = data["ClearFor"] as? [String: Bool]
        DeleteFor = data["DeleteFor"] as? [String: Bool]
        DeleteConversationFor = data["DeleteConversationFor"] as? [String: Bool]
        messageRead = data["msgtype"] as? String ?? "1"
        

    }
    
    override init(){
        
    }
    
//    required init(
//        sender: SenderType?,
//        messageId: String?,
//        sentDate: Date?,
//        kind: MessageKind?
//    ) {
//        self.sender: sender
//        self.messageId: messageId
//        self.sentDate: sentDate
//        self.kind: kind
//    }
}

struct Messagetype: MessageType {
    public var sender: SenderType
    public var messageId: String
    public var sentDate: Date
    public var kind: MessageKind
}

struct Sender: SenderType {
    public var photoURL: String
    public var senderId: String
    public var displayName: String
}

struct Media: MediaItem {
    var url: URL?
    var image: UIImage?
    var placeholderImage: UIImage
    var size: CGSize
}

struct Location: LocationItem {
    var location: CLLocation
    var size: CGSize
}

enum MessageStatus {
    case delivered
    case read
    case failed
}

enum chatMessageType{
    case text 
    case post
    case document
    case image
    case video
    case time
    case attributedText
    case location
    case emoji
    case audio
    case contact
    case custom
    case linkPreview
}

enum MessageContentType : String {
    case text = "text"
    case post = "post"
    case document = "document"
    case image = "image"
    case video = "video"
    case time = "time"
    case attributedText = "attributedText"
    case location = "location"
    case emoji = "emoji"
    case audio = "audio"
    case contact = "contact"
    case custom = "custom"
    case linkPreview = "linkPreview"
}


extension MessageKind {
    var messageKindString: String {
        switch self {
        case .text(_):
            return "text"
        case .attributedText(_):
            return "attributed_text"
        case .photo(_):
            return "photo"
        case .video(_):
            return "video"
        case .location(_):
            return "location"
        case .emoji(_):
            return "emoji"
        case .audio(_):
            return "audio"
        case .contact(_):
            return "contact"
        case .custom(_):
            return "customc"
        case .linkPreview(_):
            return "link"
        }
    }
}




class ChatMessage: NSObject {

    var messageID:String?
    var sentDate:Date?
    var senderID:String?
    var recipientID:String?
    var message:String?
    var seenByReceipent:Bool?
    
    init?(document: QueryDocumentSnapshot) {
        let data = document.data()
        messageID = document.documentID
//        self.sentDate = sentDate.dateValue()
        message = data["msg"] as? String ?? ""
        self.seenByReceipent = true
    }
}

class RoomInfo: NSObject {
    
    var roomID:String?
    var messgaeDateTime:Date?
    var messgaeTime:String?
    var otherUserID:String?
    var otherUserName:String?
    var otherUserStatus:String?
    var otherUserProfile:String?
    var message:String?
    var seenByReceipent:Bool?
    var unReadMessageCount:Int?
    var lastOnlieDateTime: String?
    var imgBGColor : UIColor = UIColor.random()
    var deleteConversationFor : [String:Bool]?
    var ClearFor : [String: Bool]?
    var DeleteFor : [String: Bool]?
    var isStaticData: Bool? = false
    override init() {
        super.init()
    }
    
    
    init?(document: QueryDocumentSnapshot) {
        
        let data = document.data()
        
        roomID = document.documentID
        
        let dateValue = (data["timestamp"] as? Int64) ?? 1590135471
        
        //        let newDate = TWChatManager.shared.convertStringToDate(dateValue)
        
        let newDate = Date.init(milliseconds: dateValue)
        messgaeDateTime = newDate
        if(messgaeDateTime != nil){
            messgaeTime = TAChatManager.shared.convertDateToTime(date: messgaeDateTime!)
            let previousDay = Calendar.current.date(byAdding: .day, value: -1, to: Date())
            if(Calendar.current.isDate( (messgaeDateTime)!, inSameDayAs:Date())){
                
            }else if(Calendar.current.isDate( (messgaeDateTime)!, inSameDayAs:previousDay!)){
                messgaeTime = "Yesterday"
            }else{
                messgaeTime = TAChatManager.shared.getStringDate(targetDate: (messgaeDateTime)!)
            }
        }
        message = dataDetector(message:  data["msg"] as? String ?? "")
        
        let userObj = data["users"] as? [String : Any]
        let userIDs = userObj?.keys
        
        for obj in userIDs!{
            if(obj != "TAU\(getUserID())"
            ){
                otherUserID = obj
            }
        }
        unReadMessageCount = userObj!["TAU\(getUserID())"] as? Int
        deleteConversationFor = data["DeleteConversationFor"] as? [String: Bool]
        ClearFor = data["ClearFor"] as? [String: Bool]
        DeleteFor = data["DeleteFor"] as? [String: Bool]
        //        otherUserID = day
        
    }
}
 



//MARK: Chat Helper Methods
func getUserID() -> String{
    guard let usr = Global.user else {
        return "0"
    }
    return "\(usr.id!)"
}

func get_user_user_name() -> String{
    guard let usr = Global.user else {
        return "Test"
    }
    return usr.name ?? ""
}

func get_Fcm_id() -> String {
    return "12312ca14521wer121f3s61212132146121567wwerwdfs"
}

func get_user_image() -> String{
    guard let usr = Global.user else {
        return ""
    }
    return usr.profileImage?.first ?? ""
}


func getEmail() -> String{
    guard let usr = Global.user else {
        return "test0@gmail.com"
    }
    return usr.email ?? ""
}


func dataDetector(message:String) -> String{
    do {
        let detector = try NSDataDetector(types: NSTextCheckingResult.CheckingType.phoneNumber.rawValue)
        let matches = detector.matches(in: message, range: NSRange(message.startIndex..., in: message))
        for match in matches{
            if match.resultType == .phoneNumber, let number = match.phoneNumber {
                let result = hideMidChars(number)
                print(number)
                print(result)
                return message.replacingOccurrences(of: number, with: result)
            }
        }
    } catch {
        print(error)
        return error.localizedDescription
    }
    
    return message
}

func hideMidChars(_ value: String) -> String {
   return String(value.enumerated().map { index, char in
      return [0, 1, value.count - 1, value.count - 2].contains(index) ? char : "*"
   })
}

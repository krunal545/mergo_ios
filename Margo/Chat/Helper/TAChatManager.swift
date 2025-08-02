//
//  TAChatManager.swift
//  FirebaseChat
//
//  Created by Techavtra's Mac Mini on 27/02/24.
//

import Foundation
import Firebase
import FirebaseFirestore
import MessageKit
import FirebaseDatabase

enum UserStatus:String{
    case Offline
    case Online
}




typealias messageReceived = (_ infoToReturn : Message) ->()
typealias profileInfoReceived = (_ infoToReturn : [String:Any]) ->()
typealias roomUnReadCountReceived = (_ infoToReturn : [String:Any]) ->()
typealias messageModified = (_ infoToReturn : Message) ->()
typealias messageArrayReceived = (_ infoToReturn : [Message]) ->()
typealias stopLoading = () ->()
typealias profilelistReceived = (_ infoToReturn : [[String:Any]]) ->()
typealias roomlistModified = (_ infoToReturn : RoomInfo) ->()
typealias roomlistReceived = (_ infoToReturn : [RoomInfo]) ->()
typealias roomNewRecordReceived = (_ infoToReturn : RoomInfo) ->()
typealias roomlistNoData = (_ infoToReturn : String) ->()

class TAChatManager {
    
    static var shared : TAChatManager = TAChatManager()
    var seenUserIDs = Set<String>()
    var userCollection:CollectionReference?
    let db = Firestore.firestore()
    var userDocumentID:String?
    var lastSnapShot:QueryDocumentSnapshot?
    var otherUserToken = ""
    var singleListener:ListenerRegistration?
    var modifiedListner:ListenerRegistration?
    var multipleListener:ListenerRegistration?
    var unReadCountListener:ListenerRegistration?
    var lastSnapShotOfRoom:QueryDocumentSnapshot?
    var roomID = "TAU0_TAU1"
    var otherUserID = "TAU1"
    var updateExistingRoomInfo:roomlistModified?
    var profileInfoReceivedBlock:profileInfoReceived?
    var roomUnReadCountReceivedBlock:roomUnReadCountReceived?
    var messageReceivedBlock:messageReceived?
    var messageModifiedBlock:messageModified?
    var messageArrayReceivedBlock:messageArrayReceived?
    var profilelistReceivedBlock:profilelistReceived?
    var roomlistModifiedBlock:roomlistModified?
    var roomlistNoDataBlock:roomlistNoData?
    var roomNewRecordReceivedBlock:roomNewRecordReceived?
    var roomlistReceivedBlock:roomlistReceived?
    var roomListListner:ListenerRegistration?
    var stopLoadingBlock:stopLoading?
    //MARK: Methods
    
    
    func InitializeUser() {
        self.userCollection = db.collection("users")
        self.createUser()
    }
    
    func createUser() {
        self.userCollection?.document("TAU\(getUserID())").setData(["userName": get_user_user_name(),
                                                              "email": getEmail(),
                                                              "fireBaseId": "TAU\(getUserID())",
                                                              "platform" : "iOS",
                                                              "lastSeen" : getCurrentTime(),
                                                              "status" : "Online",
                                                              "TAUid" : getUserID(),
                                                              "token" : get_Fcm_id(),//getDeviceID()
                                                              "userProfilePic" : get_user_image()], completion: { (err) in
            if let err = err {
                print("Error adding document: \(err)")
            } else {
                self.userDocumentID = "TAU\(getUserID())"
                print("Document added")
                
            }
        })
    }
    
    func createOtherUser() {
        self.userCollection?.document("TAU\(getUserID())").setData(["userName": get_user_user_name(),
                                                              "email": getEmail(),
                                                              "fireBaseId": "TAU\(getUserID())",
                                                              "platform" : "iOS",
                                                              "lastSeen" : getCurrentTime(),
                                                              "status" : "Online",
                                                              "TAUid" : getUserID(),
                                                              "token" : get_Fcm_id(),//getDeviceID()
                                                              "userProfilePic" : get_user_image()], completion: { (err) in
            if let err = err {
                print("Error adding document: \(err)")
            } else {
                self.userDocumentID = "TAU\(getUserID())"
                print("Document added")
                
            }
        })
    }
    
    func resetAllData() {
        self.lastSnapShot = nil
        self.roomID = ""
        self.otherUserID = ""
        self.otherUserToken = ""
        
        self.singleListener?.remove()
        self.modifiedListner?.remove()
        
        self.multipleListener?.remove()
        self.lastSnapShotOfRoom = nil
        self.unReadCountListener?.remove()
    }
    
    func getUserDetailFromID(userID:String) {
        print(userID)
        let fetchQuery = userCollection?.whereField("fireBaseId", isEqualTo:userID)
        fetchQuery?.getDocuments(completion: { (queryResult, error) in
            if let err = error {
                print("Error getting documents: \(err)")
            }else{
                if(queryResult!.documents.count == 0){
                    self.createUser()
                }else{
                    for document in queryResult!.documents {
                        print("\(document.documentID) => \(document.data())")
                        self.profileInfoReceivedBlock!(document.data())
                    }
                }
            }
        })
    }
    
    func fetchRoom(ID:String) {
        if(ID == ""){
            let messageRef = db.collection("rooms")
            
            let msgFetchQuery = messageRef.whereField("users.TAU\(getUserID())", isGreaterThanOrEqualTo: 0)
            
            msgFetchQuery.getDocuments { (queryResult, error) in
                if let err = error {
#if DEBUG
                    print("Error getting documents: \(err)")
#else
                    print("I'm running in a non-DEBUG mode")
#endif
                } else {
                    if(queryResult!.documents.count == 0){
                        //                self.createUser()
                        
                    }else{
                        for document in queryResult!.documents {
#if DEBUG
                            print("\(document.documentID) => \(document.data())")
                            print(document.data()["users"])
#else
#endif
                          
                            let userData:[String : Any] = document.data()["users"] as! [String : Any]
                            let allKeys = userData.keys
                            if(allKeys.contains(self.otherUserID)) {
                                self.roomID = document.documentID
                                self.fetchInitialMessages()
                                self.addReadCountListner()
                                break;
                            }
                        }
                    }
                    
                }
            }
        }else{
            //fetch directly with room id
            self.roomID = ID
            self.fetchInitialMessages()
            self.addReadCountListner()
        }
    }
    
    func fetchInitialMessages(){
        let first = db.collection("rooms").document(self.roomID).collection("messages")
            .limit(to: 15).order(by:"timestamp",descending: true)
        first.getDocuments { (queryResult, error) in
            self.addListenerToRoom()
            self.handleDocumentChanges(queryResult!.documentChanges)
            
            if((queryResult?.documents.count)! > 0){
                
                self.lastSnapShot = queryResult?.documents.last
            }
        }
    }
    
    
    func fetchMessages()
    {
        if(lastSnapShot != nil)
        {
            let first = db.collection("rooms").document(self.roomID).collection("messages")
                .limit(to: 15).order(by:"timestamp",descending: true).start(afterDocument: lastSnapShot!)
            first.getDocuments { (queryResult, error) in
                if(self.stopLoadingBlock != nil){
                    self.stopLoadingBlock!()
                }
                if(self.lastSnapShot == nil){
                    queryResult!.documentChanges.forEach { change in
                        self.handleDocumentChange(change)
                    }
                }
                else{
                    self.handleDocumentChanges(queryResult!.documentChanges)
                }
                if((queryResult?.documents.count)! > 0){
                    self.lastSnapShot = queryResult?.documents.last
                }
            }
        }
    }
    
    
    
    func addListenerToRoom(){
        if(self.roomID == ""){
            return;
        }
        let first = db.collection("rooms").document(self.roomID).collection("messages")
            .limit(to: 1).order(by:"timestamp",descending: true)
        
        singleListener = first.addSnapshotListener(includeMetadataChanges: false) { (querySnapshot, err) in
            guard let snapshot = querySnapshot else {
#if DEBUG
                print("Error listening for channel updates: \(err?.localizedDescription ?? "No error")")
#else
#endif
                return
            }
            guard let snap = snapshot.documents.last else {
                // The collection is empty.
                return
            }
            
            snapshot.documentChanges.forEach { change in
                if(change.type == .added){
                    self.handleDocumentChange(change)
                }
            }
        }
        
        let modified = db.collection("rooms").document(self.roomID).collection("messages")
            .order(by:"timestamp",descending: true)
        
        modifiedListner = modified.addSnapshotListener(includeMetadataChanges: false) { (querySnapshot, err) in
            guard let snapshot = querySnapshot else {
                print("Error listening for channel updates: \(err?.localizedDescription ?? "No error")")
                return
            }
            guard let snap = snapshot.documents.last else {
                // The collection is empty.
                return
            }
            
            snapshot.documentChanges.forEach { change in
                if(change.type == .modified){
                    self.handleDocumentChange(change)
                }
            }
        }
    }
    
    private func handleDocumentChange(_ change: DocumentChange) {
        guard let message = Message(document: change.document) else {
            return
        }
        
        switch change.type {
        case .added:
            if(self.messageReceivedBlock != nil){
                self.messageReceivedBlock!(message)
            }
            //          insertNewMessage(message)
        case .modified:
            if(self.messageModifiedBlock != nil){
                self.messageModifiedBlock!(message)
            }
            
        default:
            break
        }
    }
    
    private func handleDocumentChanges(_ changes: [DocumentChange]) {
        
        var messageArray:[Message] = []
        
        changes.forEach { change in
            let messageInfo = Message.init(document: change.document)
            
            if messageInfo?.ClearFor?["TAU\(getUserID())"] == false{
                messageArray.append(messageInfo!)
            }
        }
        
        self.messageArrayReceivedBlock!(messageArray)
    }
    
    func addReadCountListner() {
        //        let otherUserID = "TWU1756"
        let first = db.collection("rooms").document(self.roomID)
        
        unReadCountListener = first.addSnapshotListener(includeMetadataChanges: false) { (querySnapshot, err) in
            guard let snapshot = querySnapshot else {
                print("Error listening for channel updates: \(err?.localizedDescription ?? "No error")")
                return
            }
            if querySnapshot?.data() != nil{
                self.roomUnReadCountReceivedBlock!((querySnapshot?.data())!)
            }
            //            guard let snap = snapshot.documents.last else {
            //                // The collection is empty.
            //                return
            //            }
            //            _ = querySnapshot!.metadata.hasPendingWrites ? "Local Vivek" : "Server Vivek"
            //            if(self.lastSnapShot != nil){
            //                snapshot.documentChanges.forEach { change in
            //                    self.handleDocumentChange(change)
            //                }
            //            }
            //            else{
            //                self.lastSnapShot = snap
            //                self.handleDocumentChanges(snapshot.documentChanges)
            //            }
            
            
        }
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
    
    func sendMessageToRoom(msgType:MessageContentType,text:String, withUnReadCount:Int,typeDataType:MessageType){
        //let otherUserID = "TWU1"
        //roomID = "TWU\(getUserID())_\(otherUserID)"
        if(roomID == ""){
            createRoom(msgType: msgType, withMessage: text,withUnReadCount: withUnReadCount, typeDataType: typeDataType)
        }
        else{
            createRoom(msgType: msgType, withMessage: text,withUnReadCount: withUnReadCount, typeDataType: typeDataType)
            sendMessage(msgType: msgType, text:text, needToSubscribe: false, typeDataType: typeDataType)
            
        }
        //        document("messages").collection("messages")
        
    }
    
    
    
    func callFirebaseOfflneOnlineStatus() {
        // Set persistence before any other usage of the FIRDatabase instance
//        Database.database().isPersistenceEnabled = true
        
        // Firebase
        DispatchQueue.main.async {
           let ref = Database.database().reference()
            let connectedRef = Database.database().reference(withPath: ".info/connected")
            
            connectedRef.observe(.value, with: { snapshot in
                if let isConnected = snapshot.value as? Bool, isConnected {
                    print("Connected")
                    //                var user =
                    
                    var userId = getUserID()
                    
                    let statusRef = Database.database().reference(withPath: "status/TWU\(userId)")
                    statusRef.setValue("online") { (error, _) in
                        if let error = error {
                            print("Error setting value: \(error.localizedDescription)")
                        } else {
                            print("Online status set successfully")
                        }
                    }
                    statusRef.onDisconnectSetValue("offline") { (error, _) in
                        if let error = error {
                            print("Error setting disconnect value: \(error.localizedDescription)")
                        } else {
                            print("Disconnect value set successfully")
                        }
                    }
                    
                } else {
                    print("Not connected")
                }
            })
        }
    }
    
    
    
    
    func createRoom(msgType:MessageContentType,withMessage:String, withUnReadCount:Int,typeDataType:MessageType) {
        //        let otherUserID = "TWU1756"
        let users = ["TAU\(getUserID())" : 0,
                     otherUserID:withUnReadCount
        ]
        let deleteData = [
            "TAU\(getUserID())" : true,
            otherUserID : true
        ]
        
        let clearData = [
            "TAU\(getUserID())" : false,
            otherUserID : false
        ]
        
        let deleteConversion = [
            "TAU\(getUserID())" : true,
            otherUserID : true
        ]
        
        if(roomID == ""){
            let newRoom = "TAU\(getUserID())_\(otherUserID)"
            let idsArray = ["TAU\(getUserID())", otherUserID] // Create an array containing the IDs
            db.collection("rooms").document(newRoom).setData([
                "msg": withMessage,
                "msgContentType": msgType.rawValue,
                "msgtype": "0",
                "timestamp": Date().millisecondsSince1970,
                "title" : "",
                "uid" : "TAU\(getUserID())",
                "users" : users,
                "DeleteFor" : deleteData,
                "DeleteConversationFor" : deleteConversion,
                "ClearFor" : clearData,
                "roomId" : roomID,
                "content" : "",
                "ids" : idsArray // Set the array as the value for the "ids" field
            ]) { (err) in
                if let err = err {
                    print("Error adding document: \(err)")
                } else {
                    self.roomID = newRoom
                    self.sendMessage(msgType: msgType, text:withMessage, needToSubscribe: true, typeDataType: typeDataType)
                    print("Room Created")
                    
                }
            }
            
        }
        else{
            db.collection("rooms").document(roomID).updateData([
                "msg": withMessage,
                "msgContentType": msgType.rawValue,
                "msgtype": "0",
                "timestamp": Date().millisecondsSince1970,
                "title" : "",
                "uid" : "TAU\(getUserID())",
                "DeleteConversationFor" : deleteConversion,
                "users" : users,
                "DeleteFor" : deleteData,
                "ClearFor" : clearData,
                "roomId" : roomID,
                "content" : ""

            ]) { (err) in
                if let err = err {
                    print("Error adding document: \(err)")
                } else {
                    print("Room Created")
                }
            }
        }
    }
    
    func sendMessage(msgType:MessageContentType,text:String, needToSubscribe:Bool,typeDataType:MessageType){
        let deleteData = [
            "TAU\(getUserID())" : true,
            otherUserID : true
        ]
        
        let deleteConversion = [
            "TAU\(getUserID())" : true,
            otherUserID : true
        ]
        
        let clearData = [
            "TAU\(getUserID())" : false,
            otherUserID : false
        ]
        
        let readUsers = [
            "TAU\(getUserID())"
        ]
        
        db.collection("rooms").document(roomID).collection("messages").addDocument(data: [
            "msg": text,
            "msgtype": "0",
            "msgContentType": msgType.rawValue,
            "timestamp": Date().millisecondsSince1970,
            "title" : "",
            "uid" : "TAU\(getUserID())",
            "DeleteFor" : deleteData,
            "DeleteConversationFor" : deleteConversion,
            "ClearFor" : clearData,
            "readUsers" : readUsers,
            "roomId" : roomID,
            "content" : ""
        ]) { (err) in
            if let err = err {
                print("Error adding document: \(err)")
            } else {
                if(needToSubscribe){
                    self.addListenerToRoom()
                }
                print("Room Message Sent")
                
            }
        }
        ///
    }
    
    func fetchUserProfiles(userArray:[RoomInfo]) {
        var userIDs:[String] = []
        for roomDetail in userArray{
            if roomDetail.otherUserID != nil{
                userIDs.append(roomDetail.otherUserID!)
            }else {
                print("OtherUserId is Nil")
            }
        }
        
        var fetchID:[String] = []
        for item in userIDs{
            fetchID.append(item)
            if(fetchID.count == 10){
                let profileQuery = db.collection("users").whereField("fireBaseId", in:fetchID)
                
                profileQuery.getDocuments { (queryResult, error) in
                    
                    var  userData:[[String:Any]] = []
                    
                    for document in queryResult!.documents {
                        print("\(document.documentID) => \(document.data())")
                        userData.append(document.data())
                    }
                    if self.profilelistReceivedBlock != nil{
                        self.profilelistReceivedBlock!(userData)
                    }
                }
                
                fetchID.removeAll()
            }
        }
        
        if(fetchID.count > 0){
            let profileQuery = db.collection("users").whereField("fireBaseId", in:fetchID)
            
            profileQuery.getDocuments { (queryResult, error) in
                
                var  userData:[[String:Any]] = []
                
                for document in queryResult!.documents {
                    print("\(document.documentID) => \(document.data())")
                    userData.append(document.data())
                }
                if self.profilelistReceivedBlock != nil{
                    self.profilelistReceivedBlock!(userData)
                }
            }
        }
    }
    
    func resetAllRoomData() {
        self.roomListListner?.remove()
    }
    
    func DeleteUser(){
        let myFireBaseId = "TAU\(getUserID())"
        
        db.collection("users").whereField("ids",arrayContains: myFireBaseId).getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    document.reference.delete { error in
                        if let error = error {
                            print("Error deleting document: \(error)")
                        } else {
                            print("Document successfully deleted")
                            SBUtill.showToastWith("Deleted User")
                        }
                    }
                    print(document.reference)
                    SBUtill.showToastWith("Deleted User")
                }
            }
        }
    }
    
    
    func deleteRoomData(userId: String, otherUserId: String, isFromChatDetails:Bool) {
        let roomId1 = "\(userId)_\(otherUserId)"
        let roomId2 = "\(otherUserId)_\(userId)"
        
        let messageRef = db.collection("rooms")
        
        let deleteDocument: (String) -> Void = { roomId in
               messageRef.document(roomId).delete { error in
                   if let error = error {
                       print("Error deleting document \(roomId): \(error)")
                   } else {
                       print("Document \(roomId) successfully deleted")
                       print("Deleted Room")
                       
                       let settings = FirestoreSettings()
                       settings.isPersistenceEnabled = false
                       if isFromChatDetails {
                           NotificationCenter.default.post(name: NSNotification.Name("RoomDeleted"), object: nil, userInfo: ["roomId": roomId1])
                       }
                   }
                   return
               }
        }
        
        messageRef.document(roomId1).getDocument { (document, error) in
               if let document = document, document.exists {
                   deleteDocument(roomId1)
               } else {
                   messageRef.document(roomId2).getDocument { (document, error) in
                       if let document = document, document.exists {
                           deleteDocument(roomId2)
                       } else if let error = error {
                           print("Error getting documents: \(error)")
                       } else {
                           print("No such document exists with IDs \(roomId1) or \(roomId2)")
                           if isFromChatDetails {
                               NotificationCenter.default.post(name: NSNotification.Name("RoomDeleted"), object: nil, userInfo: ["roomId": roomId1])
                           }
                       }
                   }
               }
           }
    }
    
    func fetchInitialRoomList() {
        
        let myFireBaseId = "TAU\(getUserID())"

        
        
        let first = db.collection("rooms")
            .whereField("ids", arrayContains: myFireBaseId)
            .order(by: "timestamp", descending: true)
//            .limit(to: 1) // Fetch initial 10 rooms        //.limit(to: 10)
        
        //        first = db.collection("rooms").order(by:"timestamp",descending: true)

        roomListListner = first.addSnapshotListener(includeMetadataChanges: true) { [weak self] (querySnapshot, error) in
            guard let self = self else { return }
            
            if let error = error {
                print("Error listening for channel updates: \(error.localizedDescription)")
                return
            }
            
            guard let snapshot = querySnapshot else {
                print("No data available")
                return
            }
            
            if snapshot.isEmpty {
                print("No documents found")
                //NotificationCenter.default.post(name: NSNotification.Name("RoomDeleted"), object: nil, userInfo: ["isFromRoomList": true])
                return
            }
            
            for documentChange in snapshot.documentChanges {
                switch documentChange.type {
                case .added, .modified:
                    // Handle new message or modified message
                    self.handleRoomDocumentChange(documentChange)
                case .removed:
                    // Handle removal if needed
                    print("Document removed: \(documentChange.document.documentID)")
                    NotificationCenter.default.post(name: NSNotification.Name("RoomDeleted"), object: nil, userInfo: ["roomId": documentChange.document.documentID])
                }
            }

            // Fetch more rooms if available
            if let lastSnapshot = snapshot.documents.last {
                let lastDocumentTimestamp = lastSnapshot.get("timestamp") as? Timestamp ?? Timestamp(date: Date())
                lastDocumentIDs = lastSnapshot.documentID
                // fetchMoreRooms(lastDocumentTimestamp: lastDocumentTimestamp, lastDocumentID: lastSnapshot.documentID)
            }
        }
    }
    
    
    
    
    func fetchMoreRooms(lastDocumentTimestamp: Timestamp, lastDocumentID: String?, completion: @escaping (Result<Void, Error>) -> Void) {
        let myFireBaseId = "TAU\(getUserID())"
        
        var nextQuery = db.collection("rooms")
            .whereField("ids", arrayContains: myFireBaseId)
            .order(by: "timestamp", descending: true)
            .start(after: [lastDocumentTimestamp])
//            .limit(to: 1)
        
        if let lastDocumentID = lastDocumentID {
            let lastDocumentReference = db.collection("rooms").document(lastDocumentID)
            lastDocumentReference.getDocument { [weak self] (documentSnapshot, error) in
                guard let self = self else { return }
                
                if let error = error {
                    print("Error fetching last document: \(error.localizedDescription)")
                    completion(.failure(error)) // Call completion with error
                    return
                }
                
                guard let documentSnapshot = documentSnapshot, documentSnapshot.exists else {
                    // Handle the case where the document does not exist or could not be fetched
                    print("Document does not exist or could not be fetched")
                    self.fetchInitialRoomList()
                    NotificationCenter.default.post(name: NSNotification.Name("RoomDeleted"), object: nil, userInfo: ["isFromRoomList": true])
                    completion(.failure(NSError(domain: "FirestoreErrorDomain", code: -1, userInfo: [NSLocalizedDescriptionKey: "Document does not exist or could not be fetched"])))
                    return
                }
                
                // Update the query to start after the fetched document
                nextQuery = nextQuery.start(afterDocument: documentSnapshot)
                
                // Fetch documents using the updated query
                nextQuery.getDocuments { [weak self] (querySnapshot, error) in
                    guard let self = self else { return }
                    
                    if let error = error {
                        print("Error fetching documents: \(error.localizedDescription)")
                        completion(.failure(error)) // Call completion with error
                        return
                    }
                    
                    guard let querySnapshot = querySnapshot else {
                        print("Query snapshot is nil")
                        completion(.failure(NSError(domain: "FirestoreErrorDomain", code: -1, userInfo: [NSLocalizedDescriptionKey: "Query snapshot is nil"])))
                        return
                    }
                    
                    for documentChange in querySnapshot.documentChanges {
                        self.handleRoomDocumentChange(documentChange)
                    }
                    
                    if let lastSnapshot = querySnapshot.documents.last {
                        lastDocumentIDs = lastSnapshot.documentID
                    }
                    
                    completion(.success(())) // Call completion with success
                }
            }
        } else {
            // Fetch documents using the initial query
            nextQuery.getDocuments { [weak self] (querySnapshot, error) in
                guard let self = self else { return }
                
                if let error = error {
                    print("Error fetching documents: \(error.localizedDescription)")
                    completion(.failure(error)) // Call completion with error
                    return
                }
                
                guard let querySnapshot = querySnapshot else {
                    print("Query snapshot is nil")
                    completion(.failure(NSError(domain: "FirestoreErrorDomain", code: -1, userInfo: [NSLocalizedDescriptionKey: "Query snapshot is nil"])))
                    return
                }
                
                for documentChange in querySnapshot.documentChanges {
                    self.handleRoomDocumentChange(documentChange)
                }
                
                if let lastSnapshot = querySnapshot.documents.last {
                    lastDocumentIDs = lastSnapshot.documentID
                }
                
                completion(.success(())) // Call completion with success
            }
        }
    }
    private func handleRoomDocumentChanges(_ changes:[DocumentChange]){
        var roomInfo:[RoomInfo] = []
        
        changes.forEach { change in
            print("===> \n", change.document.data())
            
            if let GetData = change.document.data()["DeleteConversationFor"] as? [String:Bool]{
                
                if GetData["TAU\(getUserID())"] == true{
                    let roomDetail = RoomInfo.init(document: change.document)
                    roomInfo.append(roomDetail!)
                }
            }
        }
        
        if(self.roomlistReceivedBlock != nil){
            self.roomlistReceivedBlock!(roomInfo)
        }
    }
    
    private func handleRoomDocumentChange(_ change: DocumentChange) {
        guard let room = RoomInfo(document: change.document) else {
            return
        }

        switch change.type {
        case .added, .modified:
            // Check if the user ID already exists in the dictionary/set
            print(room.otherUserID)
            print(room.otherUserID != "")
            if room.otherUserID != ""{
                if !seenUserIDs.contains(room.otherUserID ?? "") {
                    print(seenUserIDs)
                    seenUserIDs.insert(room.otherUserID ?? "")
                    self.roomlistModifiedBlock?(room)
                    
                } else {
                    print("Else\(seenUserIDs)")
                    // Handle the case where the user is already visible
                    // You might want to update the existing entry here if needed
// For example, update the last online time or any other relevant information
                    self.updateExistingRoomInfo?(room)
                }
            }
        case .removed:
            // Handle removal if needed
            print("Document removed: \(change.document.documentID)")
        }
    }
    
}

//MARK: Time & Date
extension TAChatManager {
    
    func getCurrentTime() -> String {
        let currentTime = Date()
        let requireDateFormat = DateFormatter.init()
        requireDateFormat.dateFormat = "hh:mm a"
        let cTime = requireDateFormat.string(from: currentTime)
        return cTime
    }
    
    func convertDateToTime(date:Date) -> String {
        let requireDateFormat = DateFormatter.init()
        requireDateFormat.dateFormat = "hh:mm a"
        let cTime = requireDateFormat.string(from: date)
        return cTime
    }
    
    func getStringDate(targetDate:Date) -> String {
        let formatter = DateFormatter()
        // initially set the format based on your datepicker date / server String
        formatter.dateFormat = "dd-MMM-yyyy"
        let myString = formatter.string(from: targetDate)
        return myString
    }
}

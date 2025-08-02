//
//  QRUsers.swift
//  Margo
//
//  Created by Dharmesh A Nagvadia on 31/01/25.
//

import Foundation
import SwiftyJSON

class QRUsers {

    var id: Int?
    var updatedAt: String?
    var string: Int?
    var user: QRUserData?
    var userId: Int?
    var createdAt: String?
    var qrCode: String?

    init(_ json: JSON) {
        id = json["id"].intValue
        updatedAt = json["updated_at"].stringValue
        string = json["string"].intValue
        user = QRUserData(json["user"])
        userId = json["user_id"].intValue
        createdAt = json["created_at"].stringValue
        qrCode = json["qr_code"].stringValue
    }

}

class QRUserData {

    var datingIntentionsVisible: Int?
    var platform: String?
    var id: Int?
    var status: Int?
    var gender: Int?
    var phoneNo: String?
    var lastName: String?
    var apiToken: String?
    var description: String?
    var profileImage: [String]?
    var userType: Int?
    var long: String?
    var address: String?
    var countryCode: String?
    var dob: String?
    var lat: String?
    var height: String?
    var email: String?
    var deviceToken: String?
    var name: String?
    var datingIntentions: String?
    var is_liked: Bool?

    init(_ json: JSON) {
        datingIntentionsVisible = json["dating_intentions_visible"].intValue
        platform = json["platform"].stringValue
        id = json["id"].intValue
        status = json["status"].intValue
        gender = json["gender"].intValue
        phoneNo = json["phone_no"].stringValue
        lastName = json["last_name"].stringValue
        apiToken = json["api_token"].stringValue
        description = json["description"].stringValue
        profileImage = json["profile_image"].arrayValue.map { $0.stringValue }
        userType = json["user_type"].intValue
        long = json["long"].stringValue
        address = json["address"].stringValue
        countryCode = json["country_code"].stringValue
        dob = json["dob"].stringValue
        lat = json["lat"].stringValue
        height = json["height"].stringValue
        email = json["email"].stringValue
        deviceToken = json["device_token"].stringValue
        name = json["name"].stringValue
        datingIntentions = json["dating_intentions"].stringValue
        is_liked = json["is_liked"].boolValue
    }

}

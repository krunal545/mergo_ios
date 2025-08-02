//
//  MDUser.swift
//  Meekle
//
//  Created by xuser on 03/06/24.
//

import Foundation
import Alamofire
import SwiftyJSON

class MDUser {

    var message: String?
    var data: User?

    init(_ json: JSON) {
        message = json["message"].stringValue
        data = User(json["data"])
    }

}

class User:NSObject ,NSCoding{
    
    var id: Int?
    var userType: Int?
    var name: String?
    var lastName: String?
    var email: String?
    var countryCode: String?
    var phoneNo: String?
    var gender: Int?
    var height: String?
    var dob: String?
    var lat: String?
    var long: String?
    var city: String?
    var state: String?
    var address: String?
    var datingIntension:String?
    var datingIntentionsVisible: Int?
    var profileImage: [String]?
    var preference: Int?
    var education: String?
    var school: String?
    var zodiac: String?
    var lang: String?
    var profession: String?
    var company: String?
    var lookingFor: Int?
    var user_description: String? //"Property 'description' with type 'String?' cannot override a property with type 'String' aa Error na lidhe name "description" ni badle "user_description" krel che
    var emailVerifiedAt: String?
    var apiToken: String?
    var platform: String?
    var deviceToken: String?
    var status: Int?
    var postCount: Int?
    var postSpotlightCount: Int?
    var applyCount: Int?
    var applySpotlightCount: Int?
    var notification_dot: Bool?
    var notification: String?
    var likedStatus : Int?
    var scaned_qr_code : String?
    init(_ json: JSON) {
        
        id = json["id"].intValue
        userType = json["user_type"].intValue
        name = json["name"].stringValue
        lastName = json["last_name"].stringValue
        email = json["email"].stringValue
        countryCode = json["country_code"].stringValue
        phoneNo = json["phone_no"].stringValue
        gender = json["gender"].intValue
        height = json["height"].stringValue
        dob = json["dob"].stringValue
        lat = json["lat"].stringValue
        long = json["long"].stringValue
        city = json["city"].stringValue
        state = json["state"].stringValue
        address = json["address"].stringValue
        datingIntension = json["dating_intentions"].stringValue
        datingIntentionsVisible = json["dating_intentions_visible"].intValue
        profileImage = json["profile_image"].arrayValue.map { $0.stringValue }
        preference = json["preference"].intValue
        education = json["education"].stringValue
        school = json["school"].stringValue
        zodiac = json["zodiac"].stringValue
        lang = json["lang"].stringValue
        profession = json["profession"].stringValue
        company = json["company"].stringValue
        lookingFor = json["looking_for"].intValue
        user_description = json["description"].stringValue
        emailVerifiedAt = json["email_verified_at"].stringValue
        apiToken = json["api_token"].stringValue
        platform = json["platform"].stringValue
        deviceToken = json["device_token"].stringValue
        status = json["status"].intValue
        postCount = json["post_count"].intValue
        postSpotlightCount = json["post_spotlight_count"].intValue
        applyCount = json["apply_count"].intValue
        applySpotlightCount = json["apply_spotlight_count"].intValue
        notification_dot = json["notification_dot"].boolValue
        likedStatus = json["like_status"].intValue
        notification = json["notification"].stringValue
        scaned_qr_code = json["scaned_qr_code"].stringValue
    }
    func encode(with aCoder: NSCoder) {
        aCoder.encode(id, forKey : "id")
        aCoder.encode(userType, forKey: "userType")
        aCoder.encode(name, forKey: "name")
        aCoder.encode(lastName, forKey: "last_name")
        aCoder.encode(email, forKey: "email")
        aCoder.encode(countryCode, forKey: "countryCode")
        aCoder.encode(phoneNo, forKey: "phoneNo")
        aCoder.encode(gender, forKey: "gender")
        aCoder.encode(height, forKey: "height")
        aCoder.encode(dob, forKey: "dob")
        aCoder.encode(lat, forKey: "lat")
        aCoder.encode(long, forKey: "long")
        aCoder.encode(city, forKey: "city")
        aCoder.encode(state, forKey: "state")
        aCoder.encode(address, forKey: "address")
        aCoder.encode(datingIntension, forKey: "datingIntension")
        aCoder.encode(datingIntentionsVisible, forKey: "datingIntentionsVisible")
        aCoder.encode(profileImage, forKey: "profileImage")
        aCoder.encode(preference, forKey: "preference")
        aCoder.encode(education, forKey: "education")
        aCoder.encode(zodiac, forKey: "zodiac")
        aCoder.encode(profession, forKey: "profession")
        aCoder.encode(lookingFor, forKey: "lookingFor")
        aCoder.encode(user_description, forKey: "description")
        aCoder.encode(emailVerifiedAt, forKey: "emailVerifiedAt")
        aCoder.encode(apiToken, forKey: "apiToken")
        aCoder.encode(platform, forKey: "platform")
        aCoder.encode(deviceToken, forKey: "deviceToken")
        aCoder.encode(status, forKey: "status")
        aCoder.encode(company, forKey: "company")
        aCoder.encode(school, forKey: "school")
        aCoder.encode(postCount, forKey: "postCount")
        aCoder.encode(postSpotlightCount, forKey: "postSpotlightCount")
        aCoder.encode(applyCount, forKey: "applyCount")
        aCoder.encode(applySpotlightCount, forKey: "applySpotlightCount")
        aCoder.encode(lang, forKey: "lang")
        aCoder.encode(notification_dot, forKey: "notification_dot")
        aCoder.encode(notification, forKey: "notification")
        aCoder.encode(scaned_qr_code, forKey: "scaned_qr_code")
    }
    
    required init?(coder decoder: NSCoder) {
        id = decoder.decodeObject(forKey: "id") as? Int
        userType = decoder.decodeObject(forKey: "userType") as? Int
        name = decoder.decodeObject(forKey: "name") as? String
        lastName = decoder.decodeObject(forKey: "last_name") as? String
        email = decoder.decodeObject(forKey: "email") as? String
        countryCode = decoder.decodeObject(forKey: "countryCode") as? String
        phoneNo = decoder.decodeObject(forKey: "phoneNo") as? String
        gender = decoder.decodeObject(forKey: "gender") as? Int
        height = decoder.decodeObject(forKey: "height") as? String
        dob = decoder.decodeObject(forKey: "dob") as? String
        lat = decoder.decodeObject(forKey: "lat") as? String
        long = decoder.decodeObject(forKey: "long") as? String
        city = decoder.decodeObject(forKey: "city") as? String
        state = decoder.decodeObject(forKey: "state") as? String
        address = decoder.decodeObject(forKey: "address") as? String
        datingIntension = decoder.decodeObject(forKey: "datingIntension") as? String
        datingIntentionsVisible = decoder.decodeObject(forKey: "datingIntentionsVisible") as? Int
        profileImage = decoder.decodeObject(forKey: "profileImage") as? [String]
        preference = decoder.decodeObject(forKey: "preference") as? Int
        education = decoder.decodeObject(forKey: "education") as? String
        zodiac = decoder.decodeObject(forKey: "zodiac") as? String
        profession = decoder.decodeObject(forKey: "profession") as? String
        lookingFor = decoder.decodeObject(forKey: "lookingFor") as? Int
        user_description = decoder.decodeObject(forKey: "description") as? String
        emailVerifiedAt = decoder.decodeObject(forKey: "emailVerifiedAt") as? String
        apiToken = decoder.decodeObject(forKey: "apiToken") as? String
        platform = decoder.decodeObject(forKey: "platform") as? String
        deviceToken = decoder.decodeObject(forKey: "deviceToken") as? String
        status = decoder.decodeObject(forKey: "status") as? Int
        company = decoder.decodeObject(forKey: "company") as? String
        school = decoder.decodeObject(forKey: "school") as? String
        postCount = decoder.decodeObject(forKey: "postCount") as? Int
        postSpotlightCount = decoder.decodeObject(forKey: "postSpotlightCount") as? Int
        applyCount = decoder.decodeObject(forKey: "applyCount") as? Int
        applySpotlightCount = decoder.decodeObject(forKey: "applySpotlightCount") as? Int
        lang = decoder.decodeObject(forKey: "lang") as? String
        notification_dot = decoder.decodeObject(forKey: "notification_dot") as? Bool
        notification = decoder.decodeObject(forKey: "notification") as? String
        scaned_qr_code = decoder.decodeObject(forKey: "scaned_qr_code") as? String
    }
    
    func saveInUserDefaults() {
        let data = NSKeyedArchiver.archivedData(withRootObject: self) as Data
        UserDefault[KeyMessage.UserKey] = data
    }
}

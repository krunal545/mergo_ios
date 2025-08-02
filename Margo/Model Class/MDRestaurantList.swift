//
//  MDRestaurantList.swift
//  Margo
//
//  Created by xuser on 07/02/25.
//

import Foundation
import SwiftyJSON

class MDRestaurantList {

    var updatedAt: String?
    var createdAt: String?
    var id: Int?
    var code: String?
    var description: String?
    var address: String?
    var title: String?
    var userIds: Any?
    var image: String?
    var latitude: String?
    var longitude: String?
    var country: String?
    var type: Int?
    
    init(_ json: JSON) {
        updatedAt = json["updated_at"].stringValue
        createdAt = json["created_at"].stringValue
        id = json["id"].intValue
        code = json["code"].stringValue
        description = json["description"].stringValue
        address = json["address"].stringValue
        title = json["title"].stringValue
        userIds = json["user_ids"]
        image = json["image"].stringValue
        type = json["type"].intValue
    }

}

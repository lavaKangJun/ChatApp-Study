//
//  Message.swift
//  FirebaseChat
//
//  Created by 강준영 on 09/04/2019.
//  Copyright © 2019 강준영. All rights reserved.
//

import Foundation
import  Firebase
class Message: NSObject {
    var toId: String?
    var fromId: String?
    var timestampe: Int?
    var text: String?
    var imageUrl: String?
    var imageHeight: Int?
    var imageWidth: Int?
    
    func chatParterId() -> String? {
        let user = Auth.auth().currentUser?.uid
        return user == toId ? fromId : toId
    }
    
    init(dictionary: [String: AnyObject]) {
        super.init()
        fromId = dictionary["fromId"] as? String
        toId = dictionary["toId"] as? String
        text = dictionary["text"] as? String
        timestampe = dictionary["timestampe"] as? Int
        imageUrl = dictionary["imageUrl"] as? String
        imageHeight = dictionary["imageHeight"] as? Int
        imageWidth = dictionary["imageWidth"] as? Int
        
    }
    
}

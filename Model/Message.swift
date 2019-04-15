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
    
    func chatParterId() -> String? {
        let user = Auth.auth().currentUser?.uid
        return user == toId ? fromId : toId
    }
    
}

//
//  User.swift
//  InstaSampleSwift5
//
//  Created by Sample on 2020/05/02.
//  Copyright © 2020 sample.com. All rights reserved.
//

import UIKit

class User {
    var objectId: String
    var userName: String
    var displayName: String?
    var introduction: String?
    
    init(objectId: String, userName: String) {
        self.objectId = objectId
        self.userName = userName
    }
}

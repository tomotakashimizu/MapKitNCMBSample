//
//  Post.swift
//  InstaSampleSwift5
//
//  Created by Sample on 2020/05/02.
//  Copyright © 2020 sample.com. All rights reserved.
//

import UIKit
import NCMB

class Post {
    var objectId: String
    var createDate: Date
    var geoPoint: NCMBGeoPoint
    
    init(objectId: String, createDate: Date, geoPoint: NCMBGeoPoint) {
        self.objectId = objectId
        self.createDate = createDate
        self.geoPoint = geoPoint
    }
}

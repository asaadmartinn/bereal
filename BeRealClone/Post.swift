//  Post.swift
//  BeRealClone
//  Created by Amir on 2/29/24.

import Foundation
import ParseSwift

struct Post: ParseObject {
    var objectId: String?
    var createdAt: Date?
    var updatedAt: Date?
    var ACL: ParseACL?
    var originalData: Data?

    var caption: String?
    var user: User?
    var imageFile: ParseFile?
    var location: String?
    var createdTime: Date?
}

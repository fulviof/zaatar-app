//
//  Photo.swift
//  app
//
//  Created by Fulvio Fanelli on 13/07/19.
//  Copyright © 2019 zaatar. All rights reserved.
//

import Foundation

class Photo : Codable {
    let contentType: String
    let createdAt: String
    let data: String
    let name: String
    let updatedAt: String
    
    init(contentType: String, createdAt: String, data: String, name: String, updatedAt: String) {
        self.contentType = contentType
        self.createdAt = createdAt
        self.data = data
        self.name = name
        self.updatedAt = updatedAt
    }
}

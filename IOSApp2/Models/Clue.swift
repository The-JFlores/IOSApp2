//
//  Clue.swift
//  IOSApp2d
//
//  Created by Jose Flores on 2025-10-01.

import Foundation

struct Clue: Identifiable, Codable {
    let id: UUID
    var title: String
    var hint: String
    var lat: Double
    var lon: Double
    var address: String?
    var website: String?
    var isFound: Bool = false
    var userPhotoData: Data? = nil
    var photoDate: String? = nil

    init(id: UUID = UUID(),
         title: String,
         hint: String,
         lat: Double = 0,
         lon: Double = 0,
         address: String? = nil,
         website: String? = nil,
         isFound: Bool = false,
         userPhotoData: Data? = nil,
         photoDate: String? = nil) {
        self.id = id
        self.title = title
        self.hint = hint
        self.lat = lat
        self.lon = lon
        self.address = address
        self.website = website
        self.isFound = isFound
        self.userPhotoData = userPhotoData
        self.photoDate = photoDate
    }
}

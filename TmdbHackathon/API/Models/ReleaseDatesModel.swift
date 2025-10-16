//
//  ReleaseDatesModel.swift
//  TmdbHackathon
//
//  Created by DeQuan Douglas on 10/13/25.
//


import Foundation

struct ReleaseDatesModel: Codable {
    var results: [ReleaseResults]?
    
    private enum CodingKeys: String, CodingKey {
        case results
    }
}

struct ReleaseResults: Codable {
    var country: String?
    var releaseDates: [CertificationResults]?
    
    private enum CodingKeys: String, CodingKey {
        case country = "iso_3166_1"
        case releaseDates = "release_dates"
    }
}

struct CertificationResults: Codable {
    var certification: String?
    var type: Int?
}

//
//  VideoModel.swift
//  TmdbHackathon
//
//  Created by DeQuan Douglas on 10/13/25.
//


import Foundation

struct VideoModel: Codable {
    let results: [VideoObjects]?
    
    private enum CodingKeys: String, CodingKey {
        case results
    }
}

struct VideoObjects: Codable {
    let key: String?
    let site: String?
    let type: String?
}

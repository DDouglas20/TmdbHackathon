//
//  MovieModel.swift
//  TmdbHackathon
//
//  Created by DeQuan Douglas on 10/13/25.
//


import Foundation

struct MovieModel: Codable {
    var page: Int?
    var results: [MovieResults]?
    var totalPages: Int?
    var totalResults: Int?
    
    private enum CodingKeys: String, CodingKey {
        case page = "page"
        case results = "results"
        case totalPages = "total_pages"
        case totalResults = "total_results"
    }
}

struct MovieResults: Codable {
    var adult: Bool?
    var backdrop_path: String?
    var genre_ids: [Int]?
    var id: Int?
    var original_language: String?
    var original_title: String?
    var overview: String?
    var popularity: Double?
    var poster_path: String?
    var release_date: String?
    var title: String?
    var video: Bool?
    var vote_average: Double?
    var vote_count: Int?
}

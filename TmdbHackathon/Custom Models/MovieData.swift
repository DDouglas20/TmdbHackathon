//
//  MovieData.swift
//  TmdbHackathon
//
//  Created by DeQuan Douglas on 10/15/25.
//


import Foundation

/// The model we will use to normalize all of the Popular json data
struct MovieData: Hashable {
    var id: Int? // Movie id
    var isAdult: Bool? // If the movie is for adults only
    var movieName: String?
    var movieRating: Double?
    var reviewCount: Int?
    var releaseDate: String?
    var overview: String?
    var genreIds: [Int]?
    var portaitPath: String?
    var landscapePath: String?
    
    // Details we will need another api call for
    var budget: Int?
    var revenue: Int?
    var runtime: Int?
    var productionCompanies: [ProductionCompanies]?
    var youtubeId: String? // The video key used in the youtube url
    var director: Director?
    var categories: [String]? = []
    var certification: String?
    
    init(movie: MovieResults) {
        self.id = movie.id
        self.isAdult = movie.adult
        self.movieName = movie.original_title
        self.movieRating = movie.vote_average
        self.reviewCount = movie.vote_count
        self.releaseDate = movie.release_date
        self.overview = movie.overview
        self.genreIds = movie.genre_ids
        self.portaitPath = movie.poster_path
        self.landscapePath = movie.backdrop_path
    }
    
}

struct Director: Hashable {
    var id: Int
    var name: String
    var jobs: [String]
}

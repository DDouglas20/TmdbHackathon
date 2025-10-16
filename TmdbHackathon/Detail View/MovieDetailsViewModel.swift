//
//  MovieDetailsViewModel.swift
//  TmdbHackathon
//
//  Created by DeQuan Douglas on 10/15/25.
//


import Foundation


class MovieDetailsViewModel: ObservableObject { // We use observable object here because there's many more values that need to be ignored than published
    // MARK: Properties
    @Published var showDirPage: Bool = false
    @Published var showAlert: Bool = false
    
    let movieObject: MovieData
    
    let directorBaseUrl = "https://themoviedb.org/person/" // Non api link
    
    var movieId: Int {
        return movieObject.id ?? -1
    }
    
    var movieTitle: String {
        return movieObject.movieName ?? "No Certification Found"
    }
    
    var youtubeId: String? {
        return movieObject.youtubeId
    }
    
    var landscapePath: URL? {
        guard let backdropPath = movieObject.landscapePath else { return nil }
        return URL(string: "https://image.tmdb.org/t/p/w1280" + backdropPath)
    }
    
    var movieDescription: String {
        return movieObject.overview ?? "Couldn't Load Information"
    }
    
    var rating: Double {
        return (movieObject.movieRating ?? 0.0) / 2
    }
    
    var movieCert: String { // Movie certs can be unrated
        if let cert = movieObject.certification, !cert.isEmpty {
            return cert
        }
        return "Unrated"
    }
    
    var releaseDate: String {
        return movieObject.releaseDate ?? "Couldn't Load Information"
    }
    
    var movieCategories: String {
        guard let categories = movieObject.categories else { return "" }
        var categoryString: String = ""
        for (index, category) in categories.enumerated() {
            if index == categories.count - 1 {
                categoryString += category
                break
            }
            categoryString += category + ", "
        }
        return categoryString
    }
    
    var duration: String {
        return formatDuration(movieObject.runtime)
    }
    
    var director: String {
        return movieObject.director?.name ?? "Unknown Director"
    }
    
    var directorJobs: String {
        guard let dirJobs = movieObject.director?.jobs else { return ""}
        var jobsString = ""
        for (index, job) in dirJobs.enumerated() {
            if index == dirJobs.count - 1 {
                jobsString += job
                break
            }
            jobsString += job + ", "
        }
        return jobsString
    }
    
    var directorId: String {
        return "\(movieObject.director?.id ?? -1)"
    }
    
    var directorUrl: URL?
    
    struct ProductionData: Hashable {
        var name: String
        var logoUrl: URL
    }
    
    var productionData: [ProductionData] {
        guard let companies = movieObject.productionCompanies else { return [] }
        var prodData: [ProductionData] = []
        for company in companies {
            if let logoPath = company.logoPath, let logoUrl = URL(string: "https://image.tmdb.org/t/p/w300/\(logoPath)") {
                prodData.append(.init(name: company.name ?? "Uknown Company", logoUrl: logoUrl))
                continue
            }
        }
        return prodData
        
    }
    
    // MARK: Init
    init(movieObject: MovieData) {
        self.movieObject = movieObject
    }
    
    // MARK: Functions
    
    func validateDirectorUrl() {
        guard let url = URL(string: directorBaseUrl + directorId) else {
            showAlert = true
            return
        }
        directorUrl = url
        showDirPage = true
    }
    
    private func formatDuration(_ duration: Int?) -> String {
        guard let duration else { return ""}
        let hours = duration / 60
        let minutes = duration % 60
        
        var durationParts: [String] = []
        
        if hours > 0 {
            let inflectedString = String(AttributedString(localized: "^[\(hours) hour](inflect: true)").characters)
            durationParts.append(inflectedString)
        }
        
        if minutes > 0 || (hours == 0 && minutes == 0) {
            let inflectedString = String(AttributedString(localized: "^[\(minutes) minute](inflect: true)").characters)
            durationParts.append(inflectedString)
        }
        
        return durationParts.joined(separator: " ")
    }
}

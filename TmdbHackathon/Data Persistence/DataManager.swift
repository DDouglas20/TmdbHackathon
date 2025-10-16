//
//  DataManager.swift
//  TmdbHackathon
//
//  Created by DeQuan Douglas on 10/13/25.
//

import Foundation

final class DataManager {
    static let shared = DataManager()
    
    let digitalType = 4 // Digital only releases like Amazon Prime / Netflix
    
    let theaterType = 3 // Theatrical releases
    
    let usCode = "US" // US Country code
    
    var movies = [MovieData]()
    
    var genreMap: [Int: String] = [:]
    
    // MARK: Functions
    // Adds the various movie details to our custom object that holds movie data
    func addVideoData(for id: Int, key: String?) {
        guard let key, let index = movies.firstIndex(where: { $0.id == id}) else {
            print("Could not match id with key")
            return
        }
        movies[index].youtubeId = key
    }
    
    func addMovieDetailsData(for id: Int, details: MovieDetails) {
        guard let index = movies.firstIndex(where: { $0.id == id}) else {
            print("Could not match id with key")
            return
        }
        movies[index].budget = details.budget
        movies[index].revenue = details.revenue
        movies[index].runtime = details.runtime
        movies[index].productionCompanies = details.productionCompanies
    }
    
    func addCertDetails(for id: Int, details: [ReleaseResults]?) {
        guard let details, let movieIndex = movies.firstIndex(where: { $0.id == id}) else { return }
        if let index = details.firstIndex(where: { $0.country == usCode }),
           let releaseResults = details[index].releaseDates,
           let mainReleaseIndex = releaseResults.firstIndex(where: { ($0.type == theaterType) || ($0.type == digitalType)})
        {
            movies[movieIndex].certification = releaseResults[mainReleaseIndex].certification
        }
    }
    
    func addGenreDetails() {
        for index in movies.indices {
            guard let genreIds = movies[index].genreIds else {
                continue
            }

            var categoryList: [String] = []
            for genreId in genreIds {
                if let genreName = genreMap[genreId] {
                    categoryList.append(genreName)
                }
            }

            movies[index].categories = categoryList
        }
    }
    
    func addDirectorData(for id: Int, data: CrewModel) {
        guard let index = movies.firstIndex(where: { $0.id == id}) else {
            print("Could not match id with key")
            return
        }
        var director: String?
        // First find director
        if let crew = data.crew {
            for member in crew {
                if member.job?.lowercased() == "director" {
                    director = member.name?.lowercased()
                    movies[index].director = .init(id: member.id ?? -1, name: director ?? "Unknown", jobs: []) // We should never hit unknown cause we verify it exists
                }
            }
            // Second find all the roles the director was apart of
            if let director {
                var jobs: [String] = []
                for member in crew {
                    if member.name?.lowercased() == director, let job = member.job {
                        jobs.append(job)
                    }
                }
                movies[index].director?.jobs = jobs
            }
        }
    }
}

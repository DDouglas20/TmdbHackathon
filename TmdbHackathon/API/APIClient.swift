//
//  APIClient.swift
//  TmdbHackathon
//
//  Created by DeQuan Douglas on 10/13/25.
//

import Foundation

final class APIClient: NetworkRequesting {
    
    private let network: NetworkRequesting
    
    static let shared = APIClient()
    
    static let baseImageURL = "https://image.tmdb.org/t/p/w500"
    
    private struct Constants {
        static let baseURL = "https://api.themoviedb.org/3/"
        static let apiKey = ""
    }
    
    init(network: NetworkRequesting = NetworkClient()) {
        self.network = network
    }
    
    // MARK: API Functions
    
    /// Fetches the popular movies from the api
    /// - Parameter completion: Handling for when the task is complete
    func getPopularMovies(completion: @escaping (Bool) -> Void ) {
        guard let url = formURL(baseUrl: Constants.baseURL, endpoint: Endpoint.popular) else {
            // Invalid url
            print(ApiError.invalidURL)
            completion(false)
            return
        }
        
        request(url: url, expecting: MovieModel.self) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let response):
                guard let data = response.results else {
                    print(ApiError.dataNotFound)
                    completion(false)
                    return
                }
                let dispatchGroup = DispatchGroup()
                for movie in data {
                    DataManager.shared.movies.append(.init(movie: movie))
                    dispatchGroup.enter()
                    self.getAllMovieDetails(movieId: movie.id ?? -1) {
                        print("Finsihed")
                        dispatchGroup.leave()
                    }
                }
                dispatchGroup.notify(queue: .main) {
                    completion(true)
                }
            case .failure(let error):
                print(error)
                completion(false)
                return
            }
        }
    }
    
    /// Do all the api calls for the movies at once to reduce load times for users
    /// - Parameters:
    ///   - movieId: the movie's id
    ///   - completion: completion to know when the calls are complete
    private func getAllMovieDetails(movieId: Int, completion: @escaping () -> Void) {
        let dispatchGroup = DispatchGroup()
        dispatchGroup.enter()
        getMovieDetails(movieId: movieId) {
            dispatchGroup.leave()
        }
        dispatchGroup.enter()
        getMovieCertification(movieId: movieId) {
            dispatchGroup.leave()
        }
        dispatchGroup.enter()
        getVideoData(movieId: movieId) {
            dispatchGroup.leave()
        }
        dispatchGroup.enter()
        fetchGenres {
            dispatchGroup.leave()
        }
        dispatchGroup.enter()
        getCredits(movieId: movieId) {
            dispatchGroup.leave()
        }
        dispatchGroup.notify(queue: .main) {
            completion()
        }
    }
    
    /// Gets the details for an individual movie
    /// - Parameter movieId: The movie's id
    private func getMovieDetails(movieId: Int, completion: @escaping () -> Void) {
        guard let url = formURL(baseUrl: Constants.baseURL + "movie/\(movieId)", endpoint: nil) else {
            print(ApiError.invalidURL)
            return
        }
        
        request(url: url, expecting: MovieDetails.self) { result in
            switch result {
            case .success(let details):
                DataManager.shared.addMovieDetailsData(for: movieId, details: details)
                completion()
            case .failure(let failure):
                print(failure)
            }
        }
    }
    
    private func getMovieCertification(movieId: Int, completion: @escaping () -> Void) {
        guard let url = formURL(baseUrl: Constants.baseURL + "movie/\(movieId)/", endpoint: .cert) else {
            print(ApiError.invalidURL)
            return
        }
        request(url: url, expecting: ReleaseDatesModel.self) { result in
            switch result {
            case .success(let details):
                DataManager.shared.addCertDetails(for: movieId, details: details.results)
                completion()
            case .failure(let failure):
                print(failure)
            }
        }
    }
    
    /// Gets the youtubeId for watching the trailer
    /// - Parameter movieId: The movie's id
    private func getVideoData(movieId: Int, completion: @escaping () -> Void) {
        guard let url = formURL(baseUrl: Constants.baseURL + "movie/\(movieId)/", endpoint: .videos) else {
            print(ApiError.invalidURL)
            return
        }
        
        request(url: url, expecting: VideoModel.self) { result in
            switch result {
            case .success(let response):
                if let filteredArray = response.results?.filter({ $0.site?.lowercased() == "youtube" && $0.type?.lowercased() == "trailer"}),
                   let trailer = filteredArray.first {
                    DataManager.shared.addVideoData(for: movieId, key: trailer.key)
                }
                completion()
            case .failure(let failure):
                print(failure)
            }
        }
    }
    
    
    /// Fetches the genres so we can map them to the movies
    func fetchGenres(completion: @escaping () -> Void) {
        guard let url = formURL(baseUrl: Constants.baseURL + "genre/movie/", endpoint: .list) else {
            print(ApiError.invalidURL)
            return
        }
        
        request(url: url, expecting: ListModel.self) { result in
            switch result {
            case .success(_):
                DataManager.shared.addGenreDetails()
                completion()
            case .failure(let failure):
                print(failure)
            }
        }
    }
    
    /// Get movie credits so we can find the director
    /// - Parameter movieId: The movie's id
    private func getCredits(movieId: Int, completion: @escaping () -> Void) {
        guard let url = formURL(baseUrl: Constants.baseURL + "movie/\(movieId)/", endpoint: .credits) else {
            print(ApiError.invalidURL)
            return
        }
        
        request(url: url, expecting: CrewModel.self) { result in
            switch result {
            case .success(let response):
                if (response.crew?.first(where: { $0.job == "Director" })) != nil {
                    DataManager.shared.addDirectorData(for: movieId, data: response)
                }
                completion()
            case .failure(let failure):
                print(failure)
            }
        }
    }
    
    func request<T: Codable>(url: URL?, expecting: T.Type, completion: @escaping (Result<T, any Error>) -> Void) {
        network.request(url: url, expecting: expecting, completion: completion)
    }
    
    // MARK: Helper Functions
    
    /// Helps reduce redundant code when forming the request url
    /// - Parameters:
    ///   - endpoint: The endpoint we need to hit
    ///   - queryParams: Any query params we may need to add to the request
    /// - Returns: Returns the request url
    private func formURL(baseUrl: String, endpoint: Endpoint?, queryParams: [String: String] = [:]) -> URL? {
        var urlString = baseUrl
        if let endpoint {
            urlString += endpoint.rawValue
        }
        var queryItems = [URLQueryItem]()
        // Add params to request
        for (name, value) in queryParams {
            queryItems.append(.init(name: name, value: value))
        }
        
        // Add token
        queryItems.append(.init(name: "api_key", value: Constants.apiKey))
        
        urlString += "?" + queryItems.map { "\($0.name)=\($0.value ?? "")"}.joined(separator: "&")
        
        return URL(string: urlString)
    }
    
}

// MARK: Enums
extension APIClient {
    private enum Endpoint: String {
        case configuration = "configuration"
        case popular = "movie/popular"
        case videos = "videos"
        case list = "list"
        case credits = "credits"
        case cert = "release_dates"
    }
    
    enum ApiError: Error {
        case unknown
        case invalidURL
        case decodingFailed
        case dataNotFound
    }
}

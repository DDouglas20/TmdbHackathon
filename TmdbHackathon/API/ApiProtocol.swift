//
//  ApiProtocol.swift
//  TmdbHackathon
//
//  Created by DeQuan Douglas on 10/16/25.
//

import Foundation


/// Allows for mocking of the api client for testing
protocol NetworkRequesting {
    func request<T: Codable>(
        url: URL?,
        expecting: T.Type,
        completion: @escaping (Result<T, Error>) -> Void
    )
}

final class NetworkClient: NetworkRequesting {
    
    /// Completes the request to the backend
    /// - Parameters:
    ///   - url: The request url
    ///   - expecting: Whichever model we're expecting to decode
    ///   - completion: The result of a successful or failed api call
    func request<T: Codable>(url: URL?, expecting: T.Type, completion: @escaping (Result<T, any Error>) -> Void) {
        guard let url = url else {
            completion(.failure(APIClient.ApiError.invalidURL))
            return
        }
        
        print("Requesting url: \(url)")
        
        URLSession.shared.dataTask(with: url) { data, _, error in
            guard error == nil else {
                completion(.failure(APIClient.ApiError.unknown))
                return
            }
            guard let data else {
                completion(.failure(APIClient.ApiError.dataNotFound))
                return
            }
            
            do {
                let result = try JSONDecoder().decode(expecting, from: data)
                completion(.success(result))
            } catch {
                completion(.failure(error))
            }
            
        }.resume()
    }
}

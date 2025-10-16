//
//  TmdbHackathonTests.swift
//  TmdbHackathonTests
//
//  Created by DeQuan Douglas on 10/13/25.
//

import Testing
@testable import TmdbHackathon
import Foundation

struct TmdbHackathonTests {
    
    struct MockNetworkClient: NetworkRequesting {
        var responses: [String: Any] = [:]
        var shouldFail = false

        func request<T: Codable>(
            url: URL?,
            expecting type: T.Type,
            completion: @escaping (Result<T, Error>) -> Void
        ) {
            if shouldFail {
                completion(.failure(APIClient.ApiError.unknown))
                return
            }
            
            guard let response = responses[url?.absoluteString ?? ""] as? T else {
                completion(.failure(APIClient.ApiError.dataNotFound))
                return
            }
            
            completion(.success(response))
        }
    }
    
    @Suite("APITests")
    struct APITests {
        @Test func testMovieFetch() async throws {
            let fakeMovies = MovieModel(results: [
                .init(id: 1, overview: "Dream heist", title: "Inception"),
                .init(id: 2, overview: "Space odyssey", title: "Interstellar")
            ])
            
            var mock = MockNetworkClient()
            mock.responses["https://api.themoviedb.org/3/movie/popular?api_key=FAKE"] = fakeMovies
            
            let api = APIClient(network: mock)
            
            var didSucceed = false
            api.getPopularMovies { success in
                didSucceed = success
            }
            try await Task.sleep(for: .milliseconds(100))
            
            // Assert
            #expect(didSucceed)
            #expect(DataManager.shared.movies.count == 2)
        }

    }

    @Suite("ListTests")
    struct ListViewTests {
        @Test func testPosterPath() async throws {
            let viewModel = ListViewViewModel()
            #expect(viewModel.formPosterPath(path: "test") == (APIClient.baseImageURL + "test"))
        }
        
        @Test func testFilter() async throws {
            let viewModel = ListViewViewModel(moviesList: [.init(movie: .init(original_title: "Test"))])
            viewModel.filterMovies(filterText: "Test")
            #expect(viewModel.filteredMovies.count == 1)
            viewModel.filterMovies(filterText: "skip")
            #expect(viewModel.filteredMovies.count == 0)
        }
    }

}

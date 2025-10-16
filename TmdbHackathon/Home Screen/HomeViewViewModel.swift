//
//  HomeViewViewModel.swift
//  TmdbHackathon
//
//  Created by DeQuan Douglas on 10/13/25.
//

import Foundation

@Observable class HomeViewViewModel {
    var isLoading: Bool = true
    
    var movies = [MovieData]()
    
    func fetchMovies() {
        APIClient.shared.getPopularMovies { [weak self] _ in
            guard let self else { return }
            self.movies = DataManager.shared.movies
            print("Movies: \(self.movies)") // Debugging purposes
            self.isLoading = false
        }
    }
}

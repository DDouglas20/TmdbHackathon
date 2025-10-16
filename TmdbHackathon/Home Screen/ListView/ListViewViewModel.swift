//
//  ListViewViewModel.swift
//  TmdbHackathon
//
//  Created by DeQuan Douglas on 10/13/25.
//

import UIKit

@Observable final class ListViewViewModel {
    
    private var moviesList: [MovieData]
    
    var filteredMovies: [MovieData]
    
    var searchText: String = ""
    
    init(moviesList: [MovieData] = [MovieData]()) {
        self.moviesList = moviesList
        self.filteredMovies = moviesList
    }
    
    func formPosterPath(path: String) -> String {
        return APIClient.baseImageURL + path
    }
    
    func filterMovies(filterText: String) {
        if filterText.isEmpty {
            filteredMovies = moviesList
            return
        }
        filteredMovies = moviesList.filter({ $0.movieName?.lowercased().contains(filterText.lowercased()) == true })
    }
    
}

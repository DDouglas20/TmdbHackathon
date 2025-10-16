//
//  ContentView.swift
//  TmdbHackathon
//
//  Created by DeQuan Douglas on 10/13/25.
//

import SwiftUI

struct HomeView: View {
    @State private var viewModel = HomeViewViewModel()
    var body: some View {
        if viewModel.isLoading {
            ProgressView()
                .onAppear {
                    viewModel.fetchMovies() // Fetch movies on initial load
                }
        } else {
            if viewModel.movies.count > 0 {
                ListView(viewModel: .init(moviesList: viewModel.movies))
            } else {
                Text("No Movies Found")
                    .font(.system(size: 21, weight: .semibold))
            }
        }
    }
}

#Preview {
    HomeView()
}

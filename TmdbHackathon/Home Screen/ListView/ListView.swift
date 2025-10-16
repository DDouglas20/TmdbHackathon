//
//  ListView.swift
//  TmdbHackathon
//
//  Created by DeQuan Douglas on 10/13/25.
//

import SwiftUI

struct ListView: View {
    @State var viewModel: ListViewViewModel
    var body: some View {
        NavigationStack {
            VStack {
                List {
                    if viewModel.filteredMovies.isEmpty {
                        Text("No Results")
                            .font(.system(size: 17, weight: .semibold))
                    } else {
                        ForEach(viewModel.filteredMovies, id: \.self) { movie in
                            NavigationLink(value: movie) {
                                ListDetialsView(
                                    posterPath: viewModel.formPosterPath(path: movie.portaitPath ?? ""),
                                    title: movie.movieName ?? "",
                                    releaseDate: movie.releaseDate ?? "",
                                    rating: (movie.movieRating ?? 0) / 2
                                )
                            }
                        }
                    }
                }
            }
            .navigationTitle("Movie Search")
            .onChange(of: viewModel.searchText) { oldValue, newValue in
                viewModel.filterMovies(filterText: newValue)
            }
            .navigationDestination(for: MovieData.self) { movie in
                MovieDetailsView(viewModel: .init(movieObject: movie))
            }
        }
        .searchable(text: $viewModel.searchText)
    }
}

private struct ListDetialsView: View {
    let posterPath: String
    let title: String
    let releaseDate: String
    let rating: Double
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            AsyncImage(url: URL(string: posterPath)) { phase in
                switch phase {
                case .empty:
                    ProgressView()
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                        .shadow(color: .black, radius: 2.0, x: 2, y: 2)
                case .failure(_):
                    Image(systemName: "photo")
                        .resizable()
                        .onAppear {
                            print("This is path: \(posterPath)")
                        }
                }
            }
            .frame(width: 50, height: 100)
            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .lineLimit(2)
                    .font(.system(size: 17, weight: .semibold))
                Text(releaseDate)
                    .font(.system(size: 13))
                    .foregroundStyle(.gray)
                StarRatingView(rating: rating)
            }
        }
    }
}


#Preview {
    ListView(viewModel: .init())
}

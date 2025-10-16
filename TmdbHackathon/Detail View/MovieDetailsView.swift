//
//  MovieDetailsView.swift
//  TmdbHackathon
//
//  Created by DeQuan Douglas on 10/15/25.
//


import SwiftUI

struct MovieDetailsView: View {
    @StateObject var viewModel: MovieDetailsViewModel
    
    var body: some View {
        ScrollView { // Account for smaller screens
            VStack(alignment: .leading, spacing: 16) {
                // First view is the image view or the youtube view
                getCorrectMediaView()
                    .frame(height: 300)
                // Show overview
                CategoryView(
                    titleString: "Description: ",
                    subString: viewModel.movieDescription
                )
                Divider()
                // Show rating
                CategoryView(
                    titleString: "Rating: ",
                    subString: viewModel.movieCert,
                    needsHStack: true
                )
                Divider()
                // Show viewer ratings
                HStack(spacing: 4) {
                    Text("Viewer Rating: ")
                        .font(.system(size: 17, weight: .semibold))
                    StarRatingView(rating: viewModel.rating)
                }
                Divider()
                // Show Date created
                CategoryView(
                    titleString: "Release Date: ",
                    subString: viewModel.releaseDate,
                    needsHStack: true
                )
                Divider()
                // Show genres
                CategoryView(
                    titleString: "Genres: ",
                    subString: viewModel.movieCategories
                )
                Divider()
                // Show Duration
                CategoryView(
                    titleString: "Duration: ",
                    subString: viewModel.duration,
                    needsHStack: true
                )
                Divider()
                // Show director + jobs
                VStack(alignment: .leading, spacing: 16) {
                    CategoryView(
                        titleString: "Director: ",
                        subString: viewModel.director.capitalized,
                        needsHStack: true,
                        needsUnderline: true,
                        tapGesture: {
                            viewModel.validateDirectorUrl()
                        }
                    )
                    Text(viewModel.directorJobs)
                        .font(.system(size: 13))
                }
                Divider()
                if viewModel.productionData.count > 0 {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Production Companies: ")
                            .font(.system(size: 15))
                            .fontWeight(.semibold)
                        ScrollView(.horizontal) {
                            HStack {
                                let prodData = viewModel.productionData
                                ForEach(0..<prodData.count, id: \.self) { index in
                                    VStack(spacing: 4) {
                                        Text("\(prodData[index].name):")
                                            .font(.system(size: 15))
                                        AsyncImage(url: prodData[index].logoUrl) { phase in
                                            switch phase {
                                            case .empty:
                                                ProgressView()
                                            case .success(let image):
                                                image
                                                    .resizable()
                                                    .scaledToFit()
                                            case .failure(let error):
                                                Image(systemName: "photo")
                                                    .resizable()
                                            }
                                        }
                                        .frame(width: 100, height: 100)
                                    }
                                    if index != prodData.count - 1 {
                                        Divider()
                                    }
                                }
                            }
                        }
                        .scrollDisabled(viewModel.productionData.count < 3)
                    }
                }
                Spacer() // Align everything to the top
            }
            .padding()
            .navigationTitle(viewModel.movieTitle)
            .navigationBarTitleDisplayMode(.automatic)
        }
        .fullScreenCover(isPresented: $viewModel.showDirPage) {
            if let url = viewModel.directorUrl {
                SFSafariView(url: url)
                    .ignoresSafeArea()
            }
        }
        .alert("Error", isPresented: $viewModel.showAlert, actions: {}, message: {
            Text("Could not open web page. Please try again later.")
        })
    }
    
    @ViewBuilder
    private func getCorrectMediaView() -> some View {
        Group {
            if let ytId = viewModel.youtubeId {
                YoutubeView(videoId: ytId)
                    .clipShape(RoundedRectangle(cornerRadius: 4.0))
            } else if let landscapeUrl = viewModel.landscapePath {
                AsyncImage(url: landscapeUrl) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFit()
                            .clipShape(RoundedRectangle(cornerRadius: 4.0))
                    case .failure(let error):
                        Image(systemName: "photo")
                            .resizable()
                    }
                }
            }
        }
        .shadow(color: Color.black.opacity(0.3), radius: 6.0, x: 0, y: 0)
    }
}

private struct CategoryView: View {
    let titleString: String
    let subString: String
    var needsHStack: Bool = false
    var needsUnderline: Bool = false
    var tapGesture: (() -> Void)? = nil
    var body: some View {
        if needsHStack {
            HStack(spacing: 2) {
                Text(titleString)
                    .font(.system(size: 17, weight: .semibold))
                Text(subString)
                    .font(.system(size: 15))
                    .underline(needsUnderline)
                    .onTapGesture {
                        if let tapGesture {
                            tapGesture()
                        }
                    }
            }
        } else {
            VStack(alignment: .leading, spacing: 8) {
                Text(titleString)
                    .font(.system(size: 17, weight: .semibold))
                Text(subString)
                    .font(.system(size: 15))
                    .underline(needsUnderline)
                    .onTapGesture {
                        if let tapGesture {
                            tapGesture()
                        }
                    }
            }
        }
    }
}

#Preview {
    MovieDetailsView(viewModel: .init(movieObject: MovieData(movie: .init())))
}

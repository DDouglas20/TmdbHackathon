//
//  StarRatingView.swift
//  TmdbHackathon
//
//  Created by DeQuan Douglas on 10/15/25.
//

import SwiftUI

/// Generic view to display a star rating of the user's ratings
struct StarRatingView: View {
    let rating: Double
    var body: some View {
        HStack(spacing: 2) {
            ForEach(0..<5) { index in
                let filled = rating >= Double(index + 1)
                let half = rating > Double(index) && rating < Double(index + 1)
                
                Image(systemName: filled ? "star.fill" : (half ? "star.lefthalf.fill" : "star"))
                    .foregroundColor(.yellow)
            }
        }
    }
}

#Preview {
    StarRatingView(rating: 3.6)
}

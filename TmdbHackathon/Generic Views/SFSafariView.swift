//
//  SFSafariView.swift
//  TmdbHackathon
//
//  Created by DeQuan Douglas on 10/15/25.
//


import SwiftUI
import SafariServices

/// Creates a safari view that can be used in SwiftUI
struct SFSafariView: UIViewControllerRepresentable {
    let url: URL
    
    func makeUIViewController(context: Context) -> UIViewController {
        return SFSafariViewController(url: url)
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        // Nothing to update
    }
}

//
//  ContentView.swift
//  CachedAsyncImage
//
//  Created by Mahi Al Jawad on 8/9/24.
//

import SwiftUI

struct ContentView: View {
    let photoURLString = "https://images.unsplash.com/5/unsplash-kitsune-4.jpg?ixlib=rb-0.3.5&q=85&fm=jpg&crop=entropy&cs=srgb&ixid=eyJhcHBfaWQiOjEyMDd9&s=ce40ce8b8ba365e5e6d06401e5485390"
    
    var photoURL: URL? {
        URL(string: photoURLString)
    }
    
    var body: some View {
        AsyncCachedImage(url: photoURL) { image in
            image
                .resizable()
                .aspectRatio(contentMode: .fill)
        } placeholder: {
            ProgressView()
        }
    }
}

#Preview {
    ContentView()
}

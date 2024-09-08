# CachedAsyncImage-SwiftUI

SwiftUI provides a clean `AsyncImage` facility to download an asynchronous image and show a placeholder (e.g. ProgressView/Spinner) during image download. However the SwiftUI library does not cache the image, which results in redownloading the image each time. This repo provides a cleaner solution written over the `AsyncImage` library to support the caching facility. 

I have originally answered this solution in a StackOverflow question for image caching: https://stackoverflow.com/a/77956449/18823687 and StackOverflow community found the answer useful. So I have created a repo to share this library in the iOS developer community.

## CachedAsyncImage Library

Just **copy-paste** the following library code in a Swift file

```swift
import SwiftUI

@MainActor
struct AsyncCachedImage<ImageView: View, PlaceholderView: View>: View {
    // Input dependencies
    var url: URL?
    @ViewBuilder var content: (Image) -> ImageView
    @ViewBuilder var placeholder: () -> PlaceholderView
    
    // Downloaded image
    @State var image: UIImage? = nil
    
    init(
        url: URL?,
        @ViewBuilder content: @escaping (Image) -> ImageView,
        @ViewBuilder placeholder: @escaping () -> PlaceholderView
    ) {
        self.url = url
        self.content = content
        self.placeholder = placeholder
    }
    
    var body: some View {
        VStack {
            if let uiImage = image {
                content(Image(uiImage: uiImage))
            } else {
                placeholder()
                    .onAppear {
                        Task {
                            image = await downloadPhoto()
                        }
                    }
            }
        }
    }
    
    // Downloads if the image is not cached already
    // Otherwise returns from the cache
    private func downloadPhoto() async -> UIImage? {
        do {
            guard let url else { return nil }
            
            // Check if the image is cached already
            if let cachedResponse = URLCache.shared.cachedResponse(for: .init(url: url)) {
                return UIImage(data: cachedResponse.data)
            } else {
                let (data, response) = try await URLSession.shared.data(from: url)
                
                // Save returned image data into the cache
                URLCache.shared.storeCachedResponse(.init(response: response, data: data), for: .init(url: url))
                
                guard let image = UIImage(data: data) else {
                    return nil
                }
                
                return image
            }
        } catch {
            print("Error downloading: \(error)")
            return nil
        }
    }
}
```


## Usage

Same as original SwiftUI library `AsyncImage` 

```swift
        AsyncCachedImage(url: photoURL) { image in
            image
                .resizable()
                .aspectRatio(contentMode: .fill)
        } placeholder: {
            ProgressView() // Shows loading indicator until the image is downloaded
        }
```


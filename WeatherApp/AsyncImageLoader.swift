import SwiftUI

struct AsyncImageLoader: View {
    let urlString: String
    @State private var imageData: Data?

    var body: some View {
        if let imageData = imageData, let uiImage = UIImage(data: imageData) {
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFit() // This will ensure the image is sized nicely

        } else {
            Image(systemName: "photo")
                .resizable()
                .scaledToFit()
                .hidden()
                .onAppear {
                    fetchImage()
                }
        }
    }

    func fetchImage() {
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else { return }
            DispatchQueue.main.async {
                self.imageData = data
            }
        }.resume()
    }
}

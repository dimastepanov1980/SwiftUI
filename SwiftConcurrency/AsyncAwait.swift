//
//  AsyncAwait.swift
//  SwiftConcurrency
//
//  Created by Dima Stepanov on 3/16/23.
//

import SwiftUI


class AsyncAwaitManager {
    let url = URL(string: "https://picsum.photos/200")
    
    func handleResponce(data: Data?, response: URLResponse?) -> UIImage? {
        guard
            let data = data,
            let image = UIImage(data: data),
            let responce = response as? HTTPURLResponse,
            responce.statusCode >= 200 && responce.statusCode < 300 else {
            return nil
        }
        return image
    }
    
    func downloadWithEscaping(completionHandler: @escaping(_ image: UIImage?, _ error: Error?) -> ()) {
        if let url = url {
            URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
                let image = self?.handleResponce(data: data, response: response)
                completionHandler(image, error)
            }
            .resume()
        }
    }
}


class AsyncAwaitViewModel: ObservableObject {
    @Published var image: UIImage? = nil
    let loader = AsyncAwaitManager()
    
    func fetchData() {
        loader.downloadWithEscaping { [weak self] image, error in
            DispatchQueue.main.async {
                    self?.image = image
            }
        }
    }
}

struct AsyncAwait: View {
    @StateObject private var viewModel = AsyncAwaitViewModel()
    
    var body: some View {
        ZStack {
            if let image = viewModel.image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 300, height: 300)
            }
            
        }.onAppear{
            viewModel.fetchData()
        }
    }
}

struct AsyncAwait_Previews: PreviewProvider {
    static var previews: some View {
        AsyncAwait()
    }
}

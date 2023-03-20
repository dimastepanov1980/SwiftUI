//
//  AsyncAwait.swift
//  SwiftConcurrency
//
//  Created by Dima Stepanov on 3/16/23.
//

import SwiftUI
import Combine


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
  
    func downloadWithCombine() -> AnyPublisher<UIImage?, Error> {
        guard let url = url else { return Fail(error: URLError(.badURL)).eraseToAnyPublisher() }

        return URLSession.shared.dataTaskPublisher(for: url)
            .tryMap { data, response -> UIImage? in
                guard let image = UIImage(data: data) else {
                    throw URLError(.cannotDecodeContentData)
                }
                return image
            }
            .mapError { error -> Error in
                return error
            }
            .eraseToAnyPublisher()
    }
    
    func downloadWithAsync() async throws -> UIImage? {
        do {
            guard let url = url else { return nil }
            let (data, responce) = try await URLSession.shared.data(from: url)
            return handleResponce(data: data, response: responce)
        } catch  {
            throw error
        }
    }
}


class AsyncAwaitViewModel: ObservableObject {
    @Published var image: UIImage? = nil
    let loader = AsyncAwaitManager()
    var cancellables = Set<AnyCancellable>()
    // downloadWithEscaping
    //    func fetchData() {
    //        loader.downloadWithEscaping { [weak self] image, error in
    //            DispatchQueue.main.async {
    //                    self?.image = image
    //            }
    //        }
    //    }
   
    // downloadWithCombine
//    func fetchData() {
//        loader.downloadWithCombine()
//            .receive(on: DispatchQueue.main)
//            .sink { _ in
//
//            } receiveValue: { [weak self] image in
//                self?.image = image
//            }
//            .store(in: &cancellables)
//    }
    
    func fetchData() async {
        let image = try? await loader.downloadWithAsync()
        await MainActor.run {
            self.image = image
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
            
        }.onAppear {
            Task {
                await viewModel.fetchData()
            }
        }
    }
}

struct AsyncAwait_Previews: PreviewProvider {
    static var previews: some View {
        AsyncAwait()
    }
}

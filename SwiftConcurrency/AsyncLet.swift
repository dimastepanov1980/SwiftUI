//
//  AsyncLet.swift
//  SwiftConcurrency
//
//  Created by Dima Stepanov on 3/23/23.
//

import SwiftUI

class AsyncLetViewModel: ObservableObject {
    @Published var images: [UIImage?] = []
    let columns = [GridItem(.flexible()), GridItem(.flexible())]
    
    func fetchData() async throws -> UIImage? {
        guard let url = URL(string: "https://picsum.photos/200") else { return nil }

        do {
            let (data, _) = try await URLSession.shared.data(from: url, delegate: nil)
            if let image = UIImage(data: data) {
                return image
            } else {
                throw URLError(.badURL)
            }
        } catch {
            throw error
        }
    }
}

struct AsyncLet: View {
    @StateObject var viewModel = AsyncLetViewModel()
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: viewModel.columns) {
                    ForEach(viewModel.images, id: \.self) { image in
                        if let image = image {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFit()
                                .frame(height: 200)
                        }
                    }
                }
            }
            .navigationTitle("Async title")
            .onAppear{
                Task {
                    
                    do {
                        // Все запросы обрабатывется одновременно, если в одном из запросов будет задержка, другие будут весеть в очереди пока не обработается предидущий
                        async let fetchImage = try await viewModel.fetchData()
                        async let fetchImage1 = try await viewModel.fetchData()
                        async let fetchImage2 = try await viewModel.fetchData()
                        async let fetchImage3 = try await viewModel.fetchData()
                        let (image, image1, image2, image3) = await (try fetchImage, try fetchImage1, try fetchImage2, try fetchImage3)
                        
                        self.viewModel.images.append(contentsOf: [image, image1, image2, image3])

                        
                        // Каждый запрос обрабатывется последовательно, если в одном из запросов будет задержка, другие будут весеть в очереди пока не обработается предидущий
                        if let image = try await viewModel.fetchData() {
                            self.viewModel.images.append(image)
                        }
                        
                        if let image = try await viewModel.fetchData() {
                            self.viewModel.images.append(image)
                        }

                        if let image = try await viewModel.fetchData() {
                            self.viewModel.images.append(image)
                        }

                        if let image = try await viewModel.fetchData() {
                            self.viewModel.images.append(image)
                        }
                        
                        if let image = try await viewModel.fetchData() {
                            self.viewModel.images.append(image)
                        }

                    } catch {
                        
                    }
                }
            }
        }
    }
}

struct AsyncLet_Previews: PreviewProvider {
    static var previews: some View {
        AsyncLet()
    }
}

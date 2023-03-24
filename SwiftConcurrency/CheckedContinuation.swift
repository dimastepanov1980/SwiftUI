//
//  CheckedContinuation.swift
//  SwiftConcurrency
//
//  Created by Dima Stepanov on 3/24/23.
//

import SwiftUI

class CheckedContinuationNetworkManager {
    
    func getData(url: URL) async throws -> Data {
        do {
            let(data, _) = try await URLSession.shared.data(from: url)
            return data
        } catch {
            throw error
        }
    }
}

class CheckedContinuationViewModel: ObservableObject {
    @Published var image: UIImage? = nil
    let networkManager = CheckedContinuationNetworkManager()

    func getImage() async throws {
        guard let url = URL(string: "https://picsum.photos/200") else { return }
        
        do {
            let data = try await networkManager.getData(url: url)
            if let image = UIImage(data: data) {
                await MainActor.run(body: {
                    self.image = image
                })
            }
            } catch {
            throw error
        }
    }
}

struct CheckedContinuation: View {
    @StateObject private var viewModel = CheckedContinuationViewModel()
    
    var body: some View {
        ZStack {
            if let image = viewModel.image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
            }
        }
        .task {
            try? await viewModel.getImage()
        }
    }
}

struct CheckedContinuation_Previews: PreviewProvider {
    static var previews: some View {
        CheckedContinuation()
    }
}

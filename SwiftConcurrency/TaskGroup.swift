//
//  TaskGroup.swift
//  SwiftConcurrency
//
//  Created by Dima Stepanov on 3/24/23.
//

import SwiftUI

class TaskGroupDataManager {
    // добавляем вручную задачи в очередь, не очень продуктивно
    func fetchDataAsyncLet() async throws -> [UIImage] {
        async let image1 = try fetchData(urlString: "https://picsum.photos/200")
        async let image2 = try fetchData(urlString: "https://picsum.photos/200")
        async let image3 = try fetchData(urlString: "https://picsum.photos/200")
        async let image4 = try fetchData(urlString: "https://picsum.photos/200")
        let (imageOne, imageTwo, imageThree, imageFour) = await (try image1, try image2, try image3, try image4)
        return [imageOne, imageTwo, imageThree, imageFour]
        
    }
    
    func fetchDataTaskGroup() async throws -> [UIImage] {
        try await withThrowingTaskGroup(of: UIImage.self) { group in
            var images: [UIImage] = []
            
            group.addTask{
                try await self.fetchData(urlString: "https://picsum.photos/200")
            }
            
            group.addTask{
                try await self.fetchData(urlString: "https://picsum.photos/200")
            }
            
            group.addTask{
                try await self.fetchData(urlString: "https://picsum.photos/200")
            }
            
            group.addTask{
                try await self.fetchData(urlString: "https://picsum.photos/200")
            }
            
            group.addTask{
                try await self.fetchData(urlString: "https://picsum.photos/200")
            }
            
            group.addTask{
                try await self.fetchData(urlString: "https://picsum.photos/200")
            }
            
            for try await image in group {
                images.append(image)
            }
            return images
        }
    }
    
    // добавляем таски через for each
    
    func fetchDataTaskGroupWithArray() async throws -> [UIImage] {
        let urlString = ["https://picsum.photos/200", "https://picsum.photos/200", "https://picsum.photos/200", "https://picsum.photos/200", "https://picsum.photos/200" , "https://picsum.photos/200", "some erroro"]
        
        return try await withThrowingTaskGroup(of: UIImage?.self) { group in
            var images: [UIImage] = []
            // резервируем место для повышения результативности
            images.reserveCapacity(urlString.count)
            
            for url in urlString {
                group.addTask{
                    try? await self.fetchData(urlString: url)
                }
            }
            
            for try await image in group {
                if let image = image {
                    images.append(image)
                }
            }
            
            return images
        }
    }
    
    private func fetchData(urlString: String) async throws -> UIImage {
        guard let url = URL(string: urlString) else { throw URLError(.badURL) }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
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

class TaskGroupViewModel: ObservableObject {
    @Published var images: [UIImage?] = []
    let manager = TaskGroupDataManager()
    
    func getData() async {
        if let images = try? await manager.fetchDataTaskGroupWithArray() {
            self .images.append(contentsOf: images)
        }
    }
}

struct TaskGroup: View {
    @StateObject private var viewModel = TaskGroupViewModel()
    let columns = [GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: columns) {
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
            .navigationTitle("Task Group")
            .task {
                await viewModel.getData()
            }
        }
    }
}

struct TaskGroup_Previews: PreviewProvider {
    static var previews: some View {
        TaskGroup()
    }
}

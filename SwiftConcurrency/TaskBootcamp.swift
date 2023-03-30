//
//  TaskBootcamp.swift
//  SwiftConcurrency
//
//  Created by Dima Stepanov on 3/21/23.
//

import SwiftUI

class TaskBootcampViewModel: ObservableObject {
    @Published var image: UIImage? = nil
    @Published var image2: UIImage? = nil
    
    func fetchData() async {
        do {
          //  try? await Task.sleep(nanoseconds: 5_000_000_000)
            guard let url = URL(string: "https://picsum.photos/200") else { return }
            let (data, _) = try await URLSession.shared.data(from: url)
            await MainActor.run(body: {
                self.image = UIImage(data: data)
                print("image returned successfully")
            })
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func fetchData2() async {
        do {
            try? await Task.sleep(nanoseconds: 3_000_000_000)
            guard let url = URL(string: "https://picsum.photos/200") else { return }
            let (data, _) = try await URLSession.shared.data(from: url)
            await MainActor.run(body: {
                self.image2 = UIImage(data: data)
                print("image returned successfully or cancel")

            })
        } catch {
            print(error.localizedDescription)
        }
    }
}

struct TaskBootcampHomeView: View {
    var body: some View {
        NavigationView {
            ZStack {
                NavigationLink("ClickMe") {
                    TaskBootcamp()
                }
            }
        }
    }
}

struct TaskBootcamp: View {
    @StateObject private var viewModel = TaskBootcampViewModel()
    
    var body: some View {
        VStack(spacing: 40) {
            if let image = viewModel.image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
            }
            
            if let image = viewModel.image2 {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
            }
        }
        // для остановки задачи если мы ушил с экрана можно испольовать оператор .task 
        .task {
            await viewModel.fetchData()
        }
        
//        .onAppear {
////            Task {
////                await viewModel.fetchData2()
////            }
//
//// Приоритет по убыванию
////            Task(priority: .high) {
////                print("high \(Thread.current) \(Task.currentPriority)")
////            }
////            Task(priority: .userInitiated) {
////                print("userInitiated \(Thread.current) \(Task.currentPriority)")
////            }
////            Task(priority: .medium) {
////                print("medium \(Thread.current) \(Task.currentPriority)")
////            }
////            Task(priority: .low) {
////                print("low \(Thread.current) \(Task.currentPriority)")
////            }
////            Task(priority: .utility) {
////                print("utility \(Thread.current) \(Task.currentPriority)")
////            }
////            Task(priority: .background) {
////                print("background \(Thread.current) \(Task.currentPriority)")
////            }
//        }
    }
}

struct TaskBootcamp_Previews: PreviewProvider {
    static var previews: some View {
        TaskBootcampHomeView()
    }
}

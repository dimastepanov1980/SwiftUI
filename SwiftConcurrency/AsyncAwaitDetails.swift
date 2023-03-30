//
//  AsyncAwaitDetails.swift
//  SwiftConcurrency
//
//  Created by Dima Stepanov on 3/20/23.
//

import SwiftUI

class AsyncAwaitDetailsViewModel: ObservableObject {
    @Published var dataArray: [String] = []

    func addDataArrayOne() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.dataArray.append("Some Data One \(Thread.current)")
        }
    }
    
    func addDataArrayTwo() {
        DispatchQueue.global().asyncAfter(deadline: .now() + 2) {
            let title = "Some Data Two \(Thread.current)"
            DispatchQueue.main.async {
                self.dataArray.append(title)
            }
        }
    }
    
    func addDataArrayAsync() async {
        let dataAsync = "Добавляем без задержки \(Thread.current)"
        let dataAsync2 = "Эмитируем задержку сервера 5 сек \(Thread.current)"
        self.dataArray.append(dataAsync)
        try? await Task.sleep(nanoseconds: 5_000_000_000)
        
        await MainActor.run(body: {
            self.dataArray.append(dataAsync2)
            
            let dataAsync3 = "Some Data Async3: \(Thread.current)"
            self.dataArray.append (dataAsync3)
        })
        
        await addOneMoreTask()
    }
    
    func addOneMoreTask() async {
        try? await Task.sleep(nanoseconds: 5_000_000_000)
        let oneMoreTask = "One More Task: \(Thread.current)"
        
        await MainActor.run(body: {
            self.dataArray.append(oneMoreTask)
            
            let twoMoreTask = "Two More Task: \(Thread.current)"
            self.dataArray.append (twoMoreTask)
        })
    }
}

struct AsyncAwaitDetails: View {
    
    @StateObject private var viewModel = AsyncAwaitDetailsViewModel()
    
    var body: some View {
        List {
            ForEach(viewModel.dataArray, id: \.self) { data in
                Text(data)
            }
        }.onAppear{
//            viewModel.addDataArrayOne()
//            viewModel.addDataArrayTwo()
            Task {
// await - ожидаем ответа, пока ответ не придет мы не перейждем к выполнению кода дальше.
// работа происходит в паралельных потоках (это не обязательно, хкод сам принимает решение) для возврата в основнй поток используем  await MainActor.run(body: { тут пишем что хотим выполнить в осноном потоке как правило обновляем UI}
                await viewModel.addDataArrayAsync()
                let finalText = "Final Text \(Thread.current)"
                viewModel.dataArray.append(finalText)
            }
        }
    }
}

struct AsyncAwaitDetails_Previews: PreviewProvider {
    static var previews: some View {
        AsyncAwaitDetails()
    }
}

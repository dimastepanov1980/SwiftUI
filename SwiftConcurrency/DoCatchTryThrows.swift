//
//  DoCatchTryThrows.swift
//  SwiftConcurrency
//
//  Created by Dima Stepanov on 3/15/23.
//

import SwiftUI

class DoCatchTryThrowsDataManager {
    let isActive = false
    
    func getTitleTuple() -> (lable: String?, color: Color, error: Error?) {
        if isActive {
            return ("Get New Lable", .green, nil)
        } else {
            return (nil, .orange, URLError(.badURL))
        }
    }
    
    func getTitleUseResult() -> Result<String, Error> {
        if isActive {
            return .success("Result Title")
        } else {
            return .failure(URLError(.appTransportSecurityRequiresSecureConnection))
        }
    }
    

}

class DoCatchTryThrowsViewModel: ObservableObject {
    @Published var lable = "First lable"
    @Published var colorLable: Color = .gray
    let manager = DoCatchTryThrowsDataManager()
    // getTitleTuple
    /*
    func fetchDate() {
        let newValue = manager.getTitleTuple()
        if let newLable = newValue.lable {
            self.lable = newLable
            self.colorLable = newValue.color
        } else if let error = newValue.error {
            self.lable = error.localizedDescription
        }
    }
     */
    
    // getTitleUseResult
    func fetchData() {
        let result = manager.getTitleUseResult()
        
        switch result {
        case .success(let newLable):
            self.lable = newLable
        case .failure(let error):
            self.lable = error.localizedDescription
        }
    }

}


struct DoCatchTryThrows: View {
    @StateObject private var viewModel = DoCatchTryThrowsViewModel()

    var body: some View {
        Text(viewModel.lable)
            .frame(width: 300, height: 300)
            .background(viewModel.colorLable)
            .onTapGesture {
                viewModel.fetchData()
            }
    }
}

struct DoCatchTryThrows_Previews: PreviewProvider {
    static var previews: some View {
        DoCatchTryThrows()
    }
}

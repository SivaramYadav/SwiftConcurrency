//
//  DoCatchTryThrowsBC.swift
//  SwiftConcurrency
//
//  Created by Sivaram Yadav on 24/08/24.
//


/*
 
 do-catch
 try
 throws
 
 */
import SwiftUI

class DoCatchTryThrowsDataManager {
    let isActive: Bool = false
    
    func getTitle() -> String? {
        if isActive {
            return "NEW TITLE."
        } else {
            return nil
        }
    }
    
    func getTitle2() -> (title: String?, error: Error?) {
        if isActive {
            return ("NEW TITLE.", nil)
        } else {
            return (nil, URLError(.badURL))
        }
    }
    
    func getTitle3() -> Result<String, Error> {
        if isActive {
            return .success("NEW TITLE.")
        } else {
            return .failure(URLError(.appTransportSecurityRequiresSecureConnection))
        }
    }
    
    func getTitle4() throws -> String {
        if isActive {
            return ""
        } else {
            throw URLError(.badServerResponse)
        }
    }
}

class DoCatchTryThrowsViewModel: ObservableObject {
    
    @Published var title: String = "Starting text."
    let dataManager = DoCatchTryThrowsDataManager()
    
    func fetchTitle() {
        let newTitle = dataManager.getTitle()
        if let newTitle = newTitle {
            self.title = newTitle
        }
    }
    
    func fetchTitle2() {
        let returnedValue = dataManager.getTitle2()
        if let newTitle = returnedValue.title {
            self.title = newTitle
        } else if let error = returnedValue.error {
            self.title = error.localizedDescription
        }
    }
    
    func fetchTitle3() {
        let result = dataManager.getTitle3()
        switch result {
        case .success(let newTitle):
            self.title = newTitle
        case .failure(let errror):
            self.title = errror.localizedDescription
        }
    }
    
    func fetchTitle4() {
        do {
            let newTitle = try dataManager.getTitle4()
            self.title = newTitle
        } catch let error {
            self.title = error.localizedDescription
        }
    }
}

struct DoCatchTryThrowBC: View {
    
    @StateObject private var viewModel = DoCatchTryThrowsViewModel()
    
    var body: some View {
        Text(viewModel.title)
            .frame(width: 300, height: 300)
            .background(Color.blue)
            .onTapGesture {
                //viewModel.fetchTitle()
                //viewModel.fetchTitle2()
                //viewModel.fetchTitle3()
                viewModel.fetchTitle4()
            }
    }
}

#Preview {
    DoCatchTryThrowBC()
}

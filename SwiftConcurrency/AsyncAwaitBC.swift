//
//  AsyncAwaitBC.swift
//  SwiftConcurrency
//
//  Created by Sivaram Yadav on 26/08/24.
//

import SwiftUI

class AsyncAwaitViewModel: ObservableObject {
    
    @Published var dataArray: [String] = []
    
    func addTitle1() {
        //self.dataArray.append("Title1: \(Thread.current)")
        
        // add 2 seconds delay on Main Thread
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.dataArray.append("Title1: \(Thread.current)")
        }
    }
    
    func addTitle2() {
        // add 2 seconds delay on Background Thread
        DispatchQueue.global().asyncAfter(deadline: .now() + 2) {
            let title = "Title2: \(Thread.current)"
            DispatchQueue.main.async {
                self.dataArray.append(title)
                
                let title3 = "Title2: \(Thread.current)"
                self.dataArray.append(title3)
            }
        }
    }
    
    func addAuthor1() async {
        let author1 = "Author1 : \(Thread.current)"
        
        try? await Task.sleep(nanoseconds: 2_000_000_000)
        
        let author2 = "Author2 : \(Thread.current)"
        
        await MainActor.run {
            self.dataArray.append(author1)
            self.dataArray.append(author2)

            let author3 = "Author3 : \(Thread.current)"
            self.dataArray.append(author3)
        }
    }
    
    func addSomething() async {
        try? await Task.sleep(nanoseconds: 2_000_000_000)
        
        let something1 = "Something1 : \(Thread.current)"
        await MainActor.run {
            self.dataArray.append(something1)

            let something2 = "Something2 : \(Thread.current)"
            self.dataArray.append(something2)
        }

    }
}

struct AsyncAwaitBC: View {
    
    @StateObject private var viewModel = AsyncAwaitViewModel()
    
    var body: some View {
        List(viewModel.dataArray, id: \.self) { data in
            Text(data)
        }
        .onAppear {
            //viewModel.addTitle1()
            //viewModel.addTitle2()
            
            Task {
                await viewModel.addAuthor1()
                await viewModel.addSomething()
                
                let finalText = "FINAL TEXT: \(Thread.current)"
                viewModel.dataArray.append(finalText)
            }
        }
    }
}

#Preview {
    AsyncAwaitBC()
}

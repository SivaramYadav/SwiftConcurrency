//
//  TasksBC.swift
//  SwiftConcurrency
//
//  Created by Sivaram Yadav on 27/08/24.
//

import SwiftUI

class TasksViewModel: ObservableObject {
    
    @Published var image: UIImage? = nil
    @Published var image2: UIImage? = nil

    func fetchImage() async {
        
        try? await Task.sleep(nanoseconds: 5_000_000_000)
        
        /*
         
         check cancel task using checkCancellation() method on Task type
         try Task.checkCancellation()
         
         eg:-
         
         for x in array {
            try Task.checkCancellation()
         }
         
         */
        
        do {
            guard let url = URL(string: "https://picsum.photos/2000") else {
                return
            }
            let request = URLRequest(url: url)
            let (data, _) = try await URLSession.shared.data(for: request, delegate: nil)
            await MainActor.run {
                self.image = UIImage(data: data)
                print("Image Returned Successfully!!".uppercased())
            }
        } catch {
            print("error: ", error.localizedDescription)
        }
    }
    
    func fetchImage2() async {
        do {
            guard let url = URL(string: "https://picsum.photos/2000") else {
                return
            }
            let request = URLRequest(url: url)
            let (data, _) = try await URLSession.shared.data(for: request, delegate: nil)
            await MainActor.run {
                self.image2 = UIImage(data: data)
                print("Image Returned Successfully!!".uppercased())
            }
        } catch {
            print("error: ", error.localizedDescription)
        }
    }

}

struct TasksBCHomeView: View {
    var body: some View {
        NavigationView {
            NavigationLink("TAP HERE") {
                TasksBC()
            }
        }
    }
}

struct TasksBC: View {
    
    @StateObject var viewModel = TasksViewModel()
    @State var fetchImageTask: Task<Void, Never>? = nil
    
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
        .task {
            await viewModel.fetchImage()
        }
//        .onDisappear {
//            self.fetchImageTask?.cancel()
//        }
//        .onAppear {
//            self.fetchImageTask = Task {
//                print(Thread.current)
//                print(Task.currentPriority)
//                await viewModel.fetchImage()
//                //await viewModel.fetchImage2()
//            }
//            
//            Task {
//                print(Thread.current)
//                print(Task.currentPriority)
//                await viewModel.fetchImage2()
//            }
            
//            print("=====================================================")
//            
//            Task(priority: .high) {
//                //try? await Task.sleep(nanoseconds:2_000_000_000)
//                await Task.yield()
//                print("high: \(Thread.current) : \(Task.currentPriority)")
//            }
//
//            Task(priority: .low) {
//                print("low: \(Thread.current) : \(Task.currentPriority)")
//            }
//            Task(priority: .medium) {
//                print("medium: \(Thread.current) : \(Task.currentPriority)")
//            }
//            Task(priority: .utility) {
//                print("utility: \(Thread.current) : \(Task.currentPriority)")
//            }
//            Task(priority: .userInitiated) {
//                print("userInitiated: \(Thread.current) : \(Task.currentPriority)")
//            }
//            Task(priority: .background) {
//                print("background: \(Thread.current) : \(Task.currentPriority)")
//            }
            
            // Parent - Child Task relationship
//            Task(priority: .userInitiated) {
//                print("userInitiated: \(Thread.current) : \(Task.currentPriority)")
//                Task() {
//                    print("userInitiated2: \(Thread.current) : \(Task.currentPriority)")
//                }
//            }
            
            // Detached Task from its Parent Task
//            Task(priority: .low) {
//                print("low: \(Thread.current) : \(Task.currentPriority)")
//                Task.detached() {
//                    print("low2-detached: \(Thread.current) : \(Task.currentPriority)")
//                }
//            }

//        }
    }
}

#Preview {
    TasksBC()
}

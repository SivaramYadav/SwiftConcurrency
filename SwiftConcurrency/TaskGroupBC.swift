//
//  TaskGroupBC.swift
//  SwiftConcurrency
//
//  Created by Sivaram Yadav on 28/08/24.
//

import SwiftUI

class TaskGroupDataManager {
    
    func fetchImagesWithAsyncLet() async throws -> [UIImage] {
        async let fetchImage1 = fetchImage(from: "https://picsum.photos/300")
        async let fetchImage2 = fetchImage(from: "https://picsum.photos/300")
        async let fetchImage3 = fetchImage(from: "https://picsum.photos/300")
        async let fetchImage4 = fetchImage(from: "https://picsum.photos/300")
        
        let (image1, image2, image3, image4) = await (try fetchImage1, try fetchImage2, try fetchImage3, try fetchImage4)
        return [image1, image2, image3, image4]
    }
    
    func fetchImage(from urlString: String) async throws -> UIImage {
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(for: URLRequest(url: url), delegate: nil)
            if let image = UIImage(data: data) {
                return image
            } else {
                throw URLError(.badURL)
            }
        } catch {
            throw error
        }
    }
    
    func fetchImagesWithTaskGroup() async throws -> [UIImage] {
        let urls: [String] = [
            "https://picsum.photos/300",
            "https://picsum.photos/300",
            "https://picsum.photos/300",
            "https://picsum.photos/300",
            "https://picsum.photos/300",
        ]
        
        return try await withThrowingTaskGroup(of: UIImage?.self) { group in
            var images: [UIImage] = []
            images.reserveCapacity(urls.count)
            
            for url in urls {
                group.addTask {
                    try? await self.fetchImage(from: url)
                }
            }
            
            for try await returnedImage in group {
                if let image = returnedImage {
                    images.append(image)
                }
            }
            
            return images
        }
    }

}

class TaskGroupBCViewModel: ObservableObject {
    @Published var images: [UIImage] = []
    let dataManager = TaskGroupDataManager()
    
    func getImages() async {
        if let images = try? await dataManager.fetchImagesWithAsyncLet() {
            self.images.append(contentsOf: images)
        }
    }
    
    func getImagesWithTaskGroup() async {
        if let images = try? await dataManager.fetchImagesWithTaskGroup() {
            self.images.append(contentsOf: images)
        }
    }
}

struct TaskGroupBC: View {
    
    @StateObject private var viewModel = TaskGroupBCViewModel()
    let columns: [GridItem] = [GridItem(.flexible()), GridItem(.flexible())]
    let url = URL(string: "https://picsum.photos/300")!

    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: columns) {
                    ForEach(viewModel.images, id: \.self) { image in
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 150)
                    }
                }
            }
            .navigationTitle("Task Group BC")
            .task {
                //await viewModel.getImages()
                await viewModel.getImagesWithTaskGroup()
            }
        }
    }
}

#Preview {
    TaskGroupBC()
}

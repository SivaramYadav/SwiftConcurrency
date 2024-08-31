//
//  CheckedContinuationBC.swift
//  SwiftConcurrency
//
//  Created by Sivaram Yadav on 30/08/24.
//

import SwiftUI


class CheckedContinuationNetworkManager {
    
    func getData(url: URL) async throws -> Data {
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            return data
        } catch  {
            throw error
        }
    }
    
    func getDataWithContinuation(url: URL) async throws -> Data {
        return try await withCheckedThrowingContinuation { continuation in
            URLSession.shared.dataTask(with: URLRequest(url: url)) { data, response, error in
                if let data = data {
                    continuation.resume(returning: data)
                } else if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(throwing: URLError(.badURL))
                }
            }
            .resume()
        }
    }
    
    func getHeartImage(completionHandler: @escaping (_ image:UIImage) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
            completionHandler(UIImage(systemName: "heart.fill")!)
        }
    }
    
    // convert above func into async-await with checkedcontinuation
    func getHeartImageWithCheckedContinuation() async -> UIImage {
        return await withCheckedContinuation { continuation in
            getHeartImage { image in
                continuation.resume(returning: image)
            }
        }
    }
}

class CheckedContinuationViewModel: ObservableObject {
    
    @Published var image: UIImage? = nil
    let manager = CheckedContinuationNetworkManager()
    
    func fetchImage() async {
        guard let url = URL(string: "https://picsum.photos/300") else {
            return
        }
        do {
            let data = try await manager.getData(url: url)
            if let image = UIImage(data: data) {
                await MainActor.run {
                    self.image = image
                }
            }
        } catch  {
            print(error.localizedDescription)
        }
    }
    
    func fetchImage2() async {
        guard let url = URL(string: "https://picsum.photos/300") else {
            return
        }

        do {
            let data = try await manager.getDataWithContinuation(url: url)
            if let image = UIImage(data: data) {
                await MainActor.run {
                    self.image = image
                }
            }
        } catch  {
            print(error.localizedDescription)
        }
    }
    
    func fetchImage3() async {
//        manager.getHeartImage { image in
//            self.image = image
//        }
        
        // convert above approach like escaping closure to async-await approach
        // like below way
        
        self.image = await manager.getHeartImageWithCheckedContinuation()
    }
}

struct CheckedContinuationBC: View {
    
    @StateObject var viewModel = CheckedContinuationViewModel()
    
    var body: some View {
        ZStack {
            if let image = viewModel.image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 300, height: 300)
            }
        }
        .task {
            //await viewModel.fetchImage()
            //await viewModel.fetchImage2()
            await viewModel.fetchImage3()
        }
    }
}

#Preview {
    CheckedContinuationBC()
}

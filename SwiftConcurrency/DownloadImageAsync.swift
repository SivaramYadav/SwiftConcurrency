//
//  DownloadImageAsync.swift
//  SwiftConcurrency
//
//  Created by Sivaram Yadav on 25/08/24.
//

import SwiftUI
import Combine

/*
     - 200..<300 ~= response.statusCode
     - means Is the given range[ here ==> 200..<300 ] contains "response.statusCode" value?
     - Like in some range, is given value contains or not
     - We can check like that
*/

class DownloadImageAsyncImageLoader {
    
    let urlRequest = URLRequest(url: URL(string: "https://picsum.photos/200")!)
    
    func handleResponse(data: Data?, response: URLResponse?) -> UIImage? {
        guard
            let data = data,
            let image = UIImage(data: data),
            let response = response as? HTTPURLResponse,
            200..<300 ~= response.statusCode
        else {
            return nil
        }
        return image
    }
    
    func downloadWithEscaping(completionHandler:  @escaping (_ image: UIImage?, _ error: Error?) -> Void) {
        URLSession.shared.dataTask(with: urlRequest) { [weak self] data, response, error in
            let image = self?.handleResponse(data: data, response: response)
            completionHandler(image, error)
        }
        .resume()
    }
    
    func downloadWithCombine() -> AnyPublisher<UIImage?, Error> {
        URLSession.shared.dataTaskPublisher(for: URL(string: "https://picsum.photos/200")!)
            .map(handleResponse)
            .mapError({ $0 })
            .eraseToAnyPublisher()
    }
    
    func downloadWithAsync() async throws -> UIImage? {
        do {
            let (data, response) = try await URLSession.shared.data(for: urlRequest)
            let image = handleResponse(data: data, response: response)
            return image
        } catch {
            throw error
        }
    }
}

class DownloadImageAsyncViewModel: ObservableObject {
    
    @Published var image: UIImage? = nil
    let loader = DownloadImageAsyncImageLoader()
    var cancellables = Set<AnyCancellable>()
    
    func fetchImage() {
        self.image = UIImage(systemName: "heart.fill")
    }
    
    func fetchImage2() {
        loader.downloadWithEscaping { [weak self] image, error in
            DispatchQueue.main.async {
                self?.image = image
            }
        }
    }
    
    func fetchImage3() {
        /*
         loader.downloadWithCombine()
         .sink { _ in
         
         } receiveValue: { image in
         DispatchQueue.main.async { [ weak self] in
         self?.image = image
         }
         }
         .store(in: &cancellables)
         }
         */
        
        loader.downloadWithCombine()
            .receive(on: DispatchQueue.main)
            .sink { _ in

            } receiveValue: { [weak self] image in
                self?.image = image
            }
            .store(in: &cancellables)
    }
    
    func fetchImage4() async {
        let image = try? await loader.downloadWithAsync()
        await MainActor.run {
            self.image = image
        }
    }


}

struct DownloadImageAsync: View {
    
    @StateObject var viewModel = DownloadImageAsyncViewModel()
    
    var body: some View {
        ZStack {
            if let image = viewModel.image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 250, height: 250)
            }
        }
        .onAppear {
            //viewModel.fetchImage()
            //viewModel.fetchImage2()
            //viewModel.fetchImage3()
            Task {
                await viewModel.fetchImage4()
            }
        }
    }
}

#Preview {
    DownloadImageAsync()
}

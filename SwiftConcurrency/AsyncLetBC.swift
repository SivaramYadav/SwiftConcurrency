//
//  AsyncLetBC.swift
//  SwiftConcurrency
//
//  Created by Sivaram Yadav on 27/08/24.
//

import SwiftUI

struct AsyncLetBC: View {
    
    @State private var images: [UIImage] = []
    let columns: [GridItem] = [GridItem(.flexible()), GridItem(.flexible())]
    let url = URL(string: "https://picsum.photos/300")!
    @State var title: String = "First Title!!"
    
    var body: some View {
        NavigationView {
            ScrollView {
                Text(title)
                    .font(.title)
                    .fontWeight(.semibold)
                    .foregroundStyle(.orange)
                    .padding(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                LazyVGrid(columns: columns) {
                    ForEach(images, id: \.self) { image in
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 150)
                    }
                }
            }
            .navigationTitle("Async Let BC")
            .onAppear {
                //images.append(UIImage(systemName: "heart.fill")!)
                
                Task {
                    
                    do {
                        
                        async let fetchImage1 = fetchImage()
                        async let fetchTitle = fetchTitle()
                        let (image, title) = await (try fetchImage1, fetchTitle)
                        self.images.append(image)
                        self.title = title
                        
//                        async let fetchImage2 = fetchImage()
//                        async let fetchImage3 = fetchImage()
//                        async let fetchImage4 = fetchImage()
//                        
//                        let (image1, image2, image3, image4) = await (try fetchImage1, try fetchImage2, try fetchImage3, try fetchImage4)
//                        self.images.append(contentsOf: [image1, image2, image3, image4])
                        

//                        let image1 = try await fetchImage()
//                        self.images.append(image1)
//
//                        let image2 = try await fetchImage()
//                        self.images.append(image2)
//
//                        let image3 = try await fetchImage()
//                        self.images.append(image3)
//
//                        let image4 = try await fetchImage()
//                        self.images.append(image4)

                    } catch {
                        
                    }
                }
            }
        }
    }
    
    func fetchImage() async throws -> UIImage {
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
    
    func fetchTitle() async -> String {
        return "NEW TITLE!"
    }
}

#Preview {
    AsyncLetBC()
}

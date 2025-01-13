//
//  ContentView.swift
//  zadanie-06
//
//  Created by Alexander on 12/01/2025.
//

import SwiftUI

struct Product: Identifiable, Codable {
    let id: Int
    let name: String
    let price: Double
    let count: Int
    let productDescription: String
    let category: String
}

struct ContentView: View {
    @State private var products: [Product] = []
    @State private var isLoading = true

    var body: some View {
        NavigationView {
            Group {
                if isLoading {
                    ProgressView("Loading ...")
                } else {
                    List(products) { product in
                        VStack(alignment: .leading) {
                            Text(product.name).font(.headline)
                            HStack {
                                Text("Price: $\(product.price, specifier: "%.2f")").font(.subheadline)
                                Text("Availability: \(product.count)").font(.subheadline)
                            }
                            Text(product.productDescription)
                                .font(.caption)
                                .foregroundColor(.gray)

                            // Navigate to CheckoutView and pass the selected product
                            NavigationLink(destination: CheckoutView(product: product)) {
                                Text("Buy 🛒")
                                    .foregroundColor(.white)
                                    .padding()
                                    .background(Color.green)
                                    .cornerRadius(8)
                            }
                        }
                        .padding(.vertical, 5)
                    }
                }
            }
            .navigationTitle("Products")
            .onAppear {
                fetchProducts()
            }
        }
    }

    private func fetchProducts() {
        let url = URL(string: "http://localhost:3000/products")!

        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let _ = error {
                print("Error when fetching products")
                return
            }

            do {
                let decodedProductsList = try JSONDecoder().decode([Product].self, from: data!)
                products = decodedProductsList
                isLoading = false
            } catch {
                print("Error when decoding")
            }
        }
        task.resume()
    }
}

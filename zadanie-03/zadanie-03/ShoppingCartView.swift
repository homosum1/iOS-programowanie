//
//  ShoppingCartView.swift
//  zadanie-03
//
//  Created by Alexander on 30/11/2024.
//

import Foundation

import SwiftUI

class CartManager: ObservableObject {
    @Published var cartItems: [(product: Product, count: Int)] = []

    func addToCart(product: Product) {
     

        
        
        let index = cartItems.firstIndex(where: { $0.product.name == product.name })

        // check for avatiable supply
        if (product.count <= 0) { return }
        if (index != nil) && (cartItems[index!].count >= product.count) { return }
        
        if (index != nil) {
            cartItems[index!].count += 1
        } else {
            cartItems.append((product, 1))
        }
    }
    
    func removeFromCart(product: Product) {

        let index = cartItems.firstIndex(where: { $0.product.name == product.name })

        if (index != nil) {
            if cartItems[index!].count > 1 {
                cartItems[index!].count -= 1
            } else {
                cartItems.remove(at: index!)
            }
        }
    }
}


struct CartView: View {
    @EnvironmentObject var cartManager: CartManager

    var body: some View {
        NavigationView {
            List {
                if cartManager.cartItems.isEmpty {
                    Text("No items in cart 😭")
                        .foregroundColor(.gray)
                } else {
               
                    
                    ForEach(cartManager.cartItems, id: \.product) { item in
                        HStack {
                            Text(item.product.name ?? "oopsie")
                            Spacer()
                            Text("Count: \(item.count)")
                            Spacer()
                            Text("\(item.product.price * Float(item.count), specifier: "%.2f")zł")
                                .foregroundColor(.gray)
                            Spacer()
                            
                            Button(action: {
                                cartManager.removeFromCart(product: item.product)
                            }) {
                                Image(systemName: "trash")
                                    .foregroundColor(.red)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Shopping Cart 🛒")
        }
    }
}

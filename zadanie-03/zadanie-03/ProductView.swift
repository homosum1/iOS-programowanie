//
//  ProductView.swift
//  zadanie-03
//
//  Created by Alexander on 30/11/2024.
//

import Foundation
import SwiftUI

struct ProductView: View {
    @EnvironmentObject var cartManager: CartManager

    let product: Product
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text("Product name: \(product.name!)")
                .font(.headline)
                .fontWeight(.bold)
            
            
            Divider()
                .background(Color.gray)
            
            HStack(content: {
                Text("Price: \(product.price, specifier: "%.2f")zł")
                    .font(.body)
                    .foregroundColor(.black)
                
                
                Text("Stock: \(product.count)")
                    .font(.body)
                    .foregroundColor(.black)
                
            })

            Divider()
                .background(Color.gray)
            
            Text("Description:\n\(product.productDescription!)")
                .font(.body)
                .foregroundColor(.black)
            
        
            Button(action: {
                            cartManager.addToCart(product: product)
                        }) {
                            Text("Add to Cart")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
            
            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// dummy - is this a good practice?
struct ProductView_dummy: PreviewProvider {
    static var previews: some View {

        let persistenceController = PersistenceController(inMemory: true)
        let context = persistenceController.container.viewContext
        
        // mock
        let product = Product(context: context)
        product.name = "Sample Product"
        product.price = 99.99
        product.count = 5
        product.productDescription = "Sample sample description"

        return NavigationView {
            ProductView(product: product)
        }
    }
}

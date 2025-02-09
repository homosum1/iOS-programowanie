//
//  AddProductView.swift
//  zadanie-04
//
//  Created by Alexander on 17/12/2024.
//

import Foundation
import SwiftUI

struct AddProductView: View {
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.managedObjectContext) private var viewContext

//    @EnvironmentObject var persistenceController: PersistenceController

    var category: Category
      
    @State private var name: String = ""
    @State private var price: String = ""
    @State private var count: String = ""
    @State private var productDescription: String = ""
    @State private var categoryName: String = ""
    @State private var errorMessage: String = ""

    init(category: Category) {
        self.category = category
        _categoryName = State(initialValue: category.name ?? "")
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Product data:")) {
                    TextField("name", text: $name)
                    TextField("price", text: $price).keyboardType(.decimalPad)
                    TextField("count", text: $count).keyboardType(.numberPad)
                    TextField("description", text: $productDescription)
                    TextField("category", text: $categoryName).disabled(true)
                }
                
                if !errorMessage.isEmpty {
                    Text("Error: \(errorMessage)")
                        .foregroundColor(.red)
                        .font(.subheadline)
                }
                
                Button(action: {
                    addProduct()
                }) {
                    HStack {
                        
                        Image(systemName: "plus")
                                   .foregroundColor(.white)
                                   .padding(.trailing, 5)
                        
                        Text("Add Product").foregroundColor(.white)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(8)
                }
            }
            .navigationTitle("Add Product")
            .navigationBarItems(trailing: Button("exit x") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
    
    private func addProduct() {
        guard let priceValue = Float(price),
              let countValue = Int16(count),
              !name.isEmpty,
              !productDescription.isEmpty,
              !categoryName.isEmpty else {
                errorMessage = "Missing form fields"
                return
              }
        
        errorMessage = ""
        
        let newProductData: [String: Any] = [
            "name": name,
            "price": priceValue,
            "count": countValue,
            "productDescription": productDescription,
            "category": categoryName
        ]
        
        // Server request
        guard let url = URL(string: "http://localhost:3000/products") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: newProductData, options: [])
        } catch {
            errorMessage = "req error:"
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                
                if error != nil {
                    errorMessage = "network fail"
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 201 else {
                    errorMessage = "fail when adding product"
                    return
                }
            
//              LEGACY
//              RELOAD COREDATA
//                persistenceController.reload()
                
                self.addProductToCoreData(name: self.name, price: priceValue, count: countValue, productDescription: self.productDescription)
                                
                presentationMode.wrappedValue.dismiss()
            }
        }.resume()
    }
    

    private func addProductToCoreData(name: String, price: Float, count: Int16, productDescription: String) {

         let newProduct = Product(context: viewContext)
         newProduct.id = UUID()
         newProduct.name = name
         newProduct.price = price
         newProduct.count = count
         newProduct.productDescription = productDescription
         

         newProduct.category = category
         

         do {
             try viewContext.save()
             print("core data product added")
         } catch {
             errorMessage = ""
             print("core data product adding: \(error)")
         }
     }
}


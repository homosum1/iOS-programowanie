//
//  CheckoutView.swift
//  zadanie-06
//
//  Created by Alexander on 12/01/2025.
//

import Foundation
import SwiftUI
import Stripe
import UIKit
import StripePaymentSheet


struct CheckoutView: View {
    @ObservedObject var model: MyBackendModel
    var product: Product
    
    init(product: Product) {
        self.product = product
        model = MyBackendModel(product: product)
    }

    var body: some View {
        VStack {
            Text(product.name)
                .font(.largeTitle)
                .padding()
            Text("Price: \(product.price, specifier: "%.2f")")
                .font(.title)
                .padding()

            Text(product.productDescription)
                .font(.body)
                .foregroundColor(.gray)
                .padding()

            if let paymentSheet = model.paymentSheet {
                PaymentSheet.PaymentButton(
                    paymentSheet: paymentSheet,
                    onCompletion: model.onPaymentCompletion
                ) {
                    Text("Make a payment")
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.green)
                        .cornerRadius(8)
                }
                .padding(.top)
            } else {
                Text("Loading…")
                    .padding()
            }

            if let result = model.paymentResult {
                switch result {
                case .completed:
                    Text("Payment successful!")
                        .foregroundColor(.green)
                        .font(.title)
                        .padding()
                case .failed(let error):
                    Text("Payment failed: \(error.localizedDescription)")
                        .foregroundColor(.red)
                        .font(.title)
                        .padding()
                case .canceled:
                    Text("Payment canceled.")
                        .foregroundColor(.orange)
                        .font(.title)
                        .padding()
                }
            }
        }
        .onAppear { model.preparePaymentSheet() }
        .navigationTitle("Checkout")
    }
    
}


class MyBackendModel: ObservableObject {
    let backendCheckoutUrl = URL(string: "http://localhost:3000/payment-sheet")!
    @Published var paymentSheet: PaymentSheet?
    @Published var paymentResult: PaymentSheetResult?
    
    var product: Product
    @Published var productName: String = ""
    @Published var productPrice: Double = 0.0

    init(product: Product) {
        self.product = product
    }

    func preparePaymentSheet() {
        var request = URLRequest(url: backendCheckoutUrl)
        request.httpMethod = "POST"

        print(product.id)
        
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
              
        let body = try? JSONEncoder().encode(["productId": product.id])
        request.httpBody = body

        let task = URLSession.shared.dataTask(with: request) { [weak self] (data, _, error) in
            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                  let customerId = json["customer"] as? String,
                  let ephemeralKeySecret = json["ephemeralKey"] as? String,
                  let paymentIntentClientSecret = json["paymentIntent"] as? String,
                  let publishableKey = json["publishableKey"] as? String,
                  let productName = json["productName"] as? String,
                  let productPrice = json["productPrice"] as? Double,
                  let self = self else {
                return
            }

            DispatchQueue.main.async {
                self.productName = productName
                self.productPrice = productPrice
            }

            STPAPIClient.shared.publishableKey = publishableKey
            
            var configuration = PaymentSheet.Configuration()
            configuration.merchantDisplayName = "Example, Inc."
            configuration.customer = .init(id: customerId, ephemeralKeySecret: ephemeralKeySecret)
            configuration.allowsDelayedPaymentMethods = true

            DispatchQueue.main.async {
                self.paymentSheet = PaymentSheet(paymentIntentClientSecret: paymentIntentClientSecret, configuration: configuration)
            }
        }
        task.resume()
    }

    func onPaymentCompletion(result: PaymentSheetResult) {
  
        DispatchQueue.main.async {
            self.paymentResult = result
        }
        
        if case .completed = result {
            updateProductStock() // update stock
        }
    }
    
    private func updateProductStock() {
        guard let url = URL(string: "http://localhost:3000/update-stock") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = ["productId": product.id]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                return
            }
            
        }
        task.resume()
    }
}





//struct CheckoutView: View {
//    let product: Product
//    
//    @State private var paymentSheet: PaymentSheet?
//    @State private var isLoading = true
//    @State private var priceInCents = 5
//    @State private var currency = "USD"
//    @State private var formattedPrice = "$0.00"
//    
//    let backendCheckoutUrl = URL(string: "http://localhost:3000/payment-sheet")!
//
//    var body: some View {
//        VStack {
//            if isLoading {
//                ProgressView("Preparing Checkout...")
//            } else {
//                Text("Product: \(product.name)")
//                    .font(.largeTitle)
//                    .padding()
//
//                Text("Price: \(formattedPrice)")
//                    .font(.title)
//                    .padding()
//
//                Button(action: {
//                    startCheckout()
//                }) {
//                    Text("Proceed with Payment")
//                        .fontWeight(.bold)
//                        .foregroundColor(.white)
//                        .padding()
//                        .background(Color.green)
//                        .cornerRadius(8)
//                }
//                .padding(.top)
//            }
//        }
//        .onAppear {
//            prepareCheckout()
//        }
//        .navigationTitle("Checkout")
//    }
//
//    private func prepareCheckout() {
//        // Fetch the PaymentIntent, ephemeral key, and other required data from your server
//        var request = URLRequest(url: backendCheckoutUrl)
//        request.httpMethod = "POST"
//        request.httpBody = try? JSONEncoder().encode(["productId": product.id])
//        
//        let task = URLSession.shared.dataTask(with: request) { data, _, error in
//            if let error = error {
//                print("Failed to fetch checkout details: \(error.localizedDescription)")
//                return
//            }
//
//            guard let data = data,
//                  let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
//                  let customerId = json["customer"] as? String,
//                  let ephemeralKeySecret = json["ephemeralKey"] as? String,
//                  let paymentIntentClientSecret = json["paymentIntent"] as? String,
//                  let publishableKey = json["publishableKey"] as? String,
//                  let amount = json["amount"] as? Int,
//                  let currency = json["currency"] as? String else {
//                print("Invalid response data")
//                return
//            }
//
//        
//            DispatchQueue.main.async {
//                self.priceInCents = amount
//                self.currency = currency
//                self.formattedPrice = formatCurrency(amount: amount, currency: currency)
//            }
//
//            STPAPIClient.shared.publishableKey = publishableKey
//
//            var configuration = PaymentSheet.Configuration()
//            configuration.merchantDisplayName = "Example Store"
//            configuration.customer = .init(id: customerId, ephemeralKeySecret: ephemeralKeySecret)
//            configuration.allowsDelayedPaymentMethods = true
//            
//            paymentSheet = PaymentSheet(paymentIntentClientSecret: paymentIntentClientSecret, configuration: configuration)
//
//            DispatchQueue.main.async {
//                isLoading = false
//            }
//        }
//        task.resume()
//    }
//
//    private func startCheckout() {
//        guard let paymentSheet = paymentSheet else {
//            print("Something went wrong.")
//            return
//        }
//
//        // Present the PaymentSheet
//        DispatchQueue.main.async {
//            paymentSheet.present(from: UIViewController()) { paymentResult in
//                switch paymentResult {
//                case .completed:
//                    print("Payment successful!")
//                case .failed(let error):
//                    print("Payment failed: \(error.localizedDescription)")
//                case .canceled:
//                    print("Payment canceled.")
//                }
//            }
//        }
//    }
//
//    private func formatCurrency(amount: Int, currency: String) -> String {
//        let formatter = NumberFormatter()
//        formatter.numberStyle = .currency
//        formatter.currencyCode = currency
//        
//        // Convert from cents to the correct format
//        let amountInUnits = Double(amount) / 100.0
//        return formatter.string(from: NSNumber(value: amountInUnits)) ?? "$\(amountInUnits)"
//    }
//}
//

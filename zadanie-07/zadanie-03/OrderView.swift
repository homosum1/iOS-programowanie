//
//  OrderView.swift
//  zadanie-04
//
//  Created by Alexander on 17/12/2024.
//

import SwiftUI
import Foundation

struct OrderView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Order.date, ascending: false)],
        animation: .default
    )
    
    private var orders: FetchedResults<Order>

    var body: some View {
        List {
            ForEach(orders) { order in
                NavigationLink(destination: OrderDetailView(order: order)) {
                    VStack(alignment: .leading) {
                        Text(order.customerName ?? "???")
                            .font(.headline)

                        if let date = order.date {
                            Text(date, style: .date)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }

                        Text("Total: \(order.totalPrice, specifier: "%.2f")zł")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .navigationTitle("Orders")
    }
}

struct OrderDetailView: View {
    let order: Order

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Order Details")
                .font(.title2)
                .bold()

            Text("name: \(order.customerName ?? "???")")
            Text("address: \(order.street ?? ""), \(order.city ?? "")")
            Text("postcode: \(order.postcode ?? "")")

            if let date = order.date { Text("date: \(date, style: .date)") }

            Text("total: \(order.totalPrice, specifier: "%.2f")zł").bold()
            Divider()

            Text("products:").font(.headline)

            List {
                let products = order.products as? Set<OrderProduct> ?? Set<OrderProduct>()
                ForEach(Array(products)) { product in
                    HStack {
                        Text(product.name ?? "???")
                        Spacer()
                        Text("x \(product.quantity)").foregroundColor(.gray)
                    }
                }
            }
        }
        .padding()
    }
}

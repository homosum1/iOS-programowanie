//
//  OrderDTO.swift
//  zadanie-04
//
//  Created by Alexander on 14/12/2024.
//

import Foundation

struct OrderDTO: Decodable {
    let id: Int
    let customerName: String
    let street: String
    let city: String
    let postcode: String
    let date: String
    let totalPrice: Float
    let products: [OrderProductDTO]
}

struct OrderProductDTO: Decodable {
    let orderId: Int
    let quantity: Int
    let name: String
}

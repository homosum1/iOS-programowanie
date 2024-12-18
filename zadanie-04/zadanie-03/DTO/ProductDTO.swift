//
//  ProductDTO.swift
//  zadanie-04
//
//  Created by Alexander on 13/12/2024.
//

import Foundation

struct ProductDTO: Decodable {
    let id: Int
    let name: String
    let price: Float
    let count: Int
    let productDescription: String
    let category: String
}

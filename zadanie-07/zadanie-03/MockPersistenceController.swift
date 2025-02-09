//
//  MockPersistenceController.swift
//  zadanie-04
//
//  Created by Alexander on 10/02/2025.
//

import Foundation
import CoreData

class MockPersistenceController: PersistenceController {
    
    override init(inMemory: Bool = true) {
        super.init(inMemory: true)
        createMockCategories(in: container.viewContext)
       createMockProducts(in: container.viewContext)
    }
    
    override public func fetchCategories() async -> [CategoryDTO]? {
        return [
            CategoryDTO(id: 1, name: "Fruits"),
            CategoryDTO(id: 2, name: "Vegetables"),
            CategoryDTO(id: 3, name: "Dairy")
        ]
    }
    
    override public func fetchProducts() async -> [ProductDTO]? {
        return [
            ProductDTO(id: 1, name: "Apple", price: 2.99, count: 25, productDescription: "A fresh and juicy apple.", category: "Fruits"),
            ProductDTO(id: 2, name: "Banana", price: 4.50, count: 35, productDescription: "A ripe yellow banana.", category: "Fruits"),
            ProductDTO(id: 3, name: "Carrot", price: 0.99, count: 20, productDescription: "A crunchy orange carrot.", category: "Vegetables"),
            ProductDTO(id: 4, name: "Milk", price: 6.50, count: 19, productDescription: "A bottle of fresh milk.", category: "Dairy")
        ]
    }
    
    override public func fetchOrders() async -> [OrderDTO]? {
        return [
            OrderDTO(id: 1, customerName: "User 123", street: "Kołatkowa 24", city: "Kraków", postcode: "37-389", date: "2024-12-13", totalPrice: 34.56, products: [
                OrderProductDTO(orderId: 1, quantity: 2, name: "Banana"),
                OrderProductDTO(orderId: 3, quantity: 3, name: "Milk")
            ])
        ]
    }
    
    func createMockCategories(in context: NSManagedObjectContext) {
           let fruits = Category(context: context)
           fruits.id = UUID()
           fruits.name = "Fruits"

           let vegetables = Category(context: context)
           vegetables.id = UUID()
           vegetables.name = "Vegetables"

           let dairy = Category(context: context)
           dairy.id = UUID()
           dairy.name = "Dairy"

           try? context.save()
   }
    
    func createMockProducts(in context: NSManagedObjectContext) {
        let apple = Product(context: context)
        apple.id = UUID()
        apple.name = "Apple"
        apple.price = 2.99
        apple.count = 25
        apple.productDescription = "A fresh and juicy apple."

        let banana = Product(context: context)
        banana.id = UUID()
        banana.name = "Banana"
        banana.price = 4.50
        banana.count = 35
        banana.productDescription = "A ripe yellow banana."

        try? context.save()
    }
    
    func addMockProduct(name: String, price: Float, count: Int, description: String, categoryName: String) {
        let context = container.viewContext
        let product = Product(context: context)
        product.id = UUID()
        product.name = name
        product.price = price
        product.count = Int16(count)
        product.productDescription = description

        let fetchRequest: NSFetchRequest<Category> = Category.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "name == %@", categoryName)
        product.category = try? context.fetch(fetchRequest).first

        try? context.save()
    }
    
    func addMockOrder(customerName: String, street: String, city: String, postcode: String, totalPrice: Float, products: [(name: String, quantity: Int)]) {
        let context = container.viewContext
        let order = Order(context: context)
        order.id = UUID()
        order.customerName = customerName
        order.street = street
        order.city = city
        order.postcode = postcode
        order.totalPrice = totalPrice

        for product in products {
            let orderProduct = OrderProduct(context: context)
            orderProduct.quantity = Int16(product.quantity)
            orderProduct.orderId = UUID()
            orderProduct.name = product.name
            order.addToProducts(orderProduct)
        }

        try? context.save()
    }
}

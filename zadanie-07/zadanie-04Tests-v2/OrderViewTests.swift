//
//  OrderViewTests.swift
//  zadanie-04Tests-v2
//
//  Created by Alexander on 09/02/2025.
//

import XCTest
import CoreData

@testable import zadanie_04

final class OrderViewTests: XCTestCase {

    var cartManager: CartManager!
    var context: NSManagedObjectContext!

    override func setUp() {
           super.setUp()

           let container = NSPersistentContainer(name: "zadanie_03")
           let description = NSPersistentStoreDescription()
           description.type = NSInMemoryStoreType
           container.persistentStoreDescriptions = [description]
           container.loadPersistentStores { (_, error) in
               XCTAssertNil(error, "Failed to load: \(error!.localizedDescription)")
           }
           
           context = container.viewContext
           cartManager = CartManager()
       }

    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        super.setUp()
        cartManager = CartManager()
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        context = nil
        cartManager = nil
        super.tearDown()
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        // Any test you write for XCTest can be annotated as throws and async.
        // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
        // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
//        self.measure {
            // Put the code you want to measure the time of here.
//        }
    }
    
    func createProduct(name: String, price: Float, count: Int) -> Product {
        let product = Product(context: context)
        product.name = name
        product.price = price
        product.count = Int16(count)
        return product
    }
    
    func testAddToCart_IncreasesItemCount() {
        let product = createProduct(name: "Apple", price: 2.5, count: 10)
            
        cartManager.addToCart(product: product)
        XCTAssertEqual(cartManager.cartItems.first?.count, 1)
    }

        func testAddToCart_StockNotExceded() {
            let product = createProduct(name: "Banana", price: 1.0, count: 2)

            cartManager.addToCart(product: product)
            cartManager.addToCart(product: product)
            cartManager.addToCart(product: product)
            
            XCTAssertEqual(cartManager.cartItems.first?.count, 2)
        }

        func testAddToCart_QuantityIncrease() {
            let product = createProduct(name: "Chocolate", price: 5.0, count: 5)

            cartManager.addToCart(product: product)
            cartManager.addToCart(product: product)
            
            XCTAssertEqual(cartManager.cartItems.first?.count, 2)
        }

        func testRemoveFromCart_DecQuantity() {
            let product = createProduct(name: "Grapes", price: 5.0, count: 5)

            cartManager.addToCart(product: product)
            cartManager.addToCart(product: product)
            cartManager.removeFromCart(product: product)
            
            XCTAssertEqual(cartManager.cartItems.first?.count, 1)
        }

        func testRemoveFromCart_RemoveItemWithoutCount() {
            let product = createProduct(name: "Milk", price: 4.0, count: 5)

            cartManager.addToCart(product: product)
            cartManager.removeFromCart(product: product)
            
            XCTAssertTrue(cartManager.cartItems.isEmpty)
        }

        func testAddingOutOfStockItem_DoNotAddToCount() {
            let product = createProduct(name: "Chocolate", price: 3.0, count: 0)

            cartManager.addToCart(product: product)
            
            XCTAssertTrue(cartManager.cartItems.isEmpty)
        }

        func testCartIsEmptyInitially() {
            XCTAssertTrue(cartManager.cartItems.isEmpty, "Cart should be empty")
        }

}

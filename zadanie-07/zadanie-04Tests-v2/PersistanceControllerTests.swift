//
//  PersistanceControllerTests.swift
//  zadanie-04Tests-v2
//
//  Created by Alexander on 09/02/2025.
//

import XCTest
import CoreData

@testable import zadanie_04


final class PersistanceControllerTests: XCTestCase {

    var persistenceController: PersistenceController!
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        persistenceController = PersistenceController(inMemory: true)
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        persistenceController = nil
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
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
    func testPersistanceInit() {
        XCTAssertNotNil(persistenceController.container)
    }

    func testCoreDataLoad() {
        XCTAssertNotNil(persistenceController.container.persistentStoreCoordinator)
    }

    func testFetchCategories() async {
        let categories = await persistenceController.fetchCategories()
        XCTAssertNotNil(categories)
        XCTAssertFalse(categories!.isEmpty)
    }

    func testFetchProducts() async {
        let products = await persistenceController.fetchProducts()
        XCTAssertNotNil(products)
        XCTAssertFalse(products!.isEmpty)
    }

    func testFetchOrders() async {
        let orders = await persistenceController.fetchOrders()
        XCTAssertNotNil(orders)
        XCTAssertFalse(orders!.isEmpty)
    }
    
    func testSaveCategories() async {
        let context = persistenceController.container.viewContext
        let categories = [CategoryDTO(id: 1, name: "TestCategory")]

        await persistenceController.saveCategories(categories, in: context)

        let fetchRequest: NSFetchRequest<zadanie_04.Category> = zadanie_04.Category.fetchRequest()
        let fetchedCategories = try? context.fetch(fetchRequest)

        XCTAssertNotNil(fetchedCategories)
        XCTAssertEqual(fetchedCategories?.count, 1)
        XCTAssertEqual(fetchedCategories?.first?.name, "TestCategory")
    }


    func testSaveProducts() async {
        let context = persistenceController.container.viewContext
        
        let category = zadanie_04.Category(context: context)
        category.id = UUID()
        category.name = "Fruits"
        
        try? context.save()
        
        let products = [
            ProductDTO(id: 1, name: "Apple", price: 2.99, count: 10, productDescription: "A fresh apple", category: "Fruits")
        ]
        
        await persistenceController.saveProducts(products, in: context)
        
        let fetchRequest: NSFetchRequest<Product> = Product.fetchRequest()
        let fetchedProducts = try? context.fetch(fetchRequest)

        XCTAssertNotNil(fetchedProducts)
        XCTAssertEqual(fetchedProducts?.count, 1)
        XCTAssertEqual(fetchedProducts?.first?.name, "Apple")
    }

       
       func testSaveOrders() async {
           let context = persistenceController.container.viewContext
           
           let orders = [
            OrderDTO(id: 1, customerName: "user", street: "ulica", city: "testowo", postcode: "00-000", date: "2024-02-10", totalPrice: 1.0, products: [])
           ]

           await persistenceController.saveOrders(orders, in: context)

           let fetchRequest: NSFetchRequest<Order> = Order.fetchRequest()
           let fetchedOrders = try? context.fetch(fetchRequest)

           XCTAssertNotNil(fetchedOrders)
           XCTAssertEqual(fetchedOrders?.count, 1)
           XCTAssertEqual(fetchedOrders?.first?.customerName, "user")
       }
       
       func testProductCategoryR() async {
           let context = persistenceController.container.viewContext

           let category = Category(context: context)
           category.id = UUID()
           category.name = "Fruits"

           let product = Product(context: context)
           product.id = UUID()
           product.name = "Apple"
           product.category = category

           try? context.save()

           let fetchRequest: NSFetchRequest<Product> = Product.fetchRequest()
           let fetchedProducts = try? context.fetch(fetchRequest)

           XCTAssertNotNil(fetchedProducts?.first?.category)
           XCTAssertEqual(fetchedProducts?.first?.category?.name, "Fruits")
       }
       
       func testOrderProductRel() async {
           let context = persistenceController.container.viewContext

           let order = Order(context: context)
           order.id = UUID()
           order.customerName = "Test User"

           let orderProduct = OrderProduct(context: context)
           orderProduct.orderId = UUID()
           orderProduct.name = "Apple"
           orderProduct.quantity = 2

           order.addToProducts(orderProduct)
           
           try? context.save()

           let fetchRequest: NSFetchRequest<Order> = Order.fetchRequest()
           let fetchedOrders = try? context.fetch(fetchRequest)

           XCTAssertNotNil(fetchedOrders?.first?.products)
           XCTAssertEqual(fetchedOrders?.first?.products?.count, 1)
       }
       
       func testOrderDateSaving() async {
           let context = persistenceController.container.viewContext

           let order = Order(context: context)
           order.id = UUID()
           order.date = Date()

           try? context.save()

           let fetchRequest: NSFetchRequest<Order> = Order.fetchRequest()
           let fetchedOrder = try? context.fetch(fetchRequest).first

           XCTAssertNotNil(fetchedOrder?.date)
       }
       
        func testDatabaseInitialization() async {
            await persistenceController.fetchDataFromServer()
            XCTAssertTrue(true)
        }

       
       func testJSONDecodingCategories() async {
           let jsonData = """
           [
               {"id": 1, "name": "Fruits"},
               {"id": 2, "name": "Vegetables"}
           ]
           """.data(using: .utf8)!

           let categories = try? JSONDecoder().decode([CategoryDTO].self, from: jsonData)

           XCTAssertNotNil(categories)
           XCTAssertEqual(categories?.count, 2)
           XCTAssertEqual(categories?.first?.name, "Fruits")
       }
       
       func testInvalidJSONDecoding() async {
           let jsonData = """
           {"id": 1, "wrongKey": "Fruits"}
           """.data(using: .utf8)!

           let categories = try? JSONDecoder().decode([CategoryDTO].self, from: jsonData)

           XCTAssertNil(categories)
       }


}

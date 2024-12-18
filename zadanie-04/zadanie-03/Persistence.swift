import CoreData

class PersistenceController: ObservableObject {
    static let shared = PersistenceController()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "zadanie_03")

        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }

        container.loadPersistentStores { storeDescription, error in
            if let error = error as NSError? {
                fatalError("error \(error), \(error.userInfo)")
            }
        }
        
        
        
        clearDatabase() // for testing
        initializeData()
    }
    
//    func reload() {
//        clearDatabase()
//        initializeData()
//    }
    
    private func initializeData() {
        Task {
            await fetchDataFromServer()
        }
    }
    
    private func fetchDataFromServer() async {
        let viewContext = container.viewContext

        if let categories = await fetchCategories() {
            await saveCategories(categories, in: viewContext)
        } else {
            print("categories fetching error")
        }

        if let products = await fetchProducts() {
            await saveProducts(products, in: viewContext)
        } else {
            print("products fetching error")
        }
        
        if let orders = await fetchOrders() {
            await saveOrders(orders, in: viewContext)
        } else {
            print("orders fetching error")
        }
    }


    private func fetchCategories() async -> [CategoryDTO]? {
        let url = URL(string: "http://localhost:3000/categories")!

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let categories = try JSONDecoder().decode([CategoryDTO].self, from: data)
              
            return categories
        } catch {
            print("fetching categories error: \(error)")
            return nil
        }
    }

    private func fetchProducts() async -> [ProductDTO]? {
        let url = URL(string: "http://localhost:3000/products")!
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let products = try JSONDecoder().decode([ProductDTO].self, from: data)
            
            return products
        } catch {
            print("fetching products error: \(error)")
            return nil
        }
    }
    
    private func fetchOrders() async -> [OrderDTO]? {
        let url = URL(string: "http://localhost:3000/orders")!
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            
//            if let rawString = String(data: data, encoding: .utf8) {
//                print("raw JSON: \(rawString)")
//            }
            
            let orders = try JSONDecoder().decode([OrderDTO].self, from: data)
            return orders
        } catch {
            print("fetching orders error: \(error)")
            return nil
        }
    }


    private func saveCategories(_ categories: [CategoryDTO], in context: NSManagedObjectContext) async {
        do {
            try await context.perform {
                print(categories)
                for categoryDTO in categories {
                    let category = Category(context: context)
                    category.id = UUID()
                    category.name = categoryDTO.name
                }
                
                try context.save()
                print("Categories saved!")
            }
        } catch {
            print("error when saving categories: \(error)")
        }
    }

    private func saveProducts(_ products: [ProductDTO], in context: NSManagedObjectContext) async {
        do {
            try await context.perform {
                for productDTO in products {
                    let product = Product(context: context)
                    product.id = UUID()
                    product.name = productDTO.name
                    product.price = productDTO.price
                    product.count = Int16(productDTO.count)
                    product.productDescription = productDTO.productDescription
                    
                    
//                  LINKING PRODUCT.CATEGORY WITH CATEGORY FROM COREDATA
                    let fetchRequest: NSFetchRequest<Category> = Category.fetchRequest()
                    fetchRequest.predicate = NSPredicate(format: "name == %@", productDTO.category)
                    
                    product.category = try context.fetch(fetchRequest).first
                }
                
                try context.save()
                print("Products saved!")
            }
        } catch {
            print("error when saving products: \(error)")
        }
    }
    
    
    private func saveOrders(_ orders: [OrderDTO], in context: NSManagedObjectContext) async {
        do {
            try await context.perform {
                for orderDTO in orders {
                    let order = Order(context: context)
                    
                    order.id = UUID()
                    order.customerName = orderDTO.customerName
                    order.street = orderDTO.street
                    order.city = orderDTO.city
                    order.postcode = orderDTO.postcode
                    order.totalPrice = orderDTO.totalPrice
                    
                    let formatter = DateFormatter()
                    formatter.dateFormat = "yyyy-MM-dd"
                    order.date = formatter.date(from: orderDTO.date)
                    
                    
                    for orderProductDTO in orderDTO.products {
                        
                        let orderProduct = OrderProduct(context: context)
                        
                        orderProduct.quantity = Int16(orderProductDTO.quantity)
                        orderProduct.orderId = UUID()
                        orderProduct.name = orderProductDTO.name
                        order.addToProducts(orderProduct)
                    }
                    
                    
                }
                
                try context.save()
                print("Orders saved!")
            }
        } catch {
            print("Error when saving orders: \(error)")
        }
    }


    
//    LEGACY FUNCTION FROM PREVIOUS TASK
//
//    private func loadSampleData() {
//        let viewContext = container.viewContext
//
//
//        let fetchRequest: NSFetchRequest<Category> = Category.fetchRequest()
//        do {
//            let categories = try viewContext.fetch(fetchRequest)
//            
//            if categories.isEmpty {
//                createSampleData(in: viewContext)
//            }
//        } catch {
//            let nsError = error as NSError
//            fatalError("Fetch error: \(nsError), \(nsError.userInfo)")
//        }
//    }
  
//    LEGACY FUNCTION FROM PREVIOUS TASK
//
//    private func createSampleData(in viewContext: NSManagedObjectContext) {
//
//        // categories:
//        let category1 = Category(context: viewContext)
//        category1.name = "Fruits"
//        category1.id = UUID()
//
//        let category2 = Category(context: viewContext)
//        category2.name = "Vegetables"
//        category2.id = UUID()
//
//        let category3 = Category(context: viewContext)
//        category3.name = "Dairy"
//        category3.id = UUID()
//
//        // products:
//        let product1 = Product(context: viewContext)
//            product1.name = "Apple"
//            product1.price = 2.99
//            product1.count = 25
//            product1.productDescription = "A fresh and juicy apple."
//            product1.id = UUID()
//            product1.category = category1
//
//            let product2 = Product(context: viewContext)
//            product2.name = "Banana"
//            product2.price = 4.50
//            product2.count = 35
//            product2.productDescription = "A ripe yellow banana."
//            product2.id = UUID()
//            product2.category = category1
//
//            let product3 = Product(context: viewContext)
//            product3.name = "Carrot"
//            product3.price = 0.99
//            product3.count = 20
//            product3.productDescription = "A crunchy orange carrot."
//            product3.id = UUID()
//            product3.category = category2
//
//            let product4 = Product(context: viewContext)
//            product4.name = "Milk"
//            product4.price = 6.50
//            product4.count = 19
//            product4.productDescription = "A bottle of fresh milk."
//            product4.id = UUID()
//            product4.category = category3
//
//
//        do {
//            try viewContext.save()
//        } catch {
//            let nsError = error as NSError
//            fatalError("error: \(nsError), \(nsError.userInfo)")
//        }
//    }
    

    func clearDatabase() {
        let viewContext = container.viewContext
        
        let categoryFetchRequest: NSFetchRequest<NSFetchRequestResult> = Category.fetchRequest()
        let productFetchRequest: NSFetchRequest<NSFetchRequestResult> = Product.fetchRequest()
        let orderFetchRequest: NSFetchRequest<NSFetchRequestResult> = Order.fetchRequest()
        let orderProductFetchRequest: NSFetchRequest<NSFetchRequestResult> = OrderProduct.fetchRequest()
        
        let batchDeleteRequestCategory = NSBatchDeleteRequest(fetchRequest: categoryFetchRequest)
        let batchDeleteRequestProduct = NSBatchDeleteRequest(fetchRequest: productFetchRequest)
        let batchDeleteRequestOrder = NSBatchDeleteRequest(fetchRequest: orderFetchRequest)
        let batchDeleteRequestOrderProduct = NSBatchDeleteRequest(fetchRequest: orderProductFetchRequest)
        
        
        
        do {
            
            try viewContext.execute(batchDeleteRequestCategory)
            try viewContext.execute(batchDeleteRequestProduct)
            try viewContext.execute(batchDeleteRequestOrder)
            try viewContext.execute(batchDeleteRequestOrderProduct)
            
            
            viewContext.refreshAllObjects()
            
            try viewContext.save()
  

    
            print("DB cleared!")
        } catch {
            let nsError = error as NSError
            print("Failed delete DB: \(nsError), \(nsError.userInfo)")
        }
    }
}

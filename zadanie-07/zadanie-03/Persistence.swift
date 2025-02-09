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
    
    public func initializeData() {
        Task {
            await fetchDataFromServer()
        }
    }
    
    public func fetchDataFromServer() async {
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


    public func fetchCategories() async -> [CategoryDTO]? {
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

    public func fetchProducts() async -> [ProductDTO]? {
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
    
    public func fetchOrders() async -> [OrderDTO]? {
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


    public func saveCategories(_ categories: [CategoryDTO], in context: NSManagedObjectContext) async {
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

    public func saveProducts(_ products: [ProductDTO], in context: NSManagedObjectContext) async {
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
    
    
    public func saveOrders(_ orders: [OrderDTO], in context: NSManagedObjectContext) async {
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


    

    public func clearDatabase() {
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

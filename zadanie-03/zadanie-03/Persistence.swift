import CoreData

struct PersistenceController {
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
        loadSampleData()
    }
    
    private func loadSampleData() {
        let viewContext = container.viewContext


        let fetchRequest: NSFetchRequest<Category> = Category.fetchRequest()
        do {
            let categories = try viewContext.fetch(fetchRequest)
            
            if categories.isEmpty {
                createSampleData(in: viewContext)
            }
        } catch {
            let nsError = error as NSError
            fatalError("Fetch error: \(nsError), \(nsError.userInfo)")
        }
    }
    
    private func createSampleData(in viewContext: NSManagedObjectContext) {

        // categories:
        let category1 = Category(context: viewContext)
        category1.name = "Fruits"
        category1.id = UUID()

        let category2 = Category(context: viewContext)
        category2.name = "Vegetables"
        category2.id = UUID()

        let category3 = Category(context: viewContext)
        category3.name = "Dairy"
        category3.id = UUID()

        // products:
        let product1 = Product(context: viewContext)
            product1.name = "Apple"
            product1.price = 2.99
            product1.count = 25
            product1.productDescription = "A fresh and juicy apple."
            product1.id = UUID()
            product1.category = category1

            let product2 = Product(context: viewContext)
            product2.name = "Banana"
            product2.price = 4.50
            product2.count = 35
            product2.productDescription = "A ripe yellow banana."
            product2.id = UUID()
            product2.category = category1

            let product3 = Product(context: viewContext)
            product3.name = "Carrot"
            product3.price = 0.99
            product3.count = 20
            product3.productDescription = "A crunchy orange carrot."
            product3.id = UUID()
            product3.category = category2

            let product4 = Product(context: viewContext)
            product4.name = "Milk"
            product4.price = 6.50
            product4.count = 19
            product4.productDescription = "A bottle of fresh milk."
            product4.id = UUID()
            product4.category = category3


        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("error: \(nsError), \(nsError.userInfo)")
        }
    }
    
    
    func clearDatabase() {
            let viewContext = container.viewContext
            
            let categoryFetchRequest: NSFetchRequest<NSFetchRequestResult> = Category.fetchRequest()
            let productFetchRequest: NSFetchRequest<NSFetchRequestResult> = Product.fetchRequest()
            
            let batchDeleteRequestCategory = NSBatchDeleteRequest(fetchRequest: categoryFetchRequest)
            let batchDeleteRequestProduct = NSBatchDeleteRequest(fetchRequest: productFetchRequest)
            
            do {
                
                try viewContext.execute(batchDeleteRequestCategory)
                try viewContext.execute(batchDeleteRequestProduct)
                
                try viewContext.save()
                print("DB cleared!")
            } catch {
                let nsError = error as NSError
                print("Failed delete DB: \(nsError), \(nsError.userInfo)")
            }
        }
}

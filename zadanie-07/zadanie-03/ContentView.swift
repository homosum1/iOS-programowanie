import SwiftUI

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var cartManager = CartManager()

    // Fetch all categories
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Category.name, ascending: true)],
        animation: .default
    )
    private var categories: FetchedResults<Category>

    var body: some View {
        TabView {
            NavigationView {
                List {
                    // Display categories
                    ForEach(categories) { category in
                        NavigationLink(destination: ProductListView(category: category)) {
                            Text(category.name!)
                                .font(.headline)
                        }
                    }
                }
                .navigationTitle("Categories")
            }
            .tabItem {
                Label("Categories", systemImage: "list.dash")
            }
            CartView()
                .environmentObject(cartManager)
                .tabItem {
                    Label("Cart", systemImage: "cart")
                }
                NavigationView {
                    OrderView()
                }
                .tabItem {
                    Label("Orders", systemImage: "dollarsign.circle")
                }
        }
        .environmentObject(cartManager)
    }
}

struct ProductListView: View {
    let category: Category
    
    @Environment(\.managedObjectContext) private var viewContext
//    @EnvironmentObject var persistenceController: PersistenceController

    @State private var addProdActive = false

    var body: some View {
        List {
            let products = category.products as? Set<Product> ?? Set<Product>()
            ForEach(Array(products)) { product in
                NavigationLink(destination: ProductView(product: product)) {
                    HStack {
                        Text(product.name!)
                        Spacer()
                        Text("\(product.price, specifier: "%.2f")zł")
                            .foregroundColor(.gray)
                    }
                }
            }
        }
        .navigationTitle(category.name ?? "Products")
        .toolbar {
                  ToolbarItem(placement: .navigationBarTrailing) {
                      Button(action: {
                          addProdActive = true
                      }) {
                          Image(systemName: "plus")
                      }
                  }
              }
              .sheet(isPresented: $addProdActive) {
                  AddProductView(category: category)
                      .environment(\.managedObjectContext, viewContext)
//                      .environmentObject(persistenceController)
              }
    }
}

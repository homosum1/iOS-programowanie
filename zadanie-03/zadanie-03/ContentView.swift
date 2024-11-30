import SwiftUI

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var cartManager = CartManager()

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Category.name, ascending: true)],
        animation: .default
    )
    private var categories: FetchedResults<Category>

    var body: some View {
        TabView {
            NavigationView {
                List {
                    ForEach(categories) { category in
                        Section(header: Text(category.name!)) {
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
                    }
                }
                .navigationTitle("Available Products")
            }
            .tabItem {
                Label("Products", systemImage: "list.dash")
            }

            CartView()
                .environmentObject(cartManager)
                .tabItem {
                    Label("Cart", systemImage: "cart")
                }
        }
        .environmentObject(cartManager)
    }
}

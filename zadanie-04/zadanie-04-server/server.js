const express = require('express');
const bodyParser = require('body-parser');
const app = express();
const port = 3000;

app.use(bodyParser.json());

app.use((req, res, next) => {
  console.log(`${req.method} ${req.url}`);
  if (req.method === 'POST' || req.method === 'PUT') {
      console.log('Request body:', req.body);
  }
  next(); 
});

let categories = [
    {
        id: 1,
        name: "Fruits"
    },
    {
        id: 2,
        name: "Vegetables",
    },
    {
        id: 3,
        name: "Dairy"
    }
];

let products = [
    {
      id: 1,
      name: "Apple",
      price: 2.99,
      count: 25,
      productDescription: "A fresh and juicy apple.",
      category: "Fruits",
    },
    {
      id: 2,
      name: "Banana",
      price: 4.50,
      count: 35,
      productDescription: "A ripe yellow banana.",
      category: "Fruits",
    },
    {
      id: 3,
      name: "Carrot",
      price: 0.99,
      count: 20,
      productDescription: "A crunchy orange carrot.",
      category: "Vegetables",
    },
    {
      id: 4,
      name: "Milk",
      price: 6.50,
      count: 19,
      productDescription: "A bottle of fresh milk.",
      category: "Dairy",
    },
];


let orders = [
    {
        id: 1,
        customerName: "User 123",
        street: "Kołatkowa 24",
        city: "Krakow",
        postcode: "37-389",
        date: "2024-12-13",
        totalPrice: 34.56,
        products: [
            { orderId: 1, quantity: 2, name: "Banana" },
            { orderId: 3, quantity: 3, name: "Milk" }
        ]
    },
    {
        id: 2,
        customerName: "User 456",
        street: "Debowa 31",
        city: "Warsaw",
        postcode: "00-123",
        date: "2024-12-12",
        totalPrice: 26.50,
        products: [
            { orderId: 2, quantity: 5, name: "Banana" },
            { orderId: 4, quantity: 1, name: "Fruits" }
        ]
    },
    {
        id: 3,
        customerName: "User 789",
        street: "Zakrecona 88",
        city: "Gdansk",
        postcode: "80-001",
        date: "2024-12-11",
        totalPrice: 9.51,
        products: [
            { orderId: 1, quantity: 1, name: "Apple" },
            { orderId: 3, quantity: 1, name: "Carrot" }
        ]
    }
];



app.get('/', (req, res) => {
  res.send('Express server is running!');
});

app.get('/products', (req, res) => {
    console.log(products);
    res.json(products);
});

app.get('/categories', (req, res) => {
    res.json(categories);
});

app.get('/orders', (req, res) => {
    res.json(orders);
});

app.post('/products', (req, res) => {
    const { name, price, count, productDescription, category } = req.body;
  
    if (!name || !price || !count || !productDescription || !category) {
      return res.status(400).json({ error: "Some data is missing" });
    }
  
    const newId = products.length > 0 ? products[products.length - 1].id + 1 : 1;
  
    const newProduct = {
      id: newId,
      name,
      price,
      count,
      productDescription,
      category,
    };
  
    products.push(newProduct);
    res.status(201).json(newProduct);
});


app.listen(port, () => {
  console.log(`Server is running on http://localhost:${port}`);
});

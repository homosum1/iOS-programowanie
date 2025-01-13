const express = require('express');
const bodyParser = require('body-parser');
const app = express();
const port = 3000;

const stripe = require('stripe')('sk_test_51JUTphB7J5QbH0XnfYm2jTNFxagLsDJtHs4NNJYmTohQG5fiFscOwDV8MV47tTLTCUBwdTwtNV44SjkiaIz17k6D00xZiX4MR6');


app.use(bodyParser.json());

app.use((req, res, next) => {
  console.log(`${req.method} ${req.url}`);
  if (req.method === 'POST' || req.method === 'PUT') {
      console.log('Request body:', req.body);
  }
  next(); 
});

// Replace this endpoint secret with your endpoint's unique secret
// If you are testing with the CLI, find the secret by running 'stripe listen'
// If you are using an endpoint defined with the API or dashboard, look in your webhook settings
// at https://dashboard.stripe.com/webhooks
const endpointSecret = 'whsec_...';


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


app.get('/', (req, res) => {
  res.send('Express server is running!');
});

app.get('/products', (req, res) => {
    console.log(products);
    res.json(products);
});

app.post('/update-stock', async (req, res) => {
    const { productId } = req.body;
  
    if(!productId) {
        console.log('Data not passed');
        res.status(400).json({ error: 'Data not passed' });
    }

    const product = products.find(p => p.id === productId);
    if (!product) {
      console.log('Product not found');
      return res.status(400).json({ error: 'Product not found' });
    }
  
    if (product.count > 0) {
      product.count -= 1;
      console.log(`Product: ${product.name} purchased, stock updated. Now has: ${product.count} left.`);
      res.json({ message: 'stock updated', stock: product.count });
    } else {
      console.log(`Stock is already zero for: ${product.name}`);
      res.status(400).json({ error: 'Out of stock' });
    }
});

app.post('/payment-sheet', async (req, res) => {


    console.log(req.body.productId);

    // additional product and user data handling:
    const { productId } = req.body;

    if(!productId) {
        console.log('Data not passed');
        res.status(400).json({ error: 'Data not passed' });
    }

    const product = products.find(p => p.id === productId);
    if (!product) {
        console.log('Product not found');
        res.status(400).json({ error: 'Product not found' });
    }

    const customer = await stripe.customers.create();

    const ephemeralKey = await stripe.ephemeralKeys.create(
      { customer: customer.id },
      { apiVersion: '2020-08-27' }
    );
    

    const adjustedPrice = Math.round(product.price * 100);

    const paymentIntent = await stripe.paymentIntents.create({
      amount: adjustedPrice, 
      currency: 'pln',
      customer: customer.id,
      automatic_payment_methods: { enabled: true },
    });

    console.log(paymentIntent);
    
  
    res.json({
      paymentIntent: paymentIntent.client_secret,
      ephemeralKey: ephemeralKey.secret,
      customer: customer.id,
      publishableKey: 'pk_test_51JUTphB7J5QbH0XnVmU9NJhzv1SvnHTDMJijldLAveeydkBbkiLbpbIGVxiVH1sMxPIOU5vOZLcwr8Ar16ubJNdk00nbESBo2X',
      amount: paymentIntent.amount, 
      currency: paymentIntent.currency,
      productName: product.name,  
      productPrice: adjustedPrice  
    });
});





// app.post('/webhook', express.raw({type: 'application/json'}), (request, response) => {
//   let event = request.body;
//   // Only verify the event if you have an endpoint secret defined.
//   // Otherwise use the basic event deserialized with JSON.parse
//   if (endpointSecret) {
//     // Get the signature sent by Stripe
//     const signature = request.headers['stripe-signature'];
//     try {
//       event = stripe.webhooks.constructEvent(
//         request.body,
//         signature,
//         endpointSecret
//       );
//     } catch (err) {
//       console.log(`⚠️  Webhook signature verification failed.`, err.message);
//       return response.sendStatus(400);
//     }
//   }

//   // Handle the event
//   switch (event.type) {
//     case 'payment_intent.succeeded':
//       const paymentIntent = event.data.object;
//       console.log(`PaymentIntent for ${paymentIntent.amount} was successful!`);
//       // Then define and call a method to handle the successful payment intent.
//       // handlePaymentIntentSucceeded(paymentIntent);
//       break;
//     case 'payment_method.attached':
//       const paymentMethod = event.data.object;
//       // Then define and call a method to handle the successful attachment of a PaymentMethod.
//       // handlePaymentMethodAttached(paymentMethod);
//       break;
//     default:
//       // Unexpected event type
//       console.log(`Unhandled event type ${event.type}.`);
//   }

//   // Return a 200 response to acknowledge receipt of the event
//   response.send();
// });

app.listen(port, () => {
  console.log(`Server is running on http://localhost:${port}`);
});

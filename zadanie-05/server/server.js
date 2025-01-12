import express from 'express';
import bodyParser from 'body-parser';
import jwt from 'jsonwebtoken';
import morgan from 'morgan';
import axios from 'axios';
import querystring from 'querystring';

const JWT_SECRET = 'dummydumdum';
const PORT = 3000;

const app = express();

app.use(bodyParser.json());
app.use(morgan("dev"));

const clientId = process.env.GOOGLE_CLIENT_ID; 
const clientSecret = process.env.GOOGLE_CLIENT_SECRET;
const githubClientID = process.env.GITHUB_CLIENT_ID; 
const githubClientSecret = process.env.GITHUB_CLIENT_SECRET;

const redirectUri = 'http://localhost:3000/callback';
const redirectGithubUri = 'http://localhost:3000/github-callback';

const users = [
    { name: "test", email: "test@g.com", password: "123" },
    { name: "test", email: "Test@g.com", password: "123" }
];


app.post('/signup', (req, res) => {
    const { name, email, password } = req.body;


    if (!name || !email || !password) {
        return res.status(400).json({ error: 'Missing request fields' });
    }


    const existingUser = users.find(user => user.email === email);

    if (existingUser) {
        return res.status(400).json({ error: 'already in db' });
    }


    const newUser = { name, email, password };
    users.push(newUser);


    res.status(200).json({ message: 'successful signup', user: newUser });
});


app.post('/login', (req, res) => {
    const { email, password } = req.body;

    console.log(email);
    console.log(password);

    if (!email || !password) {
        return res.status(400).json({ error: 'Missing request fields' });
    }

    const user = users.find(user => user.email === email);

    if (!user) {
        return res.status(404).json({ error: 'user not found' });
    }

    if (user.password !== password) {
        return res.status(404).json({ error: 'invalid data' });
    }

    const token = jwt.sign(
        { email: user.email, name: user.name }, 
        JWT_SECRET, 
        { expiresIn: '30m' } 
    );

    res.status(200).json({ success: true, token });
});

app.get('/userPanel', (req, res) => {
    const authHeader = req.headers.authorization;

    if (!authHeader || !authHeader.startsWith('Bearer ')) {
        return res.status(401).json({ error: 'Invalid auth header' });
    }

    const token = authHeader.split(' ')[1];


    jwt.verify(token, JWT_SECRET, (err, decoded) => {
        if (err) {
            return res.status(401).json({ error: 'Invalid token' });
        }

        res.status(200).json({ message: 'Secured user data'});
    });
});


// for debugging:
app.get('/users', (req, res) => {
    res.json(users);
});

app.get('/callback', async (req, res) => {
    const code = req.query.code;

    if (!code) {
        console.log('Brak kodu autoryzacji');
        return res.status(400).send()
    }

    try {
        const response = await axios.post('https://oauth2.googleapis.com/token', querystring.stringify({
            code: code,
            client_id: clientId,
            client_secret: clientSecret,
            redirect_uri: redirectUri,
            grant_type: 'authorization_code'
        }));

        const { access_token } = response.data;

  
        console.log('Access token:', access_token);

        res.status(200).send();

    } catch (error) {
        console.log('token error', error);
        res.status(500).send();
    }
});

app.get('/github-callback', async (req, res) => {
    const code = req.query.code;

    if (!code) {
        console.log('Brak kodu autoryzacji');
        return res.status(400).send()
    }

    try {
       
        const response = await axios.post(
            'https://github.com/login/oauth/access_token',
            querystring.stringify({
                client_id: githubClientID,
                client_secret: githubClientSecret,
                code: code,
                redirect_uri: redirectGithubUri
            }),
            {
                headers: {
                    Accept: 'application/json'
                }
            }
        );

        const { access_token } = response.data;

        if (!access_token) {
            return res.status(400).send();
        }

        console.log('GitHub token:', access_token);

        res.status(200).send();
    } catch (error) {
        console.log('Error github token:', error.message);
        res.status(500).send();
    }
});



app.listen(PORT, () => {
    console.log(`Server running on: ${PORT}`);
});

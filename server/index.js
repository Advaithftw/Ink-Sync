require('dotenv').config();
const express = require('express');
const mongoose = require('mongoose');
const PORT = process.env.PORT || 3001;

const app = express();
const authRouter = require('./Routes/auth');

mongoose.connect(process.env.MONGO_URI, {
    useNewUrlParser: true,
    useUnifiedTopology: true,
}).then(() => {
    console.log('Connected to MongoDB');
}).catch(err => {
    console.error('MongoDB connection error:', err);
});

app.use(express.json());
app.use(authRouter);

app.listen(PORT, "0.0.0.0", () => {
    console.log(`Server is running on port ${PORT}`);
});

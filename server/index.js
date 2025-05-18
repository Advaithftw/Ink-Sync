require('dotenv').config();
const express = require('express');
const mongoose = require('mongoose');
const PORT = process.env.PORT || 3001;
const cors = require('cors');
const documentRouter = require('./Routes/document');
const http = require('http');
const Document = require('./models/document');

const app = express();
const authRouter = require('./Routes/auth');

const server = http.createServer(app);
const io = require('socket.io')(server, {
    cors: {
        origin: "*",
        methods: ["GET", "POST"]
    }
});

app.use(cors());
app.use(express.json());
app.use(authRouter);
app.use(documentRouter);

// MongoDB connection
mongoose.connect(process.env.MONGO_URI, {
    useNewUrlParser: true,
    useUnifiedTopology: true,
}).then(() => {
    console.log('Connected to MongoDB');
}).catch(err => {
    console.error('MongoDB connection error:', err);
});


io.on('connection', (socket) => {
    console.log(`🔌 New socket connected: ${socket.id}`);

    socket.on('join', (documentId) => {
        socket.join(documentId);
        console.log(`Socket ${socket.id} joined document room: ${documentId}`);
    });

    socket.on('typing', (data) => {
        console.log(`Typing event from ${socket.id} in room ${data.delta}:`, data.content);
        socket.broadcast.to(data.room).emit('changes', data);
    });

    socket.on('disconnect', () => {
        console.log(`Socket disconnected: ${socket.id}`);
    });
    socket.on('save', (data) => {
        saveData(data); 
    
    });
});

const saveData = async(data) => {
    let document = await Document.findById(data.room);
    document.content = data.delta;
    document = await document.save();
}


server.listen(PORT, "0.0.0.0", () => {
    console.log(`Server is running on port ${PORT}`);
});

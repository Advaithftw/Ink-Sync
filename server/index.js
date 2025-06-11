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
const meetingRoute = require('./Routes/meetings');

const server = http.createServer(app);
const io = require('socket.io')(server, {
    cors: {
        origin: "*",
        methods: ["GET", "POST"]
    }
});

app.use(cors({
  origin: [
    'http://localhost:3000', // still keep for local dev
    'https://inksync-dzeqj2c17-advaith-ss-projects.vercel.app' // new deployed frontend
  ],
  credentials: true
}));

app.use(express.json());
app.use(authRouter);
app.use(documentRouter);
app.use('/api/meeting', meetingRoute);

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
   
socket.on('join-meeting', ({ roomId, userId }) => {
    socket.join(roomId);
    socket.to(roomId).emit('user-joined', userId);
    console.log(`User ${userId} joined meeting room ${roomId}`);
});

socket.on('signal', ({ roomId, signal, userId }) => {
    socket.to(roomId).emit('receive-signal', { signal, userId });
});

socket.on('disconnect-meeting', ({ roomId, userId }) => {
    socket.to(roomId).emit('user-left', userId);
    console.log(`User ${userId} left room ${roomId}`);
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

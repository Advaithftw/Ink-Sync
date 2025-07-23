// Load environment variables
try {
    require('dotenv').config();
} catch (error) {
    console.log('dotenv not available, using system environment variables');
}
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
  origin: function (origin, callback) {
    // Allow requests with no origin (mobile apps, curl, etc.)
    if (!origin) return callback(null, true);
    
    const allowedOrigins = [
  'http://localhost:3000',
  'http://192.168.0.102:3000', // add this
  'https://inksync-dzeqj2c17-advaith-ss-projects.vercel.app',
  'https://ink-sync-production.up.railway.app',
  /^https:\/\/.*\.vercel\.app$/,
  /^https:\/\/.*\.railway\.app$/,
];

    
    const isAllowed = allowedOrigins.some(allowedOrigin => {
      if (typeof allowedOrigin === 'string') {
        return origin === allowedOrigin;
      }
      return allowedOrigin.test(origin);
    });
    
    callback(null, isAllowed);
  },
  credentials: true
}));

app.use(express.json());
app.use(authRouter);
app.use(documentRouter);
app.use('/api/meeting', meetingRoute);

// Debug environment variables
console.log('Environment check:');
console.log('NODE_ENV:', process.env.NODE_ENV);
console.log('MONGO_URI exists:', !!process.env.MONGO_URI);
console.log('PORT:', process.env.PORT);

// MongoDB connection
const mongoUri = process.env.MONGO_URI;
if (!mongoUri) {
    console.error('MONGO_URI environment variable is not set!');
    process.exit(1);
}

mongoose.connect(mongoUri, {
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

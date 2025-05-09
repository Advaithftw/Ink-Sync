const express = require('express');
const authRouter = express.Router();
const User = require('../models/user');

authRouter.post('/api/signup', async (req, res) => {
    try{
        const { name,email,profilePic } = req.body;
        let user = await User.findOne({ email :email });
        if(user){
            return res.status(400).json({ error: 'User already exists' });
        }
        user = new User({
            name,
            email,
            profilePic
        });
        user = await user.save();
        res.status(201).json({ message: 'User created successfully', user });
    } catch (e)
    {
        console.error(e);
        res.status(500).json({ error: 'Internal server error' });
    }

});

module.exports = authRouter;

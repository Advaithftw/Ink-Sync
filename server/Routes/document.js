const express = require('express');
const Document = require('../models/document');
const documentrouter = express.Router();
const auth = require('../middlewares/auth');

documentrouter.post('/doc/create', auth, async (req, res) => {
    try{
        const {createdAt} = req.body;
        let document = new Document({
            uid: req.user,
            title: 'untitled Document',
            createdAt,
        });

        document = await document.save();
        res.json(document);


    }
    catch(e)
    {
        console.log(e);
        res.status(500).send({error: 'Internal server error'});
    }
});

documentrouter.get('/docs/me', auth, async (req, res) => {
    try{
        let documents = await Document.find({uid: req.user});
        res.json(documents);
    }
    catch(e)
    {
        console.log(e);
        res.status(500).send({error: e.Document});
    }
});


documentrouter.post('/doc/title', auth, async (req, res) => {
    try{
        const {id, title } = req.body;
        const document = await Document.findByIdAndUpdate(id, {title});


        res.json(document);


    }
    catch(e)
    {
        console.log(e);
        res.status(500).send({error: 'Internal server error'});
    }
});

documentrouter.get('/docs/:id', auth, async (req, res) => {
    try{
        let document = await Document.findById(req.params.id);
        res.json(document);
    }
    catch(e)
    {
        console.log(e);
        res.status(500).send({error: e.Document});
    }
});



module.exports = documentrouter;
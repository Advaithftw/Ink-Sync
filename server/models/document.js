const mongoose = require('mongoose');

const documentSchema =  mongoose.Schema({
    uid: {
        type: String,
        required: true
    },
    createdAt: {
        type: Date,
        default: Date.now
    },
    title: {
        type: String,
        required: true,
        trim : true
    },
    content: {
        type: Array,
        default: [],

    }

});

const Document = mongoose.model('Document', documentSchema);
module.exports = Document;





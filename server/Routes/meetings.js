const express = require('express');
const { v4: uuidv4 } = require('uuid');
const Meeting = require('../models/meeting');
const auth = require('../middlewares/auth');
const router = express.Router();

router.post('/create', auth, async (req, res) => {
  const { documentId } = req.body;
  const meetingId = uuidv4();

  try {
    const meeting = new Meeting({
      meetingId,
      documentId,
      host: req.user,
    });

    await meeting.save();
    res.status(200).json({ meetingId });
  } catch (e) {
    res.status(500).json({ error: 'Failed to create meeting' });
  }
});

module.exports = router;

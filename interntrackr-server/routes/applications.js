const express = require('express');
const router = express.Router();
const auth = require('../middleware/auth');
const Application = require('../models/Application');

// Get all applications for logged-in user
router.get('/', auth, async (req, res) => {
  try {
    const apps = await Application.find({ user: req.user.id }).sort({ createdAt: -1 });
    res.json(apps);
  } catch (err) {
    res.status(500).send('Server error');
  }
});

// Create application
router.post('/', auth, async (req, res) => {
  try {
    const app = new Application({ ...req.body, user: req.user.id });
    await app.save();
    res.json(app);
  } catch (err) {
    res.status(500).send('Server error');
  }
});

// Update application (move stage or edit)
router.put('/:id', auth, async (req, res) => {
  try {
    const app = await Application.findOneAndUpdate(
      { _id: req.params.id, user: req.user.id },
      req.body,
      { new: true }
    );
    if (!app) return res.status(404).json({ msg: 'Not found' });
    res.json(app);
  } catch (err) {
    res.status(500).send('Server error');
  }
});

// Delete application
router.delete('/:id', auth, async (req, res) => {
  try {
    await Application.findOneAndDelete({ _id: req.params.id, user: req.user.id });
    res.json({ msg: 'Deleted' });
  } catch (err) {
    res.status(500).send('Server error');
  }
});

module.exports = router;
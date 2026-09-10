const express = require('express');
const router = express.Router();
const auth = require('../middleware/auth');
const { getFirestore } = require('firebase-admin/firestore');

const db = getFirestore();

// Get all applications
router.get('/', auth, async (req, res) => {
  try {
    const snapshot = await db.collection('applications').get();
    if (snapshot.empty) {
      return res.json([]);
    }
    const apps = snapshot.docs.map(doc => ({
      id: doc.id,
      ...doc.data()
    }));
    res.json(apps);
  } catch (err) {
    console.error("Error fetching applications:", err);
    res.status(500).send('Server error');
  }
});

// Create application
router.post('/', auth, async (req, res) => {
  try {
    const { company, role, status, location, link, deadline, notes, lat, lng } = req.body;
    const docRef = await db.collection('applications').add({
      company,
      role: role || '',
      status: status || 'Wishlist',
      location: location || '',
      link: link || '',
      deadline: deadline || '',
      notes: notes || '',
      lat: lat || null,
      lng: lng || null,
      user: req.user.id,
      createdAt: new Date().toISOString()
    });

    const newDoc = await docRef.get();
    res.json({ id: newDoc.id, ...newDoc.data() });
  } catch (err) {
    console.error("Error creating application:", err);
    res.status(500).send('Server error');
  }
});

// Update application (move stage or edit)
router.put('/:id', auth, async (req, res) => {
  try {
    const { id } = req.params;
    const appRef = db.collection('applications').doc(id);
    const doc = await appRef.get();

    if (!doc.exists) {
      return res.status(404).json({ msg: 'Not found' });
    }

    await appRef.update(req.body);
    const updatedDoc = await appRef.get();
    
    res.json({ id: updatedDoc.id, ...updatedDoc.data() });
  } catch (err) {
    console.error("Error updating application:", err);
    res.status(500).send('Server error');
  }
});

// Delete application
router.delete('/:id', auth, async (req, res) => {
  try {
    const { id } = req.params;
    const appRef = db.collection('applications').doc(id);
    const doc = await appRef.get();

    if (!doc.exists) {
      return res.status(404).json({ msg: 'Not found' });
    }

    await appRef.delete();
    res.json({ msg: 'Deleted' });
  } catch (err) {
    console.error("Error deleting application:", err);
    res.status(500).send('Server error');
  }
});

module.exports = router;
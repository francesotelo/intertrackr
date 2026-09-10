require('dotenv').config();
const express = require('express');
const cors = express ? require('cors') : null; // Enables cross-origin requests
const { initializeApp, cert } = require('firebase-admin/app');
const { getFirestore } = require('firebase-admin/firestore');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');

// 1. Initialize Express
const app = express();
app.use(cors()); // CRITICAL: Fixes the CORS block between your frontend and backend on Vercel
app.use(express.json());

// 2. Initialize Firebase Admin SDK (Updated for Vercel Deployment)
let serviceAccount;
if (process.env.FIREBASE_SERVICE_ACCOUNT) {
  // If running in Vercel, use the environment variable
  serviceAccount = JSON.parse(process.env.FIREBASE_SERVICE_ACCOUNT);
} else {
  // If running locally on your laptop, use the file
  serviceAccount = require('./serviceAccountKey.json');
}

initializeApp({
  credential: cert(serviceAccount)
});
const db = getFirestore();

// --- INTERNTRACKR API ROUTES ---

// CREATE: Save a new internship application
app.post('/api/applications', async (req, res) => {
  try {
    const { company, position, status, dateApplied } = req.body;
    
    const docRef = await db.collection('applications').add({
      company,
      position,
      status,
      dateApplied,
      createdAt: new Date().toISOString()
    });

    res.status(201).json({ id: docRef.id, message: "Application tracked successfully!" });
  } catch (error) {
    console.error("Error adding document: ", error);
    res.status(500).json({ error: "Failed to save application" });
  }
});

// READ: Get all tracked applications
app.get('/api/applications', async (req, res) => {
  try {
    const snapshot = await db.collection('applications').get();
    
    if (snapshot.empty) {
      return res.status(200).json([]);
    }

    const applications = snapshot.docs.map(doc => ({
      id: doc.id,
      ...doc.data()
    }));

    res.status(200).json(applications);
  } catch (error) {
    console.error("Error fetching documents: ", error);
    res.status(500).json({ error: "Failed to fetch applications" });
  }
});

// UPDATE: Modify an existing internship application
app.put('/api/applications/:id', async (req, res) => {
  try {
    const { id } = req.params;
    const updateData = req.body;
    
    const applicationRef = db.collection('applications').doc(id);
    await applicationRef.update(updateData);
    
    res.status(200).json({ message: "Application updated successfully!" });
  } catch (error) {
    console.error("Error updating document: ", error);
    res.status(500).json({ error: "Failed to update application" });
  }
});

// DELETE: Remove a tracked application (Protected for Act 5 Proofs)
app.delete('/api/applications/:id', async (req, res) => {
  try {
    const authHeader = req.headers.authorization;
    
    // 1. Proof (a): Check if Authorization header exists
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return res.status(401).json({ error: "Access denied. No token provided." });
    }

    const token = authHeader.split(' ')[1];

    // 2. Proof (b): Verify the token (rejects fake/invalid tokens)
    try {
      const verified = jwt.verify(token, process.env.JWT_SECRET);
      req.user = verified;
    } catch (tokenErr) {
      return res.status(403).json({ error: "Invalid token." });
    }

    // 3. Proof (c): Valid caller deletes the document
    const { id } = req.params;
    await db.collection('applications').doc(id).delete();
    
    res.status(200).json({ message: "Application deleted successfully!" });
  } catch (error) {
    console.error("Error deleting document: ", error);
    res.status(500).json({ error: "Failed to delete application" });
  }
});

// --- USER AUTHENTICATION ROUTES ---

// REGISTER: Create a new user account
app.post('/api/users/register', async (req, res) => {
  try {
    const { name, email, password } = req.body;

    // 1. Check if the user already exists
    const usersRef = db.collection('users');
    const snapshot = await usersRef.where('email', '==', email).get();
    
    if (!snapshot.empty) {
      return res.status(400).json({ message: "User already exists!" });
    }

    // 2. Hash the password securely
    const salt = await bcrypt.genSalt(10);
    const hashedPassword = await bcrypt.hash(password, salt);

    // 3. Save the new user to Firestore
    const newUserRef = await usersRef.add({
      name,
      email,
      password: hashedPassword,
      createdAt: new Date().toISOString()
    });

    res.status(201).json({ id: newUserRef.id, message: "User registered successfully!" });
  } catch (error) {
    console.error("Registration error: ", error);
    res.status(500).json({ error: "Server error during registration" });
  }
});

// LOGIN: Authenticate user and issue a JWT
app.post('/api/users/login', async (req, res) => {
  try {
    const { email, password } = req.body;

    // 1. Find the user by email
    const usersRef = db.collection('users');
    const snapshot = await usersRef.where('email', '==', email).get();

    if (snapshot.empty) {
      return res.status(400).json({ message: "Invalid email or password" });
    }

    const userDoc = snapshot.docs[0];
    const user = userDoc.data();

    // 2. Compare password with hashed database password
    const isMatch = await bcrypt.compare(password, user.password);
    if (!isMatch) {
      return res.status(400).json({ message: "Invalid email or password" });
    }

    // 3. Generate JWT
    const token = jwt.sign(
      { id: userDoc.id, email: user.email }, 
      process.env.JWT_SECRET, 
      { expiresIn: '1d' }
    );

    res.status(200).json({ 
      message: "Login successful!", 
      token, 
      user: { id: userDoc.id, name: user.name, email: user.email } 
    });
  } catch (error) {
    console.error("Login error: ", error);
    res.status(500).json({ error: "Server error during login" });
  }
});

// 3. Start the Server
const PORT = process.env.PORT || 5000;
app.listen(PORT, () => {
  console.log(`Server is running on port ${PORT}`);
  console.log(`Firestore database is connected and ready!`);
});

module.exports = app;
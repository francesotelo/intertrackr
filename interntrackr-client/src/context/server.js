require('dotenv').config();
const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');

const app = express();

app.use(cors());
app.use(express.json());

app.use('/api/auth', require('./routes/auth'));
app.use('/api/applications', require('./routes/applications'));
app.use('/api/profile', require('./routes/profile'));

mongoose.connect(process.env.MONGO_URI, { family: 4 })
  .then(() => {
    console.log('MongoDB connected! 🚀');
    
    const PORT = process.env.PORT || 5000;
    app.listen(PORT, () => {
      console.log(`Server running on port ${PORT} 🏃‍♀️`);
    });
  })
  .catch((err) => {
    console.error('Database connection failed:', err);
  });
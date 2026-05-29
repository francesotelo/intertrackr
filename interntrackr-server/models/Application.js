const mongoose = require('mongoose');

const ApplicationSchema = new mongoose.Schema({
  user: { 
    type: mongoose.Schema.Types.ObjectId, 
    ref: 'User', 
    required: true 
  },
  company: { type: String, required: true },
  role: { type: String, required: true },
  location: { type: String, default: '' },
  status: { type: String, default: 'Wishlist' },
  link: { type: String, default: '' },
  appliedDate: { type: String, default: '' },
  deadline: { type: String, default: '' },
  notes: { type: String, default: '' },
  createdAt: { type: Date, default: Date.now }
});

module.exports = mongoose.model('Application', ApplicationSchema);
const mongoose = require('mongoose');

const UserSchema = new mongoose.Schema({
  name: { type: String, required: true },
  email: { type: String, required: true, unique: true },
  password: { type: String, required: true },
  course: { type: String, default: '' },
  university: { type: String, default: '' },
  yearLevel: { type: String, default: '' },
  bio: { type: String, default: '' },
  skills: { type: [String], default: [] },
  linkedIn: { type: String, default: '' },
  github: { type: String, default: '' },
  portfolio: { type: String, default: '' },
  resumeFileName: { type: String, default: '' },
  resumeUploadDate: { type: String, default: '' },
  createdAt: { type: Date, default: Date.now }
});

module.exports = mongoose.model('User', UserSchema);
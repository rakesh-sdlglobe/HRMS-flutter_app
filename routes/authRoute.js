// routes.js

const express = require('express');
const router = express.Router();
const authController = require('../controllers/authController');

// Route for handling login requests
router.post('/login', authController.login);

module.exports = router;

// routes.js

const express = require('express');
const router = express.Router();
const isAuth = require("../middleware/isAuth")
const authController = require('../controllers/authController');

// Route for handling login requests
router.post('/login', authController.login);
router.post('/getUser', isAuth, authController.getUser);


module.exports = router;

const express = require('express');
const router = express.Router();
const isAuth = require("../middleware/isAuth")
const leaveController = require('../controllers/leaveController');


// Route for handling login requests
router.post('/apply', isAuth,  leaveController.insertLeave);

module.exports = router;

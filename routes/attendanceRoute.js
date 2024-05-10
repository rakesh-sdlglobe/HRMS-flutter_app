const express = require('express');
const router = express.Router();
const isAuth = require("../middleware/isAuth")
const attendanceController = require('../controllers/attendanceController');


// Route for handling login requests
router.post('/time', isAuth,  attendanceController.insertIntime);

module.exports = router;

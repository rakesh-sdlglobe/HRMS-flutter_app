const express = require('express');
const router = express.Router();
const isAuth = require("../middleware/isAuth")
const leaveController = require('../controllers/leaveController');


// Route for handling login requests
router.post('/apply', isAuth,  leaveController.insertLeave);
router.post('/get', isAuth,  leaveController.fetchLeave);
router.post('/approveGet', isAuth, leaveController.leaveToApprove)
router.post('/approve', isAuth, leaveController.leaveApprove)


module.exports = router;

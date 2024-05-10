require('dotenv').config();
const pool = require('../utils/database');
const bcrypt = require('bcrypt');
const jwt = require("jsonwebtoken");

// Login controller
exports.login = (req, res) => { 
  const { userID ,password} = req.body;

  if (!userID) {
    return res.status(400).json({ message: 'Both userID and password are required' });
  }
 
  const sql = 'SELECT * FROM tbl_login WHERE empcode = @userID';

  pool.request()
    .input('userID', userID)
    .query(sql, (err, results) => {
      if (err) {
        console.error('Error executing query: ', err);
        return res.status(500).json({ message: 'Internal server error' });
      }
      if (results.recordset.length > 0) {
        const dbPasswordHash = results.recordset[0].pwd;
        bcrypt.compare(password, dbPasswordHash).then(() => {      
          const token = jwt.sign({userID: userID.toString()}, process.env.TOKEN_SECRET, {expiresIn: "24h"});
          res.status(200).json({token: token, userID: userID.toString()});
        }).catch((err) => {
          console.log(err);
          return res.status(500).json({ message: 'Error comparing passwords' });
        });
      } else {
        return res.status(401).json({ message: 'Invalid credentials' });
      }
    });
};

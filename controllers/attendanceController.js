require('dotenv').config();
const pool = require('../utils/database');

exports.insertIntime = (req,res) => {
  const {companyID, empcode, exactdate, intime, outtime} = req.body;
  const insertSql = 'INSERT INTO tbl_attendance_login_logout (companyid, empcode, exactdate, intime,outtime) VALUES (@companyID, @empcode, @exactdate, @intime, @outtime)';
  pool.request()
    .input('companyID', companyID)
    .input('empcode', empcode)
    .input('exactdate', exactdate)
    .input('intime', intime)
    .input('outtime', outtime)
    .query(insertSql, (insertErr, insertResult) => {
      if (insertErr) {
        console.error('Error inserting attendance record: ', insertErr);
        return res.status(500).json({ message: 'Error inserting attendance record' });
      }
      res.status(200).json({ message: 'Attendance record inserted successfully' });
    });
};

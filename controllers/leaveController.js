require('dotenv').config();
const pool = require('../utils/database');

exports.insertLeave = (req,res) => {
  const {companyID, empcode, leaveid, reason, fromdate, todate} = req.body;
  const insertSql = 'INSERT INTO tbl_leave_apply_leave (companyid, empcode, leaveid, reason, fromdate, todate) VALUES (@companyID, @empcode, @leaveid, @reason, @fromdate, @todate)';
  pool.request()
    .input('companyID', companyID)
    .input('empcode', empcode)
    .input('leaveid', leaveid)
    .input('reason', reason)
    .input('fromdate', fromdate)
    .input('todate', todate)
    .query(insertSql, (insertErr, insertResult) => {
      if (insertErr) {
        console.error('Error inserting attendance record: ', insertErr);
        return res.status(500).json({ message: 'Error inserting attendance record' });
      }
      res.status(200).json({ message: 'Attendance record inserted successfully' });
    });
};

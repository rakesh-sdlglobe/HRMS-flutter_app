require('dotenv').config();
const pool = require('../utils/database');

exports.insertLeave = (req, res) => {
  const { 
    company_id, 
    empcode, 
    leaveid, 
    leavemode, 
    reason, 
    fromdate, 
    todate, 
    half, 
    no_of_days,
    leave_adjusted,
    approvel_status,
    leave_status,
    flag,
    status,
    createddate,
    createdby,
    modifieddate,
    modifiedby,
  } = req.body;
  
  const insertSql = `
  INSERT INTO tbl_leave_apply_leave (
    company_id, 
    empcode, 
    leaveid, 
    leavemode, 
    reason, 
    fromdate, 
    todate, 
    half, 
    no_of_days,
    leave_adjusted,
    approvel_status,
    leave_status,
    flag,
    status,
    createddate,
    createdby,
    modifieddate,
    modifiedby
  ) 
  VALUES (
    @company_id, 
    @empcode, 
    @leaveid, 
    @leavemode, 
    @reason, 
    @fromdate, 
    @todate, 
    @half, 
    @no_of_days,
    @leave_adjusted,
    @approvel_status,
    @leave_status,
    @flag,
    @status,
    @createddate,
    @createdby,
    @modifieddate,
    @modifiedby
  )
  
  `;

  pool.request()
    .input('company_id', company_id)
    .input('empcode', empcode)
    .input('leaveid', leaveid)
    .input('leavemode', leavemode)
    .input('reason', reason)
    .input('fromdate', fromdate)
    .input('todate', todate)
    .input('half', half)
    .input('no_of_days',no_of_days)
    .input('leave_adjusted', leave_adjusted)
    .input('approvel_status', approvel_status)
    .input('leave_status', leave_status)
    .input('flag', flag)
    .input('status', status)
    .input('createddate', createddate)
    .input('createdby', createdby)
    .input('modifieddate', modifieddate)
    .input('modifiedby', modifiedby)
    .query(insertSql, (insertErr, insertResult) => {
      if (insertErr) {
        console.error('Error inserting leave record: ', insertErr);
        return res.status(500).json({ message: 'Error inserting leave record' });
      }
      res.status(200).json({ message: 'Leave record inserted successfully' });
    });
};

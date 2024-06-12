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

exports.fetchLeave = (req, res) => {
  const { empcode } = req.body; 

  const fetchSql = `
    SELECT leaveid, fromdate, todate, createddate, approvel_status, leave_status
    FROM tbl_leave_apply_leave
    WHERE empcode = @empcode
  `;

  pool.request()
    .input('empcode', empcode)
    .query(fetchSql, (fetchErr, fetchResult) => {
      if (fetchErr) {
        console.error('Error fetching leave records: ', fetchErr);
        return res.status(500).json({ message: 'Error fetching leave records' });
      }

      const leaveRecords = fetchResult.recordset.map(record => ({
        leaveType: record.leaveid,
        fromdate: record.fromdate,
        todate: record.todate,
        createddate: record.createddate,
        approvel_status: record.approvel_status ? 'Approved' : 'Pending',
        leave_status: record.leave_status
      }));
      res.status(200).json({ leaveRecords });
    });
};


exports.leaveToApprove =(req,res)=>{
  const { empcode } = req.body; 

  const fetchSql = `
  SELECT empcode, leaveid, fromdate, todate, createddate, approvel_status, leave_status
  FROM tbl_leave_apply_leave
  WHERE approvel_status = 0 and empcode='EIN1129' and leave_status != 3
  `;

  pool.request()
    .input('empcode', empcode)
    .query(fetchSql, (fetchErr, fetchResult) => {
      if (fetchErr) {
        console.error('Error fetching leave records: ', fetchErr);
        return res.status(500).json({ message: 'Error fetching leave records' });
      }

      const leaveRecords = fetchResult.recordset.map(record => ({
        empcode:record.empcode,
        leaveType: record.leaveid,
        leaveid:record.leaveid,
        fromdate: record.fromdate,
        todate: record.todate,
        createddate: record.createddate,
        approvel_status: record.approvel_status ? 'Approved' : 'Pending',
        leave_status:record.leave_status 
      }));
      res.status(200).json({ leaveRecords });
    });
}


exports.leaveApprove = (req, res) => {
  const { leaveid, empcode, approve } = req.body;
  const approvalStatus = approve ? 1 : 0;
  const leaveStatus = approve ? 6 : 3; 

  const updateSql = `
    UPDATE tbl_leave_apply_leave
    SET approvel_status = @approvalStatus, leave_status = @leaveStatus
    WHERE leaveid = @leaveid AND empcode = @empcode
  `;

  pool.request()
    .input('leaveid', leaveid)
    .input('empcode', empcode)
    .input('approvalStatus', approvalStatus)
    .input('leaveStatus', leaveStatus)
    .query(updateSql, (updateErr, updateResult) => {
      if (updateErr) {
        console.error('Error updating leave record: ', updateErr);
        return res.status(500).json({ message: 'Error updating leave record', error: updateErr });
      }

      res.status(200).json({ message: 'Leave record updated successfully' });
    });
};



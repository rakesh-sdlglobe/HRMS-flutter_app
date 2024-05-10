require('dotenv').config();
const jwt = require('jsonwebtoken')

module.exports = (req,res,next) =>{
   const token = req.get("Authorization").split(' ')[1]
    let decodedToken;
    try {
        decodedToken = jwt.verify(token, process.env.TOKEN_SECRET)
        req.userID = decodedToken.userID
        next()
    } catch (err) {
        console.log(err);
    }
}
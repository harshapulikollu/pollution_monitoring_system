const functions = require('firebase-functions');
const admin = require('firebase-admin');

admin.initializeApp();
var db = admin.firestore();
// // Create and Deploy Your First Cloud Functions
// // https://firebase.google.com/docs/functions/write-firebase-functions
//
// exports.helloWorld = functions.https.onRequest((request, response) => {
//  response.send("Hello from Firebase!");
// });
//start of Http request trigger. This will invoke every time when this URL called.
exports.saveSensorDataToDB = functions.https.onRequest((request, response) => {
    //Getting values from the QueryString in URL.
   const latitude = String(request.query.latitude);
   const longitude = String(request.query.longitude);
   const timestamp = String(request.query.timestamp);
   //TODO: Add rest of sensors values to resp. variables from queryString here.
    // After getting values from queryString we will create a 'data' variable with all the keys and their resp. values.
    var data = {
        'latitude': latitude,
        'longitude': longitude,
        'timestamp': timestamp,
        //TODO: Add rest of sensor data here
    };
    //After creating 'data' variable we will upload into the database.
    db.collection('sensorData').doc(latitude+'&'+longitude).collection('data').doc(timestamp).set(data).then(function() {
        //IF data enter was successful following code executes.
        console.log('successfully entered data into database.');
        response.status(200).send('Data added into database successfully!');
        return 0;
    }).catch(function (error) {
        //IF data enter was unSuccessful following code executes.
        console.log('Error occurred while adding data into database.',error);
        response.status(500).send('Error occurred while adding data into database with following error: '+error);
    });
//end of Http request.
});
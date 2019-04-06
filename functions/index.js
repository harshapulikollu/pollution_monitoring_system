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
   const latitude = parseFloat(request.query.latitude);
   const longitude = parseFloat(request.query.longitude);
   const timestamp = String(request.query.timestamp);
   const airQuality = parseFloat(request.query.airQuality);
   const lpg = parseFloat(request.query.lpg);
   const turbidity = parseFloat(request.query.turbidity);
   const ph = parseFloat(request.query.ph);
   const temperature = parseFloat(request.query.temperature);
   const humidity = parseFloat(request.query.humidity);
   const noise = parseFloat(request.query.noise);

   //TODO: Add/edit rest of sensors values to resp. variables from queryString here.
    // After getting values from queryString we will create a 'data' variable with all the keys and their resp. values.
    var data = {
        'latitude': latitude,
        'longitude': longitude,
        'timestamp': timestamp,
        'airQuality': airQuality,
        'lpg': lpg,
        'turbidity': turbidity,
        'ph': ph,
        'temperature': temperature,
        'humidity': humidity,
        'noise': noise,
        //TODO: Add/edit sensor name/values data here
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

exports.sendNotification = functions.firestore.document('sensorData/{locDoc}/data/{timestamp}').onCreate((snapshot, context) => {
   const documentDoc = snapshot.data();
   let sendNotification = false;
   let notificationBody = '';
   if(documentDoc.airQuality > 10){
       notificationBody.concat('Air pollution');
       sendNotification = true;
   }
   if(documentDoc.lpg > 10){
       notificationBody.concat('LPG ');
       sendNotification = true;
   }
   if(documentDoc.turbidity > 10){
       notificationBody.concat('turbidity quality');
       sendNotification = true;
   }
    if(documentDoc.ph > 10){
        notificationBody.concat('ph quality');
        sendNotification = true;
    }
    if(documentDoc.temperature > 10){
        notificationBody.concat('temperature ');
        sendNotification = true;
    }
    if(documentDoc.humidity > 10){
        notificationBody.concat('humidity ');
        sendNotification = true;
    }
    if(documentDoc.noise > 10){
        notificationBody.concat('noise pollution');
        sendNotification = true;
    }
    if(sendNotification){
        console.log('notification message is:'+ notificationBody);
        const payload = {
            notification : {
                title: 'Seems like pollution is high..',
                body: notificationBody
            }
        };
        admin.messaging().sendToTopic('appNotification', payload)
            .then((response) => {
                console.log('Successfully sent notification message to topic:', response);
                return response;
            }).catch((error) => {
            console.log('error sending notification message to topic:', error);
        });
    }
});
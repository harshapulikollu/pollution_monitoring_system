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
   const docID = String(latitude+'&'+longitude);

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
        'docID':docID,
        //TODO: Add/edit sensor name/values data here
    };
    //After creating 'data' variable we will upload into the database.
    db.collection('sensorData').doc(latitude+'&'+longitude).collection('data').doc(timestamp).set(data).then(function() {
        //IF data enter was successful following code executes.
        console.log('successfully entered data into database.');
        db.collection('locationMarkers').doc(docID).get().then(snapshot => {
            if(!snapshot.exists){
                db.collection('locationMarkers').doc(latitude+'&'+longitude).set({
                    'latitude': latitude,
                    'longitude': longitude,
                }).then(function () {
                    console.log('added lat and lng as marker');
                    response.status(200).send('Data added into database successfully! new marker added into DB');
                    return 0;
                }).catch(function(error){
                    console.log('error', error);
                });
            }else{
                console.log('Already marker exists');
				response.status(200).send('Data added into database successfully! and marker exists already');
            }
            return 0;
        }).catch(function (error) {
            console.log('error', error);
            response.status(500).send('Error occurred while adding data into database with following error: '+error);
        });
        // response.status(200).send('Data added into database successfully!');
        return 0;
    }).catch(function (error) {
        //IF data enter was unSuccessful following code executes.
        console.log('Error occurred while adding data into database.',error);
        // response.status(500).send('Error occurred while adding data into database with following error: '+error);
    });
//end of Http request.

});

exports.sendNotification = functions.firestore.document('sensorData/{locDoc}/data/{timestamp}').onCreate((snapshot, context) => {
   const documentDoc = snapshot.data();
   let sendNotification = false;
   let notificationBody = 'It\'s high ';
   if(documentDoc.airQuality > 10){
       notificationBody =notificationBody + ' Air pollution';
       console.log('came into airQuality');
       sendNotification = true;
   }
   if(documentDoc.lpg > 10){
       notificationBody =notificationBody + ' LPG level';
       console.log('came into LPG');
       sendNotification = true;
   }
   if(documentDoc.turbidity > 10){
       notificationBody =notificationBody + ' Turbidity level';
       console.log('came into turbidity');
       sendNotification = true;
   }
    if(documentDoc.ph > 10){
        notificationBody =notificationBody + ' pH level';
        console.log('came into ph');
        sendNotification = true;
    }
    if(documentDoc.temperature > 10){
        notificationBody =notificationBody + ' temperature';
        console.log('came into temp');
        sendNotification = true;
    }
    if(documentDoc.humidity > 10){
        notificationBody =notificationBody + ' humidity level';
        console.log('came into humidity');
        sendNotification = true;
    }
    if(documentDoc.noise > 10){
        notificationBody =notificationBody + ' noise pollution';
        console.log('came into noise');
        sendNotification = true;
    }
    if(sendNotification){
        console.log('came into notification sending');
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
		return 0;
    }
	return 0;
});
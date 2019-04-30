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
// exports.saveSensorDataToDB = functions.https.onRequest((request, response) => {
//     //Getting values from the QueryString in URL.
//    const latitude = parseFloat(request.query.latitude);
//    const longitude = parseFloat(request.query.longitude);
//    const timestamp = String(request.query.timestamp);
//    const airQuality = parseFloat(request.query.airQuality);
//    const lpg = parseFloat(request.query.lpg);
//    const turbidity = parseFloat(request.query.turbidity);
//    const ph = parseFloat(request.query.ph);
//    const temperature = parseFloat(request.query.temperature);
//    const humidity = parseFloat(request.query.humidity);
//    const noise = parseFloat(request.query.noise);
//    const docID = String(latitude+'&'+longitude);
//
//    //TODO: Add/edit rest of sensors values to resp. variables from queryString here.
//     // After getting values from queryString we will create a 'data' variable with all the keys and their resp. values.
//     var data = {
//         'latitude': latitude,
//         'longitude': longitude,
//         'timestamp': timestamp,
//         'airQuality': airQuality,
//         'lpg': lpg,
//         'turbidity': turbidity,
//         'ph': ph,
//         'temperature': temperature,
//         'humidity': humidity,
//         'noise': noise,
//         'docID':docID,
//         //TODO: Add/edit sensor name/values data here
//     };
//     //After creating 'data' variable we will upload into the database.
//     db.collection('sensorData').doc(latitude+'&'+longitude).collection('data').doc(timestamp).set(data).then(function() {
//         //IF data enter was successful following code executes.
//         console.log('successfully entered data into database. docId: '+docID+' timestamp: '+timestamp);
//         db.collection('locationMarkers').doc(docID).get().then(snapshot => {
//             if(!snapshot.exists){
//                 db.collection('locationMarkers').doc(latitude+'&'+longitude).set({
//                     'latitude': latitude,
//                     'longitude': longitude,
//                 }).then(function () {
//                     console.log('added lat and lng as marker. latitude: '+latitude+' longitude: '+longitude);
//                     response.status(200).send('Data added into database successfully! new marker added into DB, HttpCode: 200(success)');
//                     return 0;
//                 }).catch(function(error){
//                     console.log('error', error);
//                 });
//             }else{
//                 console.log('Already marker exists');
// 				response.status(200).send('Data added into database successfully! and marker exists already. HttpCode: 200(success)');
//             }
//             return 0;
//         }).catch(function (error) {
//             console.log('error', error);
//             response.status(500).send('Error occurred while adding data into database with following error: '+error);
//         });
//         // response.status(200).send('Data added into database successfully!');
//         return 0;
//     }).catch(function (error) {
//         //IF data enter was unSuccessful following code executes.
//         console.log('Error occurred while adding data into database.',error);
//         // response.status(500).send('Error occurred while adding data into database with following error: '+error);
//     });
// //end of Http request.
//
// });

//firebase real time database
exports.transferData = functions.database.ref('/{newSensorData}').onWrite((snapshot, cpntext) => {
    console.log('rtdb data created and triggerd');
    const timestamp = Date.now();
    const latitude = parseFloat("31.2515151");
    const longitude = parseFloat("75.7046727");
    const humidity = parseFloat(snapshot.after.val().Humidity);
    const noise = parseFloat(snapshot.after.val().Sound);
    const temperature = parseFloat(snapshot.after.val().Temperature);
    const turbidity = parseFloat(snapshot.after.val().Turbidity);
    const airQuality = parseFloat(snapshot.after.val().AirQuality);
    const lpg = parseFloat(snapshot.after.val().LpgContent);
    const docID = String(latitude+'&'+longitude);

    var data = {
        'latitude': latitude,
        'longitude': longitude,
        'timestamp': String(timestamp),
        'airQuality': airQuality,
        'lpg': lpg,
        'turbidity': turbidity,
        'temperature': temperature,
        'humidity': humidity,
        'noise': noise,
        'docID':docID,
    };
console.log('total data gathered and made into JSON '+data);

    //writing into firestore
	console.log('lat is: '+ latitude + 'lng is '+ longitude);
	console.log('timestamp is:'+timestamp);
console.log('airQuality is:'+ airQuality);
console.log('lpg is:'+lpg);
console.log('turbidity is:'+ turbidity);
console.log('temperature is: '+ temperature);
console.log('humidity is: '+humidity);
console.log('sound is: '+noise);

if(!isNaN(airQuality) && !isNaN(lpg) && !isNaN(turbidity) && !isNaN(temperature) && !isNaN(humidity) && !isNaN(noise)){
    console.log('no NAN\'s all data are values');
    db.collection('sensorData').doc(latitude+'&'+longitude).collection('data').doc(timestamp.toString()).set(data).then(function() {
        console.log('came into firestore and added data');
        db.collection('locationMarkers').doc(latitude+'&'+longitude).get().then(snapshot => {
            console.log('came into location');
            if(!snapshot.exists){
                db.collection('locationMarkers').doc(latitude+'&'+longitude).set({
                    'latitude': latitude,
                    'longitude': longitude,
                }).then(function () {
                    console.log('added lat and lng as marker. latitude: '+latitude+' longitude: '+longitude);
                    return 0;
                }).catch(function(error){
                    console.log('error', error);
                });
            } else{
                console.log('marker exists');
            }
            return 0;
        }).catch(function (error) {
            console.log('error', error);
        });
        return 0;
    }).catch(function (error) {
        console.log('error', error);
    });
}else{
    console.log('some of values are NAN so not entering into DB');
}

 return 0;
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

    if(documentDoc.temperature > 45){
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
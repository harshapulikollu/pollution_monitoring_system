import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sparkline/flutter_sparkline.dart';

class LocPollutionDetails extends StatefulWidget {
  final String selectedLocationLatitude;
  final String selectedLocationLongitude;
  LocPollutionDetails(
      this.selectedLocationLatitude, this.selectedLocationLongitude);
  @override
  _LocPollutionDetailsState createState() => _LocPollutionDetailsState();
}

class _LocPollutionDetailsState extends State<LocPollutionDetails> {
  List<double> airQuality = [];
  List<double> humidity = [];
  List<double> lpg = [];
  List<double> noise = [];
  List<double> ph = [];
  List<String> timestamp = [];
  List<double> temperature = [];
  List<double> turbidity = [];

  @override
  Widget build(BuildContext context) {
    print(
        'line 16 loc ${widget.selectedLocationLatitude}, ${widget.selectedLocationLongitude}');
    return StreamBuilder(
        stream: Firestore.instance
            .collection('sensorData')
            .document(widget.selectedLocationLatitude +
                '&' +
                widget.selectedLocationLongitude)
            .collection('data')
            .orderBy('timestamp')
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('Oops.. something went wrong.'),
            );
          }
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              print('line 25 coonection state waiting');
              return Center(
                child: CircularProgressIndicator(),
              );
            case ConnectionState.none:
              return (Text('none'));
            default:
              print('line 25 coonection state done');
              if (snapshot.hasData) {
                if (snapshot.data.documents.length > 0) {
                  print('line 33 ${snapshot.data}');
                  return buildListViewData(snapshot.data.documents);
                } else {
                  return Center(
                    child: Text('Hmm.. seems like no data for this locatiom'),
                  );
                }
              } else {
                return Center(
                  child: Text(
                      'Hmm... seems like we don\'t have data for this location'),
                );
              }
              break;
          }
        });
  }

  @override
  void initState() {
    super.initState();
  }

  Widget buildListViewData(List<DocumentSnapshot> documents) {
    airQuality.clear();
    humidity.clear();
    lpg.clear();
    noise.clear();
    ph.clear();
    temperature.clear();
    timestamp.clear();
    turbidity.clear();
    documents.forEach((docSnapshot) {
      airQuality
          .add(double.tryParse(docSnapshot.data['airQuality'].toString()));
      humidity.add(double.tryParse(docSnapshot.data['humidity'].toString()));
      lpg.add(double.tryParse(docSnapshot.data['lpg'].toString()));
      noise.add(double.tryParse(docSnapshot.data['noise'].toString()));
      ph.add(double.tryParse(docSnapshot.data['ph'].toString()));
      temperature
          .add(double.tryParse(docSnapshot.data['temperature'].toString()));
      timestamp.add(docSnapshot.data['timestamp']);
      turbidity.add(double.tryParse(docSnapshot.data['turbidity'].toString()));
    });

    return SingleChildScrollView(
        padding: EdgeInsets.all(8.0),
        child: Column(
          children: <Widget>[
            Card(
                child: Column(
              children: <Widget>[
                Stack(
                  children: <Widget>[
                    Sparkline(
                      data: temperature,
                      lineColor: Colors.orange,
                    ),
                    Sparkline(
                      data: airQuality,
                      lineColor: Colors.blue,
                    ),
                    Sparkline(
                      data: humidity,
                      lineColor: Colors.green,
                    ),
                    Sparkline(
                      data: turbidity,
                      lineColor: Colors.black,
                    ),
                    Sparkline(
                      data: ph,
                      lineColor: Colors.yellow,
                    ),
                    Sparkline(
                      data: noise,
                      lineColor: Colors.pink,
                    ),
                  ],
                ),
               Container(
                 padding: EdgeInsets.all(10.0),
                 child: Wrap(
                   spacing: 10.0,
                   crossAxisAlignment: WrapCrossAlignment.center,
                   children: <Widget>[
                     Text(
                       'AirQualiy',
                       style: TextStyle(
                         color: Colors.blue,
                       ),
                     ),
                     Text(
                       'Temperature',
                       style: TextStyle(
                         color: Colors.orange,
                       ),
                     ),
                     Text(
                       'Humidity',
                       style: TextStyle(
                         color: Colors.green,
                       ),
                     ),
                     Text(
                       'Noise',
                       style: TextStyle(
                         color: Colors.pink,
                       ),
                     ),
                     Text(
                       'pH level',
                       style: TextStyle(
                         color: Colors.yellow,
                       ),
                     ),
                     Text(
                       'Turbidity',
                       style: TextStyle(
                         color: Colors.black,
                       ),
                     ),
                   ],
                 )
               )
              ],
            )),
            ExpansionTile(
              title: Text('Air quality'),
              children: airQuality
                  .asMap()
                  .map(
                    (index, data) => MapEntry(
                          index,
                          ListTile(
                            title: Text('Air quality is:'),
                            trailing: Text(data.toString()),
                            subtitle: Text(DateTime.fromMillisecondsSinceEpoch(
                                    int.tryParse(timestamp[index].toString()) *
                                        1000)
                                .toUtc()
                                .toString()),
                          ),
                        ),
                  )
                  .values
                  .toList(),
            ),
            ExpansionTile(
                title: Text('Temperature'),
                children: temperature
                    .asMap()
                    .map(
                      (index, data) => MapEntry(
                            index,
                            ListTile(
                              title: Text('Temperature is:'),
                              trailing: Text(data.toString()),
                              subtitle: Text(
                                  DateTime.fromMillisecondsSinceEpoch(
                                          int.tryParse(
                                                  timestamp[index].toString()) *
                                              1000)
                                      .toUtc()
                                      .toString()),
                            ),
                          ),
                    )
                    .values
                    .toList()),
            ExpansionTile(
                title: Text('Humidity'),
                children: humidity
                    .asMap()
                    .map(
                      (index, data) => MapEntry(
                            index,
                            ListTile(
                              title: Text('Humidity is:'),
                              trailing: Text(data.toString()),
                              subtitle: Text(
                                  DateTime.fromMillisecondsSinceEpoch(
                                          int.tryParse(
                                                  timestamp[index].toString()) *
                                              1000)
                                      .toUtc()
                                      .toString()),
                            ),
                          ),
                    )
                    .values
                    .toList()),
            ExpansionTile(
                title: Text('Noise'),
                children: noise
                    .asMap()
                    .map(
                      (index, data) => MapEntry(
                            index,
                            ListTile(
                              title: Text('Noise is:'),
                              trailing: Text(data.toString()),
                              subtitle: Text(
                                  DateTime.fromMillisecondsSinceEpoch(
                                          int.tryParse(
                                                  timestamp[index].toString()) *
                                              1000)
                                      .toUtc()
                                      .toString()),
                            ),
                          ),
                    )
                    .values
                    .toList()),
            ExpansionTile(
                title: Text('LPG'),
                children: lpg
                    .asMap()
                    .map(
                      (index, data) => MapEntry(
                            index,
                            ListTile(
                              title: Text('LPG is:'),
                              trailing: Text(data.toString()),
                              subtitle: Text(
                                  DateTime.fromMillisecondsSinceEpoch(
                                          int.tryParse(
                                                  timestamp[index].toString()) *
                                              1000)
                                      .toUtc()
                                      .toString()),
                            ),
                          ),
                    )
                    .values
                    .toList()),
            ExpansionTile(
                title: Text('pH level'),
                children: ph
                    .asMap()
                    .map(
                      (index, data) => MapEntry(
                            index,
                            ListTile(
                              title: Text('pH level is:'),
                              trailing: Text(data.toString()),
                              subtitle: Text(
                                  DateTime.fromMillisecondsSinceEpoch(
                                          int.tryParse(
                                                  timestamp[index].toString()) *
                                              1000)
                                      .toUtc()
                                      .toString()),
                            ),
                          ),
                    )
                    .values
                    .toList()),
            ExpansionTile(
                title: Text('Turbidity'),
                children: turbidity
                    .asMap()
                    .map(
                      (index, data) => MapEntry(
                            index,
                            ListTile(
                              title: Text('Turbidity:'),
                              trailing: Text(data.toString()),
                              subtitle: Text(
                                  DateTime.fromMillisecondsSinceEpoch(
                                          int.tryParse(
                                                  timestamp[index].toString()) *
                                              1000)
                                      .toUtc()
                                      .toString()),
                            ),
                          ),
                    )
                    .values
                    .toList()),
          ],
        ));
  }
}

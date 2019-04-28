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
  List<String> timestamp = [];
  List<double> temperature = [];
  List<double> turbidity = [];

  //values for dorp down in graph
  static final List<String> chartDropdownItems = [ 'All','Air quality', 'Humidity', 'LPG', 'Noise','Temperature','Turbidity' ];
  static final List<String> chartTimelineDropdownItems = ['All', 'Last 1 hour', 'Last 24 hours', 'Last 7 days', 'Last 30 days'];
  String actualDropdown = chartDropdownItems[0];
  String actualTimelineDropdown = chartTimelineDropdownItems[0];

  double airQualityThreshold = 101.0;//TODO: change threshold values corresponding to the sensor.
  double humidityThreshold = 5.0;//TODO: change threshold values corresponding to the sensor.
  double lpgThreshold = 5.0;//TODO: change threshold values corresponding to the sensor.
  double noiseThreshold = 5.0;//TODO: change threshold values corresponding to the sensor.
  double temperatureThreshold = 40.0;//TODO: change threshold values corresponding to the sensor.
  double turbidityThreshold = 5.0;//TODO: change threshold values corresponding to the sensor.

  MaterialColor airQualityColor = Colors.blue;
  MaterialColor humidityColor = Colors.green;
  MaterialColor lpgColor = Colors.purple;
  MaterialColor noiseColor = Colors.red;
  MaterialColor temperatureColor = Colors.orange;
  MaterialColor turbidityColor = Colors.brown;

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
    temperature.clear();
    timestamp.clear();
    turbidity.clear();
    documents.forEach((docSnapshot) {
      airQuality.add(double.tryParse(docSnapshot.data['airQuality'].toString()));
      humidity.add(double.tryParse(docSnapshot.data['humidity'].toString()));
      lpg.add(double.tryParse(docSnapshot.data['lpg'].toString()));
      noise.add(double.tryParse(docSnapshot.data['noise'].toString()));
      temperature.add(double.tryParse(docSnapshot.data['temperature'].toString()));
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    DropdownButton
                      (
                        isDense: true,
                        value: actualDropdown,
                        onChanged: (String value) => setState(()
                        {
                          actualDropdown = value;
                          //actualChart = chartDropdownItems.indexOf(value); // Refresh the chart
                        }),
                        items: chartDropdownItems.map((String title)
                        {
                          return DropdownMenuItem
                            (
                            value: title,
                            child: Text(title, style: TextStyle(color: Colors.blue, fontWeight: FontWeight.w400, fontSize: 14.0)),
                          );
                        }).toList()
                    ),
//                    DropdownButton
//                      (
//                        isDense: true,
//                        value: actualTimelineDropdown,
//                        onChanged: (String value) => setState(()
//                        {
//                          actualTimelineDropdown = value;
//                        }),
//                        items: chartTimelineDropdownItems.map((String title)
//                        {
//                          return DropdownMenuItem
//                            (
//                            value: title,
//                            child: Text(title, style: TextStyle(color: Colors.blue, fontWeight: FontWeight.w400, fontSize: 14.0)),
//                          );
//                        }).toList()
//                    ),
                  ],
                ),
                actualDropdown == 'All' ? Stack(
                  children: <Widget>[
                    Sparkline(
                      data: temperature,//TODO: show data depending on Timeline dropDown
                      pointsMode: PointsMode.aboveThreshold,
                      pointColor: temperatureColor,
                      pointSize: 10.0,
                      threshold: temperatureThreshold,
                      lineColor: temperatureColor,
                    ),
                    Sparkline(
                      data: airQuality,//TODO: show data depending on Timeline dropDown
                      pointsMode: PointsMode.aboveThreshold,
                      pointColor: airQualityColor,
                      pointSize: 10.0,
                      threshold: airQualityThreshold,
                      lineColor: airQualityColor,
                    ),
                    Sparkline(
                      data: humidity,//TODO: show data depending on Timeline dropDown
                      pointsMode: PointsMode.aboveThreshold,
                      pointColor: humidityColor,
                      pointSize: 10.0,
                      threshold: humidityThreshold,
                      lineColor: humidityColor,
                    ),
                    Sparkline(
                      data: turbidity,//TODO: show data depending on Timeline dropDown
                      pointsMode: PointsMode.aboveThreshold,
                      pointColor: turbidityColor,
                      pointSize: 10.0,
                      threshold: turbidityThreshold,
                      lineColor: turbidityColor,
                    ),
                    Sparkline(
                      data: noise,//TODO: show data depending on Timeline dropDown
                      pointsMode: PointsMode.aboveThreshold,
                      pointColor: noiseColor,
                      pointSize: 10.0,
                      threshold: noiseThreshold,
                      lineColor: noiseColor,
                    ),
                    Sparkline(
                      data: lpg,//TODO: show data depending on Timeline dropDown
                    pointsMode: PointsMode.aboveThreshold,
                    pointColor: lpgColor,
                    pointSize: 10.0,
                    threshold: lpgThreshold,
                    lineColor: lpgColor,)
                  ],
                ) : Sparkline(
                    data: getSelectedDropDownData(),//TODO: show data depending on Timeline dropDown
                pointsMode: PointsMode.aboveThreshold,
                pointColor: getSelectedDropDownLineColor(),
                pointSize: 10.0,
                threshold: getSelectedDropDownThreshold(),
                lineColor: getSelectedDropDownLineColor(),),
              ],
            )
            ),
            Container(
              child: Wrap(
                spacing: 10.0,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: <Widget>[
                  Text(
                    'AirQualiy',
                    style: TextStyle(
                      color: airQualityColor,
                    ),
                  ),
                  Text(
                    'Temperature',
                    style: TextStyle(
                      color: temperatureColor,
                    ),
                  ),
                  Text(
                    'Humidity',
                    style: TextStyle(
                      color: humidityColor,
                    ),
                  ),
                  Text(
                    'Noise',
                    style: TextStyle(
                      color: noiseColor,
                    ),
                  ),
                  Text(
                    'Turbidity',
                    style: TextStyle(
                      color: turbidityColor,
                    ),
                  ),
                  Text(
                    'LPG',
                    style: TextStyle(
                      color: lpgColor,
                    ),
                  ),
                ],
              ),
            ),
            ExpansionTile(
              title: Text('Air quality'),
              children: airQuality
                  .asMap()
                  .map(
                    (index, data) => MapEntry(
                          index,
                          ListTile(
                            title: Text('Air quality is:'),
                            trailing: Text(data.toString(),style: TextStyle(fontSize: 25.0,
                                color: data> 101 ? Colors.red : Colors.green),),
                            subtitle: Text(DateTime.fromMillisecondsSinceEpoch(
                                    int.tryParse(timestamp[index].toString()))
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
                              trailing: Text(data.toString(),style: TextStyle(fontSize: 25.0,
                              color: data> 40 ? Colors.red : Colors.green),),
                              subtitle: Text(
                                  DateTime.fromMillisecondsSinceEpoch(
                                          int.tryParse(
                                                  timestamp[index].toString()) )
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
                              trailing: Text(data.toString(), style: TextStyle(fontSize: 25.0,
                                  color: data> 10 ? Colors.red : Colors.green),),
                              subtitle: Text(
                                  DateTime.fromMillisecondsSinceEpoch(
                                          int.tryParse(
                                                  timestamp[index].toString()))
                                      .toUtc()
                                      .toString()),
                            ),
                          ),
                    )
                    .values
                    .toList()),
            ExpansionTile(
                title: Text('Sound'),
                children: noise
                    .asMap()
                    .map(
                      (index, data) => MapEntry(
                            index,
                            ListTile(
                              title: Text('Sound is:'),
                              trailing: Text(data.toString(),style: TextStyle(fontSize: 25.0,
                                  color: data> 20 ? Colors.red : Colors.green),),
                              subtitle: Text(
                                  DateTime.fromMillisecondsSinceEpoch(
                                          int.tryParse(
                                                  timestamp[index].toString()) )
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
                              trailing: Text(data.toString(),style: TextStyle(fontSize: 25.0,
                                  color: data> 45 ? Colors.red : Colors.green),),
                              subtitle: Text(
                                  DateTime.fromMillisecondsSinceEpoch(
                                          int.tryParse(
                                                  timestamp[index].toString()) )
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
                              trailing: Text(data.toString(),style: TextStyle(fontSize: 25.0,
                                  color: data> 40 ? Colors.red : Colors.green),),
                              subtitle: Text(
                                  DateTime.fromMillisecondsSinceEpoch(
                                          int.tryParse(
                                                  timestamp[index].toString()) )
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

  getSelectedDropDownData() {
    print('line 389 $actualDropdown, ${humidity.length}');
    return actualDropdown == 'Air quality' ? airQuality
        : actualDropdown == 'Humidity' ? humidity
        :actualDropdown == 'LPG' ? lpg
        :actualDropdown == 'Noise' ? noise
        :actualDropdown == 'Temperature' ? temperature
        :turbidity;

  }

  getSelectedDropDownThreshold() {
    return actualDropdown == 'Air quality' ? airQualityThreshold
        : actualDropdown == 'Humidity' ? humidityThreshold
        :actualDropdown == 'LPG' ? lpgThreshold
        :actualDropdown == 'Noise' ? noiseThreshold
        :actualDropdown == 'Temperature' ? temperatureThreshold
        :turbidityThreshold;

  }

  getSelectedDropDownLineColor() {
    return actualDropdown == 'Air quality' ? airQualityColor
        : actualDropdown == 'Humidity' ? humidityColor
        :actualDropdown == 'LPG' ? lpgColor
        :actualDropdown == 'Noise' ? noiseColor
        :actualDropdown == 'Temperature' ? temperatureColor
        :turbidityColor;
  }
}

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geocoder/geocoder.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:pollution_monitoring_system/util/location/location.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pollution monitoring app',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Pollution monitoring app'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  double userLatitude = 20.5937;
  double userLongitude = 78.9629;
  Address userLocationAddress;
  Completer<GoogleMapController> _mapController = Completer();
  MapType _currentMapType = MapType.normal;
  final Set<Marker> _markers = {};

  PanelController _bottomSheetController = new PanelController();

  void _onMapCreated(GoogleMapController controller) {
    //This method is called upon map created
    _mapController.complete(controller);
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called.
//    return Scaffold(
//      body: GoogleMap(
//          onMapCreated: _onMapCreated,
//          mapType: _currentMapType,
//          markers: _markers,
//          initialCameraPosition: CameraPosition(
//            target: LatLng(userLongitude, userLongitude),
//            zoom: 14.4746,
//          )),
//      floatingActionButton: FloatingActionButton(
//        onPressed: () {
//          //This will change map type to normal or satellite depending on what's showing to user.
//          setState(() {
//            _currentMapType = _currentMapType == MapType.normal
//                ? MapType.satellite
//                : MapType.normal;
//          });
//        },
//        child: Icon(Icons.layers),
//      ),
//      bottomSheet: _getDetailsSheet(context),
//    );
    return Scaffold(
      body: SlidingUpPanel(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24.0),
          topRight: Radius.circular(24.0),
        ),
        body: GoogleMap(
          onMapCreated: _onMapCreated,
          mapType: _currentMapType,
          markers: _markers,
          initialCameraPosition: CameraPosition(
            target: LatLng(20.5937, 78.9629),
            zoom: 5.0,
          )),
        panel: _getFullDetailsSheet(context),
        collapsed: _getCollapsedDetailsSheet(context),
        controller: _bottomSheetController,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          //This will change map type to normal or satellite depending on what's showing to user.
          setState(() {
            _currentMapType = _currentMapType == MapType.normal
                ? MapType.satellite
                : MapType.normal;
          });
        },
        child: Icon(Icons.layers),
      ),
    );
  }

  @override
  void initState() {
    //This is the first method which invokes every time when this class is called.
    super.initState();
    initPlatformState();
  }

  void initPlatformState() async {
    //This method will call the getUserLocation method from Utils and gets the latitude and longitude also with geooder data(address)
    List userLocationData = await getUserLocation();
    double latitude = userLocationData[0];
    double longitude = userLocationData[1];

    setState(() {
      //This setState method is called when we have refresh/render UI to show new changes made into UI
      print('line 136 ${latitude}, - $longitude, ${userLocationData[2]}');
      userLatitude = latitude;
      userLongitude = longitude;
      userLocationAddress = userLocationData[2];
    });
    _gotoUserLocation(userLatitude, userLongitude);
  }

 Widget _getFullDetailsSheet(BuildContext context) {
    //This method shows the details of the data from that location when sheet is open

    return  Column(
      children: <Widget>[
        Text('hi')
      ],
    );
  }

  Widget _getCollapsedDetailsSheet(BuildContext context) {
    //This method shows the details of the data from that location when sheet is not open

    return  Container(
      padding: EdgeInsets.all(20.0),
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
          color: Colors.blueGrey,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24.0),
            topRight: Radius.circular(24.0),
          ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Icon(Icons.keyboard_arrow_up,color: Colors.white,),
          Text(userLocationAddress.subAdminArea,
          style: TextStyle(color: Colors.white,
          fontSize: 20.0,
          fontWeight: FontWeight.bold),),
          Text('$userLatitude , $userLongitude',
          style: TextStyle(color: Colors.white),)
        ],
      ),
    );
  }

  void _gotoUserLocation(double userLatitude, double userLongitude) async{
    //after getting the location data now we move to user(device) location.
    print('line 154 came here $userLongitude, $userLongitude');
    final GoogleMapController _controller = await _mapController.future;
    _controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(target: LatLng(userLatitude, userLongitude),
    zoom: 12.0)));
  }
}

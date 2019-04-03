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
      debugShowCheckedModeBanner: false,
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
  double selectedMarkerLatitude;
  double selectedMarketLongitude;
  Address selectedLocationAddress;
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
  print('line 93 ${_markers.length}');
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
      print('line 136 $latitude, - $longitude, ${userLocationData[2]}');
      userLatitude = latitude;
      userLongitude = longitude;
      userLocationAddress = userLocationData[2];
      selectedMarkerLatitude = latitude;
      selectedMarketLongitude = longitude;
      selectedLocationAddress = userLocationData[2];
    });
    _gotoUserLocation(userLatitude, userLongitude);
    _addMarkerOnMap(latitude, longitude);
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
          getSelectedLocationName(),
          Text('${selectedMarkerLatitude == null ? '...' : selectedMarkerLatitude} , ${selectedMarketLongitude == null ? '...': selectedMarketLongitude}',
          style: TextStyle(color: Colors.white),)
        ],
      ),
    );
  }

  Widget getSelectedLocationName() {
    String locationName;
    if(selectedLocationAddress.addressLine == null){
      if(selectedLocationAddress.subLocality == null){
        if(selectedLocationAddress.locality == null){
          if(selectedLocationAddress.subAdminArea == null){
            if(selectedLocationAddress.adminArea == null){
              locationName = 'unable to fetch location name';
            }else{
              locationName = selectedLocationAddress.adminArea;
              print('LocalityName - admin area');
            }
          }else{
            locationName = selectedLocationAddress.subAdminArea;
            print('LocalityName - sub admin area');
          }
        }else{
          locationName = selectedLocationAddress.locality;
          print('LocalityName - locality area');
        }
      }else{
        locationName = selectedLocationAddress.subLocality;
        print('LocalityName - sublocality area');
      }
    }else{
      locationName = selectedLocationAddress.addressLine;
      print('LocalityName - addressline');
    }
   return Text(selectedLocationAddress == null ? 'Getting data..' : locationName,
      style: TextStyle(color: Colors.white,
          fontSize: 20.0,
          fontWeight: FontWeight.bold),);
  }

  void _gotoUserLocation(double userLatitude, double userLongitude) async{
    //after getting the location data now we move to user(device) location.
    print('line 154 came here $userLongitude, $userLongitude');
    final GoogleMapController _controller = await _mapController.future;
    _controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(target: LatLng(userLatitude, userLongitude),
    zoom: 12.0)));
  }

  void _addMarkerOnMap(double latitude, double longitude) {
    print('line 196 came here $latitude, $longitude');
     LatLng _latLan =  LatLng(latitude, latitude);
    //first marker is user's device GPS location
    _markers.add(Marker(markerId: MarkerId(_latLan.toString()),
      position: LatLng(latitude, longitude),
      onTap: (){
        getLocationDetailsOfCoordinates(latitude, longitude);
      },
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet),));
    //added smaple checking data
    _markers.add(Marker(markerId: MarkerId('jdkddf'),
      position: LatLng(31.2536, 75.7037),
      onTap: (){
          getLocationDetailsOfCoordinates(31.2536, 75.7037);
      },
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),));
     setState(() {
     });

  }

  void getLocationDetailsOfCoordinates(double latitude, double longitude) async{
    //once user clicks on a marker we will send that location coordinates to the method and get details of it.
    List selectedMarkerAddress = await getUserAddressFromCoordinates(latitude, longitude);
    selectedLocationAddress = null;
    setState(() {
      //This setState method is called when we have refresh/render UI to show new changes made into UI
      print('line 136 $latitude, - $longitude, ${selectedMarkerAddress[2]}');
      selectedMarkerLatitude = latitude;
      selectedMarketLongitude = longitude;
      selectedLocationAddress = selectedMarkerAddress[2];
    });
  }


}

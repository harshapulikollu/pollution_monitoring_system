import 'package:flutter/services.dart';
import 'package:geocoder/geocoder.dart';
import 'package:location/location.dart';

getUserLocation() async {
  //This method will track the current location of device(user) in lat and long then,
  //using geoCoder by passing lat and long to it, we will get the human readable address.
  //we will return an array which carries lat, long and user address

  LocationData myLocation;
  String error;
  Location location = new Location();
  try {
    myLocation = await location.getLocation();
  } on PlatformException catch (e) {
    if (e.code == 'PERMISSION_DENIED') {
      error = 'please grant permission';
      print(error);
    }
    if (e.code == 'PERMISSION_DENIED_NEVER_ASK') {
      error = 'permission denied- please enable it from app settings';
      print(error);
    }
    myLocation = null;
  }
  final coordinates = new Coordinates(
      myLocation.latitude, myLocation.longitude);
  var addresses = await Geocoder.local.findAddressesFromCoordinates(
      coordinates);
  Address userLocation = addresses.first;
  print('line 30 ${userLocation.locality}, ${userLocation.adminArea},${userLocation.subLocality}, ${userLocation.subAdminArea},${userLocation.addressLine}, ${userLocation.featureName},${userLocation.thoroughfare}, ${userLocation.subThoroughfare}');
  print('line 31 in location ${myLocation.latitude} , ${myLocation.longitude} ');
  return [myLocation.latitude, myLocation.longitude, userLocation];
}

getUserAddressFromCoordinates(double latitude, double longitude) async{
  final coordinates = new Coordinates(
      latitude, longitude);
  var addresses = await Geocoder.local.findAddressesFromCoordinates(
      coordinates);
  Address userLocation = addresses.first;
  return [latitude, longitude, userLocation];
}
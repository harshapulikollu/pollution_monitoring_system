import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geocoder/geocoder.dart';

class LocPollutionDetails extends StatefulWidget {
  final String selectedLocationLatitude;
  final String selectedLocationLongitude;
  LocPollutionDetails(this.selectedLocationLatitude, this.selectedLocationLongitude);
  @override
  _LocPollutionDetailsState createState() => _LocPollutionDetailsState();
}

class _LocPollutionDetailsState extends State<LocPollutionDetails> {
  @override
  Widget build(BuildContext context) {

    return StreamBuilder(
        stream: Firestore.instance.collection('sendorData').document(widget.selectedLocationLatitude+'&'+widget.selectedLocationLongitude).collection('data').orderBy('timestamp').snapshots(),
        builder: (BuildContext context, snapshot){
          if(snapshot.hasError){
            return Center(child: Text('Oops.. something went wrong.'),);
          }
          switch(snapshot.connectionState){
            case ConnectionState.waiting:
              print('line 25 coonection state waiting');
              return Center(child: CircularProgressIndicator(),);
            case ConnectionState.none:
              return (Text('none'));

              default:
              print('line 25 coonection state done');
              if(snapshot.hasData) {
                return Center(child: Text('cool exists'),);
              }else{
                return Center(child:  Text('Hmm... seems like we don\'t have data for this location'),);
              }
              break;
          }
        });
  }
}

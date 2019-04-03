import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

//An About page which contains details of app and link to source code.

class AboutPage extends StatefulWidget {
  @override
  _AboutPageState createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('About'),
        elevation: 0.0,
      ),
      body: ListView(
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(10.0),
            child:
            new Text('About app', style: Theme.of(context).textTheme.body2),
          ),
          Container(
            color: Theme.of(context).cardColor,
            child: new ListTile(
              title: new Text('''A POLLUTION MONITORING SYSTEM (Flutter application) for Lovely Professional University capstone 2019(course code- CSE445), which monitors the pollution around the location where the device is held and alerts users when there the pollution level is high in that location.Users can see the data in real-time through this app.\nDeveloped by Akshay kumar mishra(11406923), Aman prathap singh(), Harsha pulikollu(11404683), Prince kumar jha(11407392), veerender() under the guidance of Tejinder sir.
              ''',
              style: TextStyle(
                fontSize: 15.0,
                fontWeight: FontWeight.bold
              ),),
            ),
          ),
          Container(
            color: Theme.of(context).cardColor,
            child: new ListTile(
              title: new Text('Source code'),
              onTap: () async{
                const url = 'https://github.com/harshapulikollu/pollution_monitoring_system';
                if (await canLaunch(url)) {
                  await launch(url);
                } else {
                  throw 'Could not launch $url';
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

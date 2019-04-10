import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:meta/meta.dart';


NotificationDetails get _ongoing {
  final androidChannelSpecifics = AndroidNotificationDetails(
    'pullution_monitoring_system_cse445',
    'pollution_monitoring_system',
    'notification_for_pollution_monitoring_system',
    importance: Importance.Max,
    priority: Priority.High,
    ongoing: true,
    autoCancel: true,
  );
  final iOSChannelSpecifics = IOSNotificationDetails();
  return NotificationDetails(androidChannelSpecifics, iOSChannelSpecifics);
}

Future showOngoingNotification(
    FlutterLocalNotificationsPlugin notifications, {
      @required String title,
      @required String body,
      int id = 0,//This the identifier for notification, If we get a new notif then the old notification will be replaced with new notif.
    }) =>
    _showNotification(notifications,
        title: title, body: body, id: id, type: _ongoing);

Future _showNotification(
    FlutterLocalNotificationsPlugin notifications, {
      @required String title,
      @required String body,
      @required NotificationDetails type,
      int id = 0,
    }) =>
    notifications.show(id, title, body, type);
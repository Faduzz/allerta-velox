import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _ready = false;

  Future<void> _init() async {
    if (_ready) return;
    tzdata.initializeTimeZones();
    await _plugin.initialize(
      settings: const InitializationSettings(
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      ),
    );
    _ready = true;
  }

  /// Chiede il permesso notifiche (solo avviso e suono). `true` se concesso.
  Future<bool> requestPermission() async {
    await _init();
    final ios = _plugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    final granted =
        await ios?.requestPermissions(alert: true, sound: true, badge: false);
    return granted ?? false;
  }

  /// Notifica programmata tra [delay]: puoi bloccare lo schermo prima che parta.
  Future<void> scheduleTest({
    Duration delay = const Duration(seconds: 10),
  }) async {
    await _init();
    await _plugin.zonedSchedule(
      id: 1,
      title: 'Allerta Velox',
      body: 'Notifica di prova: il banner funziona.',
      scheduledDate: tz.TZDateTime.now(tz.UTC).add(delay),
      notificationDetails: const NotificationDetails(
        iOS: DarwinNotificationDetails(presentAlert: true, presentSound: true),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }
}

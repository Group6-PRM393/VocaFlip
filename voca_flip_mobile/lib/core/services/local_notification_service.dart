import 'dart:developer';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class LocalNotificationService {
  LocalNotificationService._();
  static final LocalNotificationService _instance =
      LocalNotificationService._();
  static LocalNotificationService get instance => _instance;

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  Future<void> init() async {
    if (_initialized || kIsWeb) return;

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    const darwinSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    final windowsSettings = Platform.isWindows
        ? const WindowsInitializationSettings(
            appName: 'VocaFlip',
            appUserModelId: 'com.vocaflip.mobile',
            guid: 'd3b6a241-7613-4b74-9e3d-9a7b348c1234',
          )
        : null;

    final initSettings = InitializationSettings(
      android: androidSettings,
      iOS: darwinSettings,
      windows: windowsSettings,
    );

    final result = await _plugin.initialize(settings: initSettings);
    _initialized = result ?? false;
    log(
      'LocalNotificationService.init() result=$result, _initialized=$_initialized',
    );

    // Request notification permission on Android 13+
    await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();
  }

  Future<bool> showNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    if (kIsWeb) return false;
    if (!_initialized) {
      log('LocalNotificationService: not initialized, skipping notification');
      return false;
    }

    try {
      const androidDetails = AndroidNotificationDetails(
        'vocaflip_channel',
        'VocaFlip Notifications',
        channelDescription: 'Thông báo từ VocaFlip',
        importance: Importance.high,
        priority: Priority.high,
      );

      const notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: DarwinNotificationDetails(),
        windows: WindowsNotificationDetails(),
      );

      await _plugin.show(
        id: id,
        title: title,
        body: body,
        notificationDetails: notificationDetails,
      );
      log('LocalNotificationService: notification shown id=$id');
      return true;
    } catch (e, st) {
      log(
        'LocalNotificationService: failed to show notification',
        error: e,
        stackTrace: st,
      );
      return false;
    }
  }
}

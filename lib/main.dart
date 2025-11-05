import 'package:credlawn/helpers/device_info_helper.dart';
import 'package:credlawn/network/api_login_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:credlawn/screens/login_screen.dart';
import 'package:credlawn/screens/home_screen.dart';
import 'package:credlawn/screens/app_update_screen.dart';
import 'package:credlawn/helpers/session_manager.dart';
import 'package:credlawn/models/user.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:google_fonts/google_fonts.dart';
import 'package:credlawn/helpers/call_log_sync_manager.dart';
import 'package:credlawn/helpers/app_state_manager.dart';
import 'package:credlawn/screens/customer_details_screen.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:credlawn/screens/permission_denied_screen.dart';
import 'package:credlawn/screens/notification_detail_screen.dart';
import 'package:credlawn/screens/no_internet_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:credlawn/models/fcm_log_model.dart';
import 'package:credlawn/helpers/database_service.dart';
import 'package:credlawn/helpers/app_lifecycle_handler.dart';
import 'package:credlawn/helpers/background_sync_service.dart';
import 'package:credlawn/api/server_api.dart';
import 'package:credlawn/helpers/error_logger.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

Future<String?> _getInitialNotificationPayload() async {
  RemoteMessage? initialFCMMessage = await FirebaseMessaging.instance.getInitialMessage();
  if (initialFCMMessage != null) {
    String? title = initialFCMMessage.notification?.title;
    String? body = initialFCMMessage.notification?.body ?? initialFCMMessage.data['body'];
    String logId = initialFCMMessage.data['name'] ?? '';
    return json.encode({'title': title, 'body': body, 'name': logId});
  }
  final NotificationAppLaunchDetails? notificationAppLaunchDetails =
      await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();
  if (notificationAppLaunchDetails?.didNotificationLaunchApp ?? false) {
    return notificationAppLaunchDetails!.notificationResponse?.payload;
  }
  return null;
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  BackgroundSyncService.initialize();
  await Firebase.initializeApp();
  await DatabaseService.instance.initialize();
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/launcher_icon');
  const InitializationSettings initializationSettings = InitializationSettings(
    android: AndroidInitializationSettings('@mipmap/launcher_icon'),
  );
  await flutterLocalNotificationsPlugin.initialize(initializationSettings,
    onDidReceiveNotificationResponse: (NotificationResponse response) async {
      if (response.payload != null) {
        try {
          final data = json.decode(response.payload!);
          navigatorKey.currentState?.push(
            MaterialPageRoute(
              builder: (context) => NotificationDetailScreen(
                log: FcmLogModel(
                  name: data['name'] ?? '', // Pass logId
                  title: data['title'] ?? 'Notification',
                  body: data['body'] ?? '',
                  messageStatus: 'Unread', // Placeholder
                  creation: DateTime.now(), // Placeholder
                ),
              ),
            ),
          );
        } catch (_) {}
      }
    },
  );
  String? initialNotificationPayload = await _getInitialNotificationPayload();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    String? title = message.notification?.title;
    String? body = message.notification?.body;
    String? fullMessage = message.data['body'];
    String displayBody = (fullMessage ?? body) ?? '';
    String logId = message.data['name'] ?? ''; // Extract logId

    if (title != null && displayBody.isNotEmpty) {
      int id = DateTime.now().millisecondsSinceEpoch.remainder(100000);
      flutterLocalNotificationsPlugin.show(
        id,
        title,
        displayBody,
        NotificationDetails(
          android: AndroidNotificationDetails(
            'default_channel',
            'Default Channel',
            channelDescription: 'Default channel for app notifications',
            importance: Importance.max,
            priority: Priority.high,
            styleInformation: BigTextStyleInformation(displayBody),
          ),
        ),
        payload: json.encode({'title': title, 'body': displayBody, 'name': logId}), // Include logId in payload
      );
    }
  });
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    String? title = message.notification?.title;
    String? body = message.notification?.body;
    String? fullMessage = message.data['body'];
    String displayBody = (fullMessage ?? body) ?? '';
    String logId = message.data['name'] ?? ''; // Extract logId

    if (title != null && displayBody.isNotEmpty) {
      navigatorKey.currentState?.push(
        MaterialPageRoute(
          builder: (context) => NotificationDetailScreen(
            log: FcmLogModel(
              name: logId, // Pass logId
              title: title,
              body: displayBody,
              messageStatus: 'Unread', // Placeholder
              creation: DateTime.now(), // Placeholder
            ),
          ),
        ),
      );
    }
  });
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );
  String? token = await messaging.getToken();
  await CallLogSyncManager.initialize();
  await CallLogSyncManager.syncCallLogs();
  AppLifecycleHandler.initialize();
  final String? pendingFeedbackMobile = await AppStateManager.getPendingFeedbackMobile();
  var status = await Permission.phone.status;
  if (!status.isGranted) {
    status = await Permission.phone.request();
  }
  Widget initialScreen;
  if (status.isGranted) {
    initialScreen = MyApp(pendingFeedbackMobile: pendingFeedbackMobile, initialNotificationPayload: initialNotificationPayload);
  } else {
    initialScreen = const MaterialApp(
      home: PermissionDeniedScreen(),
    );
  }
  runApp(initialScreen);
}

class MyApp extends StatefulWidget {
  final String? pendingFeedbackMobile;
  final String? initialNotificationPayload;
  const MyApp({super.key, this.pendingFeedbackMobile, this.initialNotificationPayload});
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    if (widget.initialNotificationPayload != null) {
      try {
        final data = json.decode(widget.initialNotificationPayload!);
        final String title = data['title'] ?? 'Notification';
        final String body = data['body'] ?? '';
        final String logId = data['name'] ?? '';
        return MaterialApp(
          navigatorKey: navigatorKey,
          title: 'Credlawn',
          theme: ThemeData(
            primarySwatch: Colors.blue,
            scaffoldBackgroundColor: Colors.white,
            fontFamily: GoogleFonts.poppins().fontFamily,
            colorScheme: ColorScheme.light(primary: Colors.blue, secondary: Colors.blueAccent),
            buttonTheme: ButtonThemeData(textTheme: ButtonTextTheme.primary), dialogTheme: DialogThemeData(backgroundColor: Colors.white),
          ),
          home: NotificationDetailScreen(
            log: FcmLogModel(
              name: logId, // Pass logId
              title: title,
              body: body,
              messageStatus: 'Unread', // Placeholder
              creation: DateTime.now(), // Placeholder
            ),
          ),
        );
      } catch (_) {}
    }
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'Credlawn',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
        fontFamily: GoogleFonts.poppins().fontFamily,
        colorScheme: ColorScheme.light(primary: Colors.blue, secondary: Colors.blueAccent),
        buttonTheme: ButtonThemeData(textTheme: ButtonTextTheme.primary), dialogTheme: DialogThemeData(backgroundColor: Colors.white),
      ),
      home: FutureBuilder<User?>(
              future: _checkSession(context),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) return Center(child: Text('Error loading session'));
                else if (snapshot.hasData && snapshot.data != null) return HomeScreen(user: snapshot.data!);
                else return LoginScreen();
              },
            ),
    );
  }

  Future<User?> _checkSession(BuildContext context) async {
    await _checkAppVersion();
    var sessionData = await SessionManager.getSessionData();
    String? token = await FirebaseMessaging.instance.getToken();
    String? deviceId = await getDeviceId();
    if (token != null && deviceId != null) {
      if (sessionData != null) {
        await sendFcmTokenToServer(token: token, deviceId: deviceId, userId: sessionData.userId, sid: sessionData.sid);
      } else {
        await sendFcmTokenToServer(token: token, deviceId: deviceId);
      }
    }
    return sessionData;
  }

  Future<void> _checkAppVersion() async {
    try {
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      String currentVersion = packageInfo.version;

      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? storedVersion = prefs.getString('appVersion');

      if (storedVersion != currentVersion) {
        await SessionManager.logout();
        await prefs.setString('appVersion', currentVersion);
      }

      final response = await http.get(ServerApi.appVersion);
      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        if (data != null && data['data'] != null) {
          String latestVersion = data['data']['latest_version'];
          String changeLog = data['data']['change_log'];
          String downloadUrl = data['data']['url'];
          if (currentVersion != latestVersion) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              navigatorKey.currentState?.push(
                MaterialPageRoute(
                  builder: (context) => AppUpdateScreen(
                    currentVersion: currentVersion,
                    latestVersion: latestVersion,
                    changeLog: changeLog,
                    url: downloadUrl,
                  ),
                ),
              );
            });
          }
        }
      }
    } catch (e) {
      final connectivityResult = await Connectivity().checkConnectivity();
      final hasInternet = connectivityResult != ConnectivityResult.none;

      if (!hasInternet) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          navigatorKey.currentState?.push(
            MaterialPageRoute(
              fullscreenDialog: true,
              builder: (context) => NoInternetScreen(),
            ),
          ).then((result) {
            if (result != true) {
              _checkAppVersion();
            }
          });
        });
      } else {
        await ErrorLogger.logException(
          context: 'MyApp._checkAppVersion',
          exception: e,
        );
      }
    }
  }
}

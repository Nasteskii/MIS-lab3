import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';
import 'package:raspored/firebase_options.dart';
import 'package:raspored/models/term.dart';
import 'package:raspored/ui/pages/calendar_page.dart';
import 'package:raspored/ui/pages/home_page.dart';
import 'package:raspored/ui/pages/sign_in_page.dart';
import 'package:raspored/ui/pages/sign_up_page.dart';
import 'package:raspored/view_models/term_view_model.dart';
import 'package:timezone/timezone.dart' as tz;

final navigatorKey = GlobalKey<NavigatorState>();

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await initializeNotifications();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => TermViewModel(),
        ),
      ],
      child: const MyApp(),
    ),
  );
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(
        const AndroidNotificationChannel(
          '0',
          'Event Reminder',
          description: 'Channel for event reminders',
          importance: Importance.max,
        ),
      );
}

Future<void> initializeNotifications() async {
  try {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('app_icon');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);

    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'event_reminders_channel',
      'Event Reminder',
      description: 'Channel for event reminders',
      importance: Importance.max,
    );

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  } catch (e) {
    print('Error initializing notifications: $e');
  }
}

Future<void> scheduleNotification(Term term) async {
  try {
    AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'event_reminders_channel',
      'Event Reminder',
      channelDescription: '${term.courseName} is starting soon!',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
    );
    NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    tz.TZDateTime scheduledDate = tz.TZDateTime.from(
      term.dateTime,
      tz.getLocation('Europe/Skopje'),
    );

    await flutterLocalNotificationsPlugin.zonedSchedule(
      0,
      'Event Reminder',
      '${term.courseName} is starting soon!',
      scheduledDate,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'event_reminders_channel',
          'Event Reminder',
          channelDescription: 'Channel for event reminders',
          importance: Importance.max,
          priority: Priority.high,
          ticker: 'ticker',
        ),
      ),
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  } catch (e) {
    print('Error scheduling notification: $e');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'Flutter Firebase',
      routes: {
        '/': (context) => const HomePage(),
        '/signIn': (context) => const SignInPage(),
        '/signUp': (context) => const SignUpPage(),
        '/calendar': (context) => const CalendarPage(),
      },
    );
  }
}

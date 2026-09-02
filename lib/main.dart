import 'package:flutter/material.dart';

import 'screens/splash_screen.dart';
import 'services/deep_link_service.dart';
import 'services/notification_service.dart';

final GlobalKey<NavigatorState> appNavigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.initialize();

  final deepLinkService = DeepLinkService(appNavigatorKey);
  await deepLinkService.initialize();

  runApp(TicketProMobile(
    deepLinkService: deepLinkService,
  ));
}

class TicketProMobile extends StatelessWidget {
  const TicketProMobile({
    super.key,
    required this.deepLinkService,
  });

  final DeepLinkService deepLinkService;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'TicketPro',
      navigatorKey: appNavigatorKey,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF050814),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}
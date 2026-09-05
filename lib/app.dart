import 'package:flutter/material.dart';
import 'package:app_mobile/app/router.dart';
import 'package:app_mobile/features/notifications/services/firebase_service.dart';
import 'package:app_mobile/shared/services/ping_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:app_mobile/shared/services/connectivity_service.dart';
import 'package:app_mobile/shared/widgets/network_banner.dart';
class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    PingService().start();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      PingService().start();
      _saveActivityTime();
    } else if (state == AppLifecycleState.paused || state == AppLifecycleState.detached) {
      PingService().stop();
      _saveActivityTime();
      _saveAppCloseTime();
    }
  }

  Future<void> _saveActivityTime() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('last_activity_time', DateTime.now().millisecondsSinceEpoch);
  }

  Future<void> _saveAppCloseTime() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('last_app_close_time', DateTime.now().millisecondsSinceEpoch);
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ConnectivityService()),
      ],
      child: MaterialApp(
        builder: (context, child) {
          return NetworkBanner(child: child ?? const SizedBox.shrink());
        },
        debugShowCheckedModeBanner: false,
        title: 'School Platform',
        navigatorKey: navigatorKey, 
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        initialRoute: '/',
        onGenerateRoute: AppRouter.generateRoute,
      ),
    );
  }
}

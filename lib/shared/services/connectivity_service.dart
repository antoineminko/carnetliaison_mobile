import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:flutter/material.dart';

class ConnectivityService extends ChangeNotifier {
  bool _isOnline = true;
  bool get isOnline => _isOnline;

  final Connectivity _connectivity = Connectivity();
  final InternetConnection _internetChecker = InternetConnection();

  StreamSubscription<List<ConnectivityResult>>? _subscription;
  StreamSubscription<InternetStatus>? _internetSubscription;

  ConnectivityService() {
    _initConnectivity();
  }

  Future<void> _initConnectivity() async {
    try {
      _isOnline = await _internetChecker.hasInternetAccess;
      notifyListeners();
    } catch (e) {
      debugPrint("Couldn't check connectivity status: $e");
    }

    _subscription = _connectivity.onConnectivityChanged.listen((results) async {
      bool hasInternet = await _internetChecker.hasInternetAccess;
      if (_isOnline != hasInternet) {
        _isOnline = hasInternet;
        notifyListeners();
      }
    });

    _internetSubscription = _internetChecker.onStatusChange.listen((InternetStatus status) {
      bool previousState = _isOnline;
      _isOnline = status == InternetStatus.connected;
      if (previousState != _isOnline) {
        notifyListeners();
      }
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _internetSubscription?.cancel();
    super.dispose();
  }
}

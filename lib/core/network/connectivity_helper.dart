import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityHelper {
  static final ConnectivityHelper _instance = ConnectivityHelper._internal();
  factory ConnectivityHelper() => _instance;
  ConnectivityHelper._internal();

  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  bool _isConnected = true;
  bool get isConnected => _isConnected;

  Future<void> init() async {
    final result = await _connectivity.checkConnectivity();
    _updateConnectionStatus(result);
  }

  void startListening(Function(bool) onConnectionChange) {
    _subscription = _connectivity.onConnectivityChanged.listen((result) {
      _updateConnectionStatus(result);
      onConnectionChange(_isConnected);
    });
  }

  void _updateConnectionStatus(List<ConnectivityResult> result) {
    _isConnected =
        result.contains(ConnectivityResult.mobile) ||
        result.contains(ConnectivityResult.wifi) ||
        result.contains(ConnectivityResult.ethernet);
  }

  void dispose() {
    _subscription?.cancel();
  }
}

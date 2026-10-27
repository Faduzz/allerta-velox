import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import 'notification_service.dart';
import 'permission_state.dart';
import 'tracking_service.dart';

void main() => runApp(const AllertaVeloxApp());

class AllertaVeloxApp extends StatelessWidget {
  const AllertaVeloxApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(title: 'Allerta Velox', home: HomePage());
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  final _tracking = TrackingService();
  final _notifications = NotificationService();
  StreamSubscription<TrackingSnapshot>? _sub;
  TrackingSnapshot? _last;
  LocationUiState _state = LocationUiState.denied;
  String? _notificationHint;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _refreshState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _sub?.cancel();
    _tracking.stop();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _refreshState();
  }

  Future<void> _refreshState() async {
    final enabled = await Geolocator.isLocationServiceEnabled();
    final permission = await Geolocator.checkPermission();
    if (!mounted) return;
    setState(() {
      _state = describeLocationState(
        serviceEnabled: enabled,
        permission: permission,
      );
    });
  }

  Future<void> _start() async {
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission(); // «in uso»
    }
    if (permission == LocationPermission.whileInUse) {
      permission = await Geolocator.requestPermission(); // passa a «Sempre»
    }
    await _refreshState();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return;
    }
    await _sub?.cancel();
    _sub = _tracking.start().listen((snapshot) {
      if (mounted) setState(() => _last = snapshot);
    });
  }

  Future<void> _stop() async {
    await _sub?.cancel();
    _sub = null;
    await _tracking.stop();
    if (mounted) setState(() {});
  }

  Future<void> _scheduleTest() async {
    final granted = await _notifications.requestPermission();
    if (granted) await _notifications.scheduleTest();
    if (!mounted) return;
    setState(() => _notificationHint = notificationHint(granted: granted));
    if (granted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Notifica tra 10 secondi: blocca lo schermo.'),
      ));
    }
  }

  String _stateMessage(LocationUiState state) => switch (state) {
        LocationUiState.servicesOff =>
          'Servizi di localizzazione spenti. Attivali in Impostazioni, '
              'Privacy e sicurezza, Localizzazione.',
        LocationUiState.denied =>
          'Permesso posizione non ancora concesso. Premi «Avvia tracciamento».',
        LocationUiState.deniedForever =>
          'Permesso negato. In Impostazioni, Allerta Velox, Posizione, '
              'scegli «Sempre».',
        LocationUiState.whileInUseOnly =>
          'Permesso solo «mentre usi l’app»: in background non funziona. '
              'In Impostazioni scegli «Sempre».',
        LocationUiState.ready => 'Pronto: permesso «Sempre» concesso.',
      };

  Widget _readout() {
    final s = _last;
    if (s == null) return const Text('Nessun fix ricevuto.');
    String two(int n) => n.toString().padLeft(2, '0');
    final t = s.at.toLocal();
    return Text(
      'lat ${s.lat.toStringAsFixed(5)}   lng ${s.lng.toStringAsFixed(5)}\n'
      'velocità ${(s.speedMps * 3.6).toStringAsFixed(0)} km/h   '
      'precisione ${s.accuracyM.toStringAsFixed(0)} m\n'
      'fix ricevuti ${s.fixCount}\n'
      'ultimo fix ${two(t.hour)}:${two(t.minute)}:${two(t.second)}\n'
      'buco massimo ${s.maxGap.inSeconds} s',
    );
  }

  @override
  Widget build(BuildContext context) {
    final hint = _notificationHint;
    return Scaffold(
      appBar: AppBar(title: const Text('Allerta Velox · tappa 1')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(_stateMessage(_state)),
          if (hint != null) ...[const SizedBox(height: 8), Text(hint)],
          const SizedBox(height: 16),
          FilledButton(
            onPressed: _start,
            child: const Text('Avvia tracciamento'),
          ),
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: _sub == null ? null : _stop,
            child: const Text('Ferma tracciamento'),
          ),
          const SizedBox(height: 16),
          _readout(),
          const SizedBox(height: 24),
          FilledButton.tonal(
            onPressed: _scheduleTest,
            child: const Text('Notifica tra 10 s'),
          ),
        ],
      ),
    );
  }
}

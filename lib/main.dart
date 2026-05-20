import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'config/theme.dart';
import 'widgets/synapse_dashboard.dart';
import 'controllers/synapse_score_controller.dart';
import 'utils/privacy_manager.dart';
import 'services/biometric_sync_service.dart';
import 'services/notification_mediator_service.dart';

/// Synapse App Entry Point
///
/// Initializes all services, configures system UI, and launches the
/// context-aware productivity engine.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock orientation to portrait for consistent dashboard layout
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  // Configure system UI overlay style (transparent status bar)
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: Color(0xFF0A0E17),
    systemNavigationBarIconBrightness: Brightness.light,
  ));

  // Initialize core services before launch
  final privacyManager = PrivacyManager();
  await privacyManager.initialize();

  final notificationService = NotificationMediatorService();
  await notificationService.initialize();

  final biometricService = BiometricSyncService();

  runApp(
    ProviderScope(
      overrides: [
        // Inject initialized services into Riverpod
        biometricServiceProvider.overrideWithValue(biometricService),
        privacyManagerProvider.overrideWithValue(privacyManager),
        notificationMediatorProvider.overrideWithValue(notificationService),
      ],
      child: const SynapseApp(),
    ),
  );
}

/// Root application widget
class SynapseApp extends StatelessWidget {
  const SynapseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Synapse',
      debugShowCheckedModeBanner: false,
      theme: SynapseTheme.darkTheme,
      home: const SynapseDashboard(),
    );
  }
}

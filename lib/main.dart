import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite/sqflite.dart';
import 'package:wanderlog/data/auth_api_service.dart';
import 'package:wanderlog/data/credentials_storage.dart';
import 'package:wanderlog/data/database_service.dart';
import 'package:wanderlog/data/payment_gateway_api.dart';
import 'package:wanderlog/data/payment_gateway_service.dart';
import 'package:wanderlog/nav.dart';
import 'package:wanderlog/pages/auth/auth_provider.dart';
import 'package:wanderlog/pages/settings/merchant_config_provider.dart';
import 'package:wanderlog/theme.dart';

/// Main entry point for the application
///
/// This sets up:
/// - Provider state management (AuthProvider)
/// - go_router navigation
/// - Material 3 theming with light/dark modes
void main() {
  // Initialize sqflite for desktop platforms only
  // Web doesn't support SQLite, mobile uses native implementation
  if (!kIsWeb) {
    try {
      if (Platform.isLinux || Platform.isWindows || Platform.isMacOS) {
        // Desktop platforms need FFI
        sqfliteFfiInit();
        databaseFactory = databaseFactoryFfi;
      }
    } catch (e) {
      print('Platform check failed: $e');
    }
  }
  
  // Initialize the app
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Widget>(
      future: _buildApp(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return snapshot.data!;
        }
        return MaterialApp(
          home: Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          ),
        );
      },
    );
  }

  Future<Widget> _buildApp() async {
    // Initialize database first
    final database = DatabaseService();
    await database.initialize();
    
    // Create API client and credentials storage
    final api = PaymentGatewayApi();
    final storage = await CredentialsStorage.create();
    final authService = AuthApiService(api, storage);
    
    // Initialize with stored credentials
    await authService.initialize();

    // Create the service with the shared API instance
    final paymentService = PaymentGatewayService(api: api, database: database);

    return _AppContent(
      api: api,
      authService: authService,
      paymentService: paymentService,
      database: database,
    );
  }
}

class _AppContent extends StatelessWidget {
  final PaymentGatewayApi api;
  final AuthApiService authService;
  final PaymentGatewayService paymentService;
  final DatabaseService database;

  const _AppContent({
    required this.api,
    required this.authService,
    required this.paymentService,
    required this.database,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(authService)..initialize(),
        ),
        ChangeNotifierProvider(
          create: (_) => MerchantConfigProvider(api: api),
        ),
        // Provide PaymentGatewayService as a singleton so all pages use the same instance
        Provider<PaymentGatewayService>(
          create: (_) => paymentService,
        ),
      ],
      child: MaterialApp.router(
        title: 'RemPay',
        debugShowCheckedModeBanner: false,

        // Theme configuration
        theme: lightTheme,
        darkTheme: darkTheme,
        themeMode: ThemeMode.system,

        // Use context.go() or context.push() to navigate to the routes.
        routerConfig: AppRouter.router,
      ),
    );
  }
}

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons_500.dart';

import 'reminders.dart';
import 'screens/home.dart';
import 'screens/start.dart';
import 'state.dart';
import 'theme.dart';
import 'widgets.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (!demo) await Firebase.initializeApp();
  await initializeDateFormatting('es');
  Intl.defaultLocale = 'es';
  await initReminders();
  runApp(const ProaApp());
  await app.start();
}

class ProaApp extends StatelessWidget {
  const ProaApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'PROA',
    debugShowCheckedModeBanner: false,
    navigatorKey: navKey,
    scaffoldMessengerKey: messengerKey,
    theme: buildTheme(),
    locale: const Locale('es', 'CO'),
    supportedLocales: const [Locale('es', 'CO'), Locale('es')],
    localizationsDelegates: GlobalMaterialLocalizations.delegates,
    home: ListenableBuilder(
      listenable: app,
      builder: (context, _) => switch (app.phase) {
        Phase.loading => const Scaffold(
          body: Center(child: CircularProgressIndicator(color: C.green)),
        ),
        Phase.signedOut => const WelcomeScreen(),
        Phase.onboarding => const CreateProfileScreen(),
        Phase.ready => const MainShell(),
        Phase.error => const _LoadError(),
      },
    ),
  );
}

class _LoadError extends StatelessWidget {
  const _LoadError();
  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const IconTile(LucideIcons500.cloudRain, C.orange, size: 64),
            const SizedBox(height: 18),
            Text('No pudimos cargar tus datos', textAlign: TextAlign.center, style: title(26)),
            const SizedBox(height: 8),
            const Text(
              'Revisa tu conexión a internet e intenta de nuevo',
              textAlign: TextAlign.center,
              style: TextStyle(color: C.muted, fontSize: 16),
            ),
            const SizedBox(height: 24),
            Btn('Intentar de nuevo', onPressed: app.reload),
            TextButton(onPressed: app.signOut, child: const Text('Cerrar sesión')),
          ],
        ),
      ),
    ),
  );
}

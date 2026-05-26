import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'services/database_service.dart';
import 'services/sync_service.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://aiflerhtgvyfngnecslg.supabase.co',
    anonKey: 'sb_publishable_rUk3BUS69bVvmmPvqlOuow_1ieHTBbU',
  );

  await DatabaseService.instance.init();
  SyncService.instance.iniciarMonitor();

  runApp(const App());
}

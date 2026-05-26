import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/auth/login_screen.dart';
import 'screens/brix_atr_screen.dart';
import 'screens/im_pool_screen.dart';
import 'screens/tch_screen.dart';
import 'screens/amostras_screen.dart';
import 'screens/talhoes_screen.dart';
import 'screens/produtores_screen.dart';
import 'services/auth_service.dart';
import 'widgets/sync_status_badge.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Interpretation of Brix',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF003819),
          primary: const Color(0xFF003819),
        ),
        textTheme: GoogleFonts.outfitTextTheme(),
        useMaterial3: true,
      ),
      home: _AuthGate(),
    );
  }
}

class _AuthGate extends StatefulWidget {
  @override
  State<_AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<_AuthGate> {
  @override
  void initState() {
    super.initState();
    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final session = Supabase.instance.client.auth.currentSession;
    if (session == null) return const LoginScreen();
    return const MainScreen();
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final _screens = const [
    BrixAtrScreen(),
    ImPoolScreen(),
    TchScreen(),
    AmostrasScreen(),
    TalhoesScreen(),
    ProdutoresScreen(),
  ];

  final _labels = const [
    'Brix/ATR',
    'IM/Pool',
    'TCH/TAH',
    'Amostras',
    'Talhões',
    'Produtores',
  ];

  final _icons = const [
    Icons.science,
    Icons.water_drop,
    Icons.grass,
    Icons.list_alt,
    Icons.map,
    Icons.people,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF003819),
        title: Text(
          'Brix — ${_labels[_currentIndex]}',
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
        actions: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Center(child: SyncStatusBadge()),
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () async {
              await AuthService.instance.logout();
            },
          ),
        ],
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        backgroundColor: const Color(0xFF003819),
        selectedItemColor: const Color(0xFF8ac53a),
        unselectedItemColor: Colors.white54,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: const TextStyle(fontSize: 10),
        unselectedLabelStyle: const TextStyle(fontSize: 10),
        onTap: (i) => setState(() => _currentIndex = i),
        items: List.generate(
          _labels.length,
          (i) => BottomNavigationBarItem(
            icon: Icon(_icons[i]),
            label: _labels[i],
          ),
        ),
      ),
    );
  }
}

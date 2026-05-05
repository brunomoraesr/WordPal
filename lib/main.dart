import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'providers/app_provider.dart';
import 'screens/search_screen.dart';
import 'screens/word_detail_screen.dart';
import 'screens/notebook_screen.dart';
import 'screens/flashcards_screen.dart';
import 'screens/practice_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/onboarding_screen.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));

  runApp(
    ChangeNotifierProvider(
      create: (_) => AppProvider()..init(),
      child: const WordPalApp(),
    ),
  );
}

class WordPalApp extends StatelessWidget {
  const WordPalApp({super.key});

  @override
  Widget build(BuildContext context) {
    final fontSize = context.select<AppProvider, double>((p) => p.userProfile.fontSize);

    return MaterialApp(
      title: 'WordPal',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      locale: const Locale('pt', 'BR'),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('pt', 'BR'),
        Locale('en'),
      ],
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(
          textScaler: TextScaler.linear(fontSize),
        ),
        child: child!,
      ),
      initialRoute: '/splash',
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/splash':
            return MaterialPageRoute(
              builder: (_) => const SplashScreen(),
              settings: settings,
            );
          case '/onboarding':
            return MaterialPageRoute(
              builder: (_) => const OnboardingScreen(),
              settings: settings,
            );
          case '/':
            return MaterialPageRoute(
              builder: (_) => const MainShell(),
              settings: settings,
            );
          case '/notebook':
            return MaterialPageRoute(
              builder: (_) => const MainShell(initialIndex: 1),
              settings: settings,
            );
          case '/word':
            return PageRouteBuilder(
              settings: settings,
              pageBuilder: (_, animation, __) => const WordDetailScreen(),
              transitionsBuilder: (_, animation, __, child) {
                return SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(1, 0),
                    end: Offset.zero,
                  ).animate(CurvedAnimation(
                      parent: animation, curve: Curves.easeOutCubic)),
                  child: child,
                );
              },
            );
          case '/flashcards':
            return PageRouteBuilder(
              settings: settings,
              pageBuilder: (_, animation, __) => const FlashcardsScreen(),
              transitionsBuilder: (_, animation, __, child) {
                return SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 1),
                    end: Offset.zero,
                  ).animate(CurvedAnimation(
                      parent: animation, curve: Curves.easeOutCubic)),
                  child: child,
                );
              },
            );
          default:
            return MaterialPageRoute(builder: (_) => const MainShell());
        }
      },
    );
  }
}

class MainShell extends StatefulWidget {
  final int initialIndex;

  const MainShell({super.key, this.initialIndex = 0});

  @override
  State<MainShell> createState() => MainShellState();
}

class MainShellState extends State<MainShell> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  void setTab(int i) => setState(() => _currentIndex = i);

  @override
  Widget build(BuildContext context) {
    final screens = [
      const SearchScreen(),
      NotebookScreen(onOpenFlashcards: () =>
          Navigator.pushNamed(context, '/flashcards')),
      const PracticeScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.bgRaised,
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                _NavItem(
                  icon: Icons.search_rounded,
                  label: 'Buscar',
                  isActive: _currentIndex == 0,
                  onTap: () => setTab(0),
                ),
                _NavItem(
                  icon: Icons.menu_book_rounded,
                  label: 'Caderno',
                  isActive: _currentIndex == 1,
                  onTap: () => setTab(1),
                ),
                _NavItem(
                  icon: Icons.quiz_rounded,
                  label: 'Prática',
                  isActive: _currentIndex == 2,
                  onTap: () => setTab(2),
                ),
                _NavItem(
                  icon: Icons.person_rounded,
                  label: 'Perfil',
                  isActive: _currentIndex == 3,
                  onTap: () => setTab(3),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                size: 24,
                color: isActive ? AppColors.primary : AppColors.inkMuted),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight:
                    isActive ? FontWeight.w700 : FontWeight.w500,
                color: isActive ? AppColors.primary : AppColors.inkMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

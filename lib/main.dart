import 'package:flutter/material.dart';
import 'package:tech_smash/screens/admin/scoreCount.dart';
import 'package:tech_smash/screens/auth/login.dart';
import 'package:tech_smash/screens/user/userpage.dart';
import 'package:tech_smash/widget/wrapper.dart';
import 'screens/home_page.dart';
import 'screens/team_registration_page.dart';
import 'screens/admin/match_scheduler_page.dart';
import 'screens/admin/score_entry_page.dart';
import 'screens/leaderboard_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'config/firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const BadmintonEventApp());
}

class BadmintonEventApp extends StatelessWidget {
  const BadmintonEventApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Badminton Event Manager',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const AuthWrapper(),
        '/homepage': (context) => const HomePage(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const TeamRegistrationPage(),
        '/schedule': (context) => const TournamentBracketPage(),
        '/score': (context) => const ScoreEntryPage(),
        '/leaderboard': (context) => const LeaderboardPage(),
        '/scoreCount': (context) => const CounterPage(),
        '/userpage': (context) => const Userpage(),
      },
    );
  }
}

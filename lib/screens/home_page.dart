// ignore_for_file: library_private_types_in_public_api, unused_import, prefer_const_constructors

import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'dart:async';
import 'package:simple_animations/simple_animations.dart';
import 'package:tech_smash/services/auth_service.dart';

class ParticlePainter extends CustomPainter {
  final List<Particle> particles;
  ParticlePainter(this.particles);

  @override
  void paint(Canvas canvas, Size size) {
    for (var particle in particles) {
      final paint = Paint()
        ..color = particle.color.withOpacity(particle.opacity)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(particle.position, particle.size, paint);
    }
  }

  @override
  bool shouldRepaint(ParticlePainter oldDelegate) => true;
}

class Particle {
  Offset position;
  Color color;
  double size;
  double opacity;
  double speed;
  double angle;

  Particle({
    required this.position,
    required this.color,
    required this.size,
    required this.opacity,
    required this.speed,
    required this.angle,
  });

  void update(Size size) {
    position = Offset(
      position.dx + math.cos(angle) * speed,
      position.dy + math.sin(angle) * speed,
    );

    if (position.dx < 0 || position.dx > size.width) {
      angle = math.pi - angle;
    }
    if (position.dy < 0 || position.dy > size.height) {
      angle = -angle;
    }
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  final List<Particle> particles = [];
  final math.Random random = math.Random();
  late AnimationController _buttonController;
  late AnimationController _titleController;
  late Animation<double> _titleScale;
  late Animation<double> _titleGlow;
  int selectedIndex = -1;
  final AuthService _authService = AuthService();

  final List<MenuOption> menuOptions = [
    MenuOption(
      title: 'Team Registration',
      icon: Icons.group_add,
      route: '/register',
      color: Colors.blue,
      description: 'Register your team for the tournament',
    ),
    MenuOption(
      title: 'Match Scheduler',
      icon: Icons.schedule,
      route: '/schedule',
      color: Colors.purple,
      description: 'View and manage match schedules',
    ),
    MenuOption(
      title: 'Enter Scores',
      icon: Icons.edit,
      route: '/score',
      color: Colors.orange,
      description: 'Update match scores and results',
    ),
    MenuOption(
      title: 'Leaderboard',
      icon: Icons.leaderboard,
      route: '/leaderboard',
      color: Colors.green,
      description: 'Track tournament rankings',
    ),
    MenuOption(
      title: 'Score',
      icon: Icons.countertops,
      route: '/scoreCount',
      color: Colors.teal,
      description: 'Enter the scores',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _initializeParticles();
    _setupAnimations();
    _startParticleAnimation();
  }

  void _initializeParticles() {
    for (int i = 0; i < 50; i++) {
      particles.add(
        Particle(
          position: Offset(
            random.nextDouble() * 400,
            random.nextDouble() * 800,
          ),
          color: Colors.white,
          size: random.nextDouble() * 3 + 1,
          opacity: random.nextDouble() * 0.6 + 0.2,
          speed: random.nextDouble() * 2 + 0.5,
          angle: random.nextDouble() * 2 * math.pi,
        ),
      );
    }
  }

  void _setupAnimations() {
    _buttonController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _titleController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);

    _titleScale = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(
        parent: _titleController,
        curve: Curves.easeInOut,
      ),
    );

    _titleGlow = Tween<double>(begin: 0, end: 10).animate(
      CurvedAnimation(
        parent: _titleController,
        curve: Curves.easeInOut,
      ),
    );
  }

  void _startParticleAnimation() {
    Timer.periodic(const Duration(milliseconds: 16), (timer) {
      if (mounted) {
        setState(() {
          for (var particle in particles) {
            particle.update(const Size(400, 800));
          }
        });
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _buttonController.dispose();
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(222, 13, 72, 161),
        automaticallyImplyLeading: false,
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 16.0), // Add space from the right
            child: IconButton(
              onPressed: _authService.signOut,
              icon: Icon(
                Icons.logout_rounded,
                color: Colors.white, // Set the icon color directly
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Background with particles
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF1a237e),
                  Color(0xFF0d47a1),
                  Color(0xFF01579b),
                ],
              ),
            ),
            child: CustomPaint(
              painter: ParticlePainter(particles),
              child: Container(),
            ),
          ),
          // Main content
          SafeArea(
            child: Column(
              children: [
                const SizedBox(
                  height: 50,
                ),
                // Animated title
                AnimatedBuilder(
                  animation: _titleController,
                  builder: (context, child) {
                    return Container(
                      padding: const EdgeInsets.all(10),
                      child: Transform.scale(
                        scale: _titleScale.value,
                        child: Text(
                          'Tech Smash',
                          style: TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                color: Colors.blue.withOpacity(0.5),
                                blurRadius: _titleGlow.value,
                                offset: const Offset(0, 0),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),

                const Text(
                  'Badminton Tournament',
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.white70,
                    letterSpacing: 2,
                  ),
                ),

                const SizedBox(height: 20),

                // Menu options
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: menuOptions.length,
                    itemBuilder: (context, index) {
                      return TweenAnimationBuilder<double>(
                        duration: const Duration(milliseconds: 500),
                        tween: Tween(begin: 0.0, end: 1.0),
                        curve: Curves.easeOutQuint,
                        builder: (context, value, child) {
                          return Transform.translate(
                            offset: Offset(0, 50 * (1 - value)),
                            child: Opacity(
                              opacity: value,
                              child: _buildMenuCard(menuOptions[index], index),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuCard(MenuOption option, int index) {
    bool isSelected = selectedIndex == index;

    return GestureDetector(
      onTapDown: (_) => setState(() => selectedIndex = index),
      onTapUp: (_) {
        setState(() => selectedIndex = -1);
        Navigator.pushNamed(context, option.route);
      },
      onTapCancel: () => setState(() => selectedIndex = -1),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 20),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected
              ? option.color.withOpacity(0.2)
              : Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? option.color : Colors.white.withOpacity(0.2),
            width: 2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: option.color.withOpacity(0.3),
                    blurRadius: 20,
                    spreadRadius: 2,
                  )
                ]
              : [],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: option.color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                option.icon,
                color: Colors.white,
                size: 30,
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    option.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    option.description,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: Colors.white70,
            ),
          ],
        ),
      ),
    );
  }
}

class MenuOption {
  final String title;
  final IconData icon;
  final String route;
  final Color color;
  final String description;

  MenuOption({
    required this.title,
    required this.icon,
    required this.route,
    required this.color,
    required this.description,
  });
}

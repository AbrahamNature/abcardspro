import 'package:flutter/material.dart';
import 'screens/signupscreen1.dart';
import 'screens/loginscreen2.dart';

void main() => runApp(const ABCardsProApp());

class Palette {
  static const night = Color.fromARGB(255, 26, 11, 238);
  static const paper = Color.fromARGB(255, 227, 227, 228);
  static const marigold = Color.fromARGB(255, 130, 248, 20);
  static const teal = Color.fromARGB(255, 149, 241, 232);
  static const rose = Color.fromARGB(255, 248, 24, 24);
}

class ABCardsProApp extends StatelessWidget {
  const ABCardsProApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ABCardsPro',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color.fromARGB(255, 9, 6, 44),
        colorScheme: ColorScheme.fromSeed(
          seedColor:  Color.fromARGB(255, 73, 248, 20),
          brightness: Brightness.dark,
        ),
      ),
      home:  WelcomeScreen(),
    );
  }
}

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _fan = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  );
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    if (MediaQuery.disableAnimationsOf(context)) {
      _fan.value = 1;
    } else {
      _fan.forward();
    }
  }

  @override
  void dispose() {
    _fan.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
               SizedBox(height: 24),
              Text(
                'ABCardsPro',
                style: text.titleMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                  color:  Color.fromARGB(232, 20, 248, 20),
                ),
              ),
              Expanded(
                child: Center(
                  child: AnimatedBuilder(
                    animation: CurvedAnimation(
                      parent: _fan,
                      curve: Curves.easeOutCubic,
                    ),
                    builder: (context, _) {
                      final t = Curves.easeOutCubic.transform(_fan.value);
                      return SizedBox(
                        height: 280,
                        width: double.infinity,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            _fanned(t, -0.24, -70,  Color.fromARGB(255, 77, 236, 220), 'Gaming', '\$25'),
                            _fanned(t, 0.24, 70, Palette.rose, 'Food', '\$50'),
                            _fanned(t, 0.0, 0,  Color.fromARGB(207, 126, 233, 26), 'Shopping', '\$100'),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
              Text(
                'Buy, sell and trade gift cards.',
                style: text.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  height: 1.15,
                ),
              ),
               SizedBox(height: 15),
              Text(
                'Turn cards you don\'t use into money in your wallet.',
                style: text.bodyLarge?.copyWith(
                  color: Palette.paper.withOpacity(0.75),
                ),
              ),
               SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: Palette.marigold,
                    foregroundColor: Palette.night,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => SignupScreen()),
                  ),
                  child: Text(
                    'Create account',
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                  ),
                ),
              ),
               SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Palette.paper,
                    side: BorderSide(color: Palette.paper.withOpacity(0.35)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => LoginScreen()),
                  ),
                  child: Text(
                    'Log in',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                  ),
                ),
              ),
               SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _fanned(
    double t,
    double angle,
    double dx,
    Color color,
    String label,
    String amount,
  ) {
    return Transform.translate(
      offset: Offset(dx * t, 0),
      child: Transform.rotate(
        angle: angle * t,
        child: GiftCardTile(color: color, label: label, amount: amount),
      ),
    );
  }
}

class GiftCardTile extends StatelessWidget {
  const GiftCardTile({
    super.key,
    required this.color,
    required this.label,
    required this.amount,
  });

  final Color color;
  final String label;
  final String amount;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      height: 128,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Color(0x66000000),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style:  TextStyle(
              color: Palette.night,
              fontWeight: FontWeight.w700,
              fontSize: 15,
            ),
          ),
          Text(
            amount,
            style: TextStyle(
              color:  Color.fromARGB(255, 12, 4, 126),
              fontWeight: FontWeight.w900,
              fontSize: 30,
            ),
          ),
        ],
      ),
    );
  }
}
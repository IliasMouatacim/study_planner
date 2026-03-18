import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'dart:math';
import '../widgets/custom_app_bar.dart';

class DailyQuotesScreen extends StatefulWidget {
  const DailyQuotesScreen({super.key});

  @override
  State<DailyQuotesScreen> createState() => _DailyQuotesScreenState();
}

class _DailyQuotesScreenState extends State<DailyQuotesScreen> {
  final List<Map<String, String>> _quotes = const [
    {
      'quote': 'Success is the sum of small efforts, repeated day in and day out.',
      'author': 'Robert Collier',
    },
    {
      'quote': 'The secret of getting ahead is getting started.',
      'author': 'Mark Twain',
    },
    {
      'quote': 'Don’t watch the clock; do what it does. Keep going.',
      'author': 'Sam Levenson',
    },
    {
      'quote': 'It always seems impossible until it’s done.',
      'author': 'Nelson Mandela',
    },
    {
      'quote': 'The future depends on what you do today.',
      'author': 'Mahatma Gandhi',
    },
    {
      'quote': 'You don’t have to be great to start, but you have to start to be great.',
      'author': 'Zig Ziglar',
    },
  ];

  int _currentIndex = 0;
  final Random _random = Random();

  void _showNewQuote() {
    setState(() {
      int newIndex;
      do {
        newIndex = _random.nextInt(_quotes.length);
      } while (newIndex == _currentIndex && _quotes.length > 1);
      _currentIndex = newIndex;
    });
  }

  @override
  void initState() {
    super.initState();
    _currentIndex = _random.nextInt(_quotes.length);
  }

  @override
  Widget build(BuildContext context) {
    final quote = _quotes[_currentIndex];
    // Import CustomAppBar
    // ignore: unused_import
    return Scaffold(
      extendBody: true,
      appBar: const CustomAppBar(
        title: 'Daily Quotes',
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Theme.of(context).colorScheme.primary.withOpacity(0.07),
              Theme.of(context).colorScheme.secondary.withOpacity(0.04),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface.withOpacity(0.85),
                    borderRadius: BorderRadius.circular(32),
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.08),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 28),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(FontAwesomeIcons.quoteLeft, size: 60, color: Theme.of(context).colorScheme.primary),
                      const SizedBox(height: 32),
                      Text(
                        '"${quote['quote']}"',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        '- ${quote['author']}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                ElevatedButton.icon(
                  onPressed: _showNewQuote,
                  icon: const Icon(FontAwesomeIcons.rotate),
                  label: const Text('New Quote'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 18),
                    textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                    elevation: 8,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

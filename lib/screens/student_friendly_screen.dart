import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../widgets/custom_app_bar.dart';
import 'student_food_screen.dart';
import 'student_todo_screen.dart';

class StudentFriendlyScreen extends StatelessWidget {
  const StudentFriendlyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final categories = _buildCategories();

    return Scaffold(
      extendBody: true,
      appBar: const CustomAppBar(
        title: 'Student Friendly',
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        FontAwesomeIcons.graduationCap,
                        color: Theme.of(context).colorScheme.primary,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Student Toolkit',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Practical categories to help you study better, spend less, and stay healthy during the semester.',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          ...categories.map(
            (category) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _CategoryCard(
                icon: category.icon,
                title: category.title,
                subtitle: category.subtitle,
                onTap: () => category.onTap(context),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<_BuiltCategory> _buildCategories() {
    return [
      _CategoryConfig(
        icon: FontAwesomeIcons.listCheck,
        title: 'To-Do List',
        subtitle: 'Personal student checklist',
        onTapBuilder: (context) => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const StudentTodoScreen()),
        ),
      ),
      _CategoryConfig(
        icon: FontAwesomeIcons.bowlFood,
        title: 'Affordable Recipes',
        subtitle: 'Easy meals for students',
        onTapBuilder: (context) => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const StudentFoodScreen()),
        ),
      ),
      _CategoryConfig(
        icon: FontAwesomeIcons.piggyBank,
        title: 'Budget Tips',
        subtitle: 'Save money without killing your social life',
        onTapBuilder: (context) => _openContent(
          context,
          title: 'Budget Tips',
          sections: const [
            _ContentSection(
              title: 'Monthly Survival Plan',
              items: [
                'Use a 50/30/20 student version: 50% needs, 30% flexible, 20% emergency or debt.',
                'Set weekly cash limits for food and transport to avoid end-of-month panic.',
                'Track 3 spending categories only: food, commute, random impulse buys.',
              ],
            ),
            _ContentSection(
              title: 'Low-Effort Savings',
              items: [
                'Buy store brands for basics: rice, pasta, oats, yogurt.',
                'Cook 2 base meals and repeat them instead of daily new recipes.',
                'Use student discounts: software, gym, transport, cinema, and subscriptions.',
              ],
            ),
            _ContentSection(
              title: 'Avoid Money Traps',
              items: [
                'Do not keep card details saved in shopping apps.',
                'Wait 24 hours before buying anything non-essential.',
                'Split wants into a wishlist and buy only one item per month.',
              ],
            ),
          ],
        ),
      ),
      _CategoryConfig(
        icon: FontAwesomeIcons.brain,
        title: 'Study Lifestyle',
        subtitle: 'Habits that protect your grades and energy',
        onTapBuilder: (context) => _openContent(
          context,
          title: 'Study Lifestyle',
          sections: const [
            _ContentSection(
              title: 'Weekly Rhythm',
              items: [
                'Plan 3 deep work blocks per week for your hardest subject.',
                'Use a Sunday 20-minute reset: check deadlines and pick top 5 tasks.',
                'Keep one rest half-day weekly to prevent burnout.',
              ],
            ),
            _ContentSection(
              title: 'Study Quality',
              items: [
                'Study in 25-50 minute blocks with short breaks.',
                'Test yourself more than rereading (active recall).',
                'Finish sessions with a 3-line summary so revision is easier.',
              ],
            ),
            _ContentSection(
              title: 'Sleep and Recovery',
              items: [
                'Target consistent sleep and wake times even during exams.',
                'Stop caffeine at least 8 hours before sleep.',
                'If exhausted, take a 20-minute nap instead of doom scrolling.',
              ],
            ),
          ],
        ),
      ),
      _CategoryConfig(
        icon: FontAwesomeIcons.bookOpenReader,
        title: 'Exam Week Survival',
        subtitle: 'Stay sharp under pressure',
        onTapBuilder: (context) => _openContent(
          context,
          title: 'Exam Week Survival',
          sections: const [
            _ContentSection(
              title: '7 Days Before',
              items: [
                'Make a topic checklist and mark weak areas first.',
                'Practice under timed conditions at least once per course.',
                'Prepare all logistics: exam room, transport, required documents.',
              ],
            ),
            _ContentSection(
              title: 'Night Before',
              items: [
                'Do light review only: formulas, key frameworks, summary notes.',
                'Pack pens, charger, water, and snack before sleeping.',
                'Sleep is a performance tool, not optional.',
              ],
            ),
            _ContentSection(
              title: 'Exam Day',
              items: [
                'Eat something simple with protein and carbs.',
                'Start by scanning all questions and allocating time.',
                'If stuck, skip and return; do not panic on one question.',
              ],
            ),
          ],
        ),
      ),
      _CategoryConfig(
        icon: FontAwesomeIcons.bolt,
        title: 'Focus and Energy',
        subtitle: 'Quick fixes for low-motivation days',
        onTapBuilder: (context) => _openContent(
          context,
          title: 'Focus and Energy',
          sections: const [
            _ContentSection(
              title: '5-Minute Reset',
              items: [
                'Drink water, stand up, and open a window.',
                'Write one tiny next action: "read page 12", not "study biology".',
                'Start a 10-minute timer; momentum usually follows.',
              ],
            ),
            _ContentSection(
              title: 'Environment Tweaks',
              items: [
                'Keep only one subject on desk at a time.',
                'Use website blockers during deep work.',
                'Put phone physically out of reach while studying.',
              ],
            ),
            _ContentSection(
              title: 'When You Feel Behind',
              items: [
                'Pick 3 highest-impact tasks today and ignore the rest.',
                'Use "good enough" progress instead of perfection.',
                'Ask classmates or tutors early; do not wait until crisis mode.',
              ],
            ),
          ],
        ),
      ),
      _CategoryConfig(
        icon: FontAwesomeIcons.fileCircleCheck,
        title: 'Admin and Career Basics',
        subtitle: 'Simple systems for internships and opportunities',
        onTapBuilder: (context) => _openContent(
          context,
          title: 'Admin and Career Basics',
          sections: const [
            _ContentSection(
              title: 'Documents Folder',
              items: [
                'Keep one cloud folder: CV, transcript, ID scan, recommendation letters.',
                'Use clear filenames like CV_Name_2026.pdf.',
                'Back up key files in two places.',
              ],
            ),
            _ContentSection(
              title: 'Internship Workflow',
              items: [
                'Apply weekly, not randomly once a semester.',
                'Track applications in a simple sheet: company, date, status, follow-up.',
                'Customize first 3 lines of your CV and cover email each time.',
              ],
            ),
            _ContentSection(
              title: 'Networking for Introverts',
              items: [
                'Send short thank-you messages after events or talks.',
                'Ask one useful question instead of trying to impress.',
                'Build relationships slowly; consistency beats intensity.',
              ],
            ),
          ],
        ),
      ),
    ].map((c) => c.build()).toList();
  }

  void _openContent(
    BuildContext context, {
    required String title,
    required List<_ContentSection> sections,
  }) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _StudentContentScreen(
          title: title,
          sections: sections,
        ),
      ),
    );
  }
}

class _StudentContentScreen extends StatelessWidget {
  const _StudentContentScreen({
    required this.title,
    required this.sections,
  });

  final String title;
  final List<_ContentSection> sections;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      appBar: CustomAppBar(
        title: title,
        showBack: true,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: sections.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final section = sections[index];
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    section.title,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  ...section.items.map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Text('- $item'),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        leading: Icon(icon),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}

class _CategoryConfig {
  _CategoryConfig({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTapBuilder,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final void Function(BuildContext context) onTapBuilder;

  _BuiltCategory build() {
    return _BuiltCategory(
      icon: icon,
      title: title,
      subtitle: subtitle,
      onTap: onTapBuilder,
    );
  }
}

class _BuiltCategory {
  _BuiltCategory({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final void Function(BuildContext context) onTap;
}

class _ContentSection {
  const _ContentSection({
    required this.title,
    required this.items,
  });

  final String title;
  final List<String> items;
}

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../widgets/custom_app_bar.dart';

class StudentFoodScreen extends StatelessWidget {
  const StudentFoodScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      appBar: const CustomAppBar(
        title: 'Student-Friendly Food',
        showBack: true,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _recipes.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final recipe = _recipes[index];
          return Card(
            child: ExpansionTile(
              leading: const Icon(FontAwesomeIcons.utensils),
              title: Text(recipe.title),
              subtitle: Text('${recipe.timeMinutes} min - ${recipe.costLevel}'),
              childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              children: [
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Ingredients',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 6),
                ...recipe.ingredients.map(
                  (item) => Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text('- $item'),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Steps',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 6),
                ...recipe.steps.asMap().entries.map(
                  (entry) => Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text('${entry.key + 1}. ${entry.value}'),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _Recipe {
  const _Recipe({
    required this.title,
    required this.timeMinutes,
    required this.costLevel,
    required this.ingredients,
    required this.steps,
  });

  final String title;
  final int timeMinutes;
  final String costLevel;
  final List<String> ingredients;
  final List<String> steps;
}

const List<_Recipe> _recipes = [
  _Recipe(
    title: 'One-Pan Garlic Pasta',
    timeMinutes: 15,
    costLevel: 'Budget',
    ingredients: [
      'Pasta',
      '2 garlic cloves',
      'Olive oil or butter',
      'Salt, pepper, chili flakes',
      'Optional: grated cheese',
    ],
    steps: [
      'Boil pasta and reserve some pasta water.',
      'Saute garlic in oil for 1 minute.',
      'Add pasta, seasoning, and a splash of pasta water.',
      'Mix until glossy and serve.',
    ],
  ),
  _Recipe(
    title: 'Egg Fried Rice',
    timeMinutes: 12,
    costLevel: 'Budget',
    ingredients: [
      'Cooked rice (best if cold)',
      '2 eggs',
      'Soy sauce',
      'Frozen mixed veggies',
      'Oil',
    ],
    steps: [
      'Scramble eggs in a pan and set aside.',
      'Stir-fry veggies for 2 to 3 minutes.',
      'Add rice, eggs, and soy sauce.',
      'Cook until hot and slightly crispy.',
    ],
  ),
  _Recipe(
    title: 'Tuna Chickpea Salad',
    timeMinutes: 10,
    costLevel: 'Low',
    ingredients: [
      '1 can tuna',
      '1 can chickpeas',
      'Lemon juice',
      'Olive oil',
      'Salt, pepper, parsley',
    ],
    steps: [
      'Drain tuna and chickpeas.',
      'Mix with lemon juice and olive oil.',
      'Season with salt and pepper.',
      'Serve as salad or wrap filling.',
    ],
  ),
  _Recipe(
    title: 'Microwave Oat Bowl',
    timeMinutes: 5,
    costLevel: 'Very Low',
    ingredients: [
      'Oats',
      'Milk or water',
      'Banana or apple',
      'Peanut butter (optional)',
      'Cinnamon',
    ],
    steps: [
      'Microwave oats with milk or water for 2 to 3 minutes.',
      'Top with fruit and cinnamon.',
      'Add peanut butter for extra calories and protein.',
    ],
  ),
  _Recipe(
    title: 'Bean and Cheese Quesadilla',
    timeMinutes: 8,
    costLevel: 'Low',
    ingredients: [
      'Tortillas',
      'Canned beans',
      'Shredded cheese',
      'Salsa (optional)',
    ],
    steps: [
      'Spread beans and cheese on half of a tortilla.',
      'Fold and toast on pan until golden.',
      'Slice and serve with salsa.',
    ],
  ),
  _Recipe(
    title: 'Greek Yogurt Power Snack',
    timeMinutes: 3,
    costLevel: 'Low',
    ingredients: [
      'Greek yogurt',
      'Honey or jam',
      'Oats or granola',
      'Fruit',
    ],
    steps: [
      'Add yogurt to bowl.',
      'Top with oats and fruit.',
      'Drizzle honey or jam and eat.',
    ],
  ),
];

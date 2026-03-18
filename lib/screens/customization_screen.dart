import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import '../main.dart';
import '../widgets/custom_app_bar.dart';

class CustomizationScreen extends StatefulWidget {
  const CustomizationScreen({super.key});

  @override
  State<CustomizationScreen> createState() => _CustomizationScreenState();
}

class _CustomizationScreenState extends State<CustomizationScreen> {
  static const List<Color> _colorPalette = [
    Colors.teal,
    Colors.deepPurple,
    Colors.indigo,
    Colors.blue,
    Colors.cyan,
    Colors.green,
    Colors.lime,
    Colors.amber,
    Colors.orange,
    Colors.deepOrange,
    Colors.red,
    Colors.pink,
    Colors.purple,
    Color(0xFF6C63FF), // Default primary
    Color(0xFF00C9A7), // Default secondary
    Colors.brown,
  ];

  void _showColorPicker(String label, Color currentColor, ValueChanged<Color> onChanged) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(label),
        content: SizedBox(
          width: 280,
          child: Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _colorPalette.map((color) {
              final isSelected = color.value == currentColor.value;
              return GestureDetector(
                onTap: () {
                  onChanged(color);
                  Navigator.pop(context);
                },
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? Colors.white : Colors.grey.shade300,
                      width: isSelected ? 3 : 1,
                    ),
                    boxShadow: isSelected
                        ? [BoxShadow(color: color.withOpacity(0.5), blurRadius: 8)]
                        : [],
                  ),
                  child: isSelected
                      ? const Icon(Icons.check, color: Colors.white, size: 22)
                      : null,
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      extendBody: true,
      appBar: const CustomAppBar(
        title: 'Customization',
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
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 28),
          children: [
            _glassCard(
              child: SwitchListTile(
                title: const Text('Dark Mode', style: TextStyle(fontWeight: FontWeight.bold)),
                secondary: const Icon(Icons.dark_mode),
                value: themeProvider.darkMode,
                onChanged: (val) {
                  themeProvider.setDarkMode(val);
                },
              ),
            ),
            const SizedBox(height: 20),
            _glassCard(
              child: ListTile(
                leading: Icon(FontAwesomeIcons.palette, color: themeProvider.primaryColor),
                title: const Text('Primary Color', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text('Tap to change'),
                onTap: () {
                  _showColorPicker('Primary Color', themeProvider.primaryColor, (color) {
                    themeProvider.setPrimaryColor(color);
                  });
                },
                trailing: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: themeProvider.primaryColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            _glassCard(
              child: ListTile(
                leading: Icon(FontAwesomeIcons.droplet, color: themeProvider.secondaryColor),
                title: const Text('Secondary Color', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text('Tap to change'),
                onTap: () {
                  _showColorPicker('Secondary Color', themeProvider.secondaryColor, (color) {
                    themeProvider.setSecondaryColor(color);
                  });
                },
                trailing: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: themeProvider.secondaryColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            _glassCard(
              child: ListTile(
                leading: Icon(FontAwesomeIcons.bars, color: themeProvider.appBarColor),
                title: const Text('App Bar Color', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text('Tap to change'),
                onTap: () {
                  _showColorPicker('App Bar Color', themeProvider.appBarColor, (color) {
                    themeProvider.setAppBarColor(color);
                  });
                },
                trailing: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: themeProvider.appBarColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            _glassCard(
              child: ListTile(
                leading: const Icon(FontAwesomeIcons.square),
                title: const Text('Card Shape', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text('Rounded or Square corners'),
                trailing: DropdownButton<String>(
                  value: themeProvider.cardShape,
                  borderRadius: BorderRadius.circular(16),
                  items: const [
                    DropdownMenuItem(value: 'Rounded', child: Text('Rounded')),
                    DropdownMenuItem(value: 'Square', child: Text('Square')),
                  ],
                  onChanged: (value) {
                    if (value != null) themeProvider.setCardShape(value);
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),
            _glassCard(
              child: ListTile(
                leading: const Icon(FontAwesomeIcons.bars),
                title: const Text('App Bar Style', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text('Classic or Modern'),
                trailing: DropdownButton<String>(
                  value: themeProvider.appBarStyle,
                  borderRadius: BorderRadius.circular(16),
                  items: const [
                    DropdownMenuItem(value: 'Classic', child: Text('Classic')),
                    DropdownMenuItem(value: 'Modern', child: Text('Modern')),
                  ],
                  onChanged: (value) {
                    if (value != null) themeProvider.setAppBarStyle(value);
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),
            _glassCard(
              child: ListTile(
                leading: const Icon(FontAwesomeIcons.tablets),
                title: const Text('App Bar Shape', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text('Rectangle or Pill'),
                trailing: DropdownButton<String>(
                  value: themeProvider.appBarShape,
                  borderRadius: BorderRadius.circular(16),
                  items: const [
                    DropdownMenuItem(value: 'Rectangle', child: Text('Rectangle')),
                    DropdownMenuItem(value: 'Pill', child: Text('Pill')),
                  ],
                  onChanged: (value) {
                    if (value != null) themeProvider.setAppBarShape(value);
                  },
                ),
              ),
            ),
            // Background image option removed
          ],
        ),
      ),
    );

  }

  Widget _glassCard({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withOpacity(0.85),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
  }
}

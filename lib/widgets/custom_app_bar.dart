import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../main.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  static const double _compactHeight = 44;

  final String title;
  final List<Widget>? actions;
  final PreferredSizeWidget? bottom;
  final bool centerTitle;
  final bool showBack;

  const CustomAppBar({
    super.key,
    required this.title,
    this.actions,
    this.bottom,
    this.centerTitle = true,
    this.showBack = false,
  });

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isPill = themeProvider.appBarShape == 'Pill';
    final topInset = MediaQuery.of(context).viewPadding.top;
    final pillTopSpacing = isPill ? (topInset + 6) : 0.0;
    final toolbarHeight = Theme.of(context).appBarTheme.toolbarHeight ?? _compactHeight;
    final bgColor = Theme.of(context).appBarTheme.backgroundColor ?? themeProvider.appBarColor;
    final elevation = Theme.of(context).appBarTheme.elevation ?? 4.0;
    const double titleOffsetY = 0;

    return PreferredSize(
      preferredSize: Size.fromHeight(
        toolbarHeight + (bottom?.preferredSize.height ?? 0) + pillTopSpacing,
      ),
      child: Container(
        margin: isPill
            ? EdgeInsets.only(top: pillTopSpacing, left: 12, right: 12)
            : null,
        decoration: isPill
            ? const BoxDecoration(
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(20),
                  top: Radius.circular(14),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 6,
                    offset: Offset(0, 1),
                  ),
                ],
              )
            : null,
        clipBehavior: isPill ? Clip.antiAlias : Clip.none,
        child: AppBar(
          primary: !isPill,
          automaticallyImplyLeading: showBack,
          toolbarHeight: toolbarHeight,
          backgroundColor: bgColor,
          shape: isPill ? const StadiumBorder() : null,
          elevation: elevation,
          centerTitle: centerTitle,
          titleSpacing: 12,
          title: Transform.translate(
            offset: const Offset(0, titleOffsetY),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
          actions: actions,
          bottom: bottom,
        ),
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(_compactHeight + (bottom?.preferredSize.height ?? 0));
}

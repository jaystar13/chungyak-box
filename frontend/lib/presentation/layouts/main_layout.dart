import 'package:chungyak_box/presentation/widgets/app_drawer.dart';
import 'package:flutter/material.dart';

class MainLayout extends StatelessWidget {
  final Widget child;
  final Widget? bottomNavigationBar;
  final String? title;

  const MainLayout({
    super.key,
    required this.child,
    this.bottomNavigationBar,
    this.title,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: title != null ? Text(title!) : null,
        centerTitle: true,
        elevation: 2,
        backgroundColor: colors.primaryContainer,
        actions: [
          Builder(
            builder: (context) {
              return IconButton(
                onPressed: () {
                  Scaffold.of(context).openEndDrawer();
                },
                icon: Icon(Icons.menu, color: colors.onPrimaryContainer),
              );
            },
          ),
        ],
      ),
      endDrawer: const AppDrawer(),
      body: child,
      bottomNavigationBar: bottomNavigationBar,
    );
  }
}

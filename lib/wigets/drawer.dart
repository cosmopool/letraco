import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:letraco/game_controller.dart';
import 'package:letraco/wigets/dialogs.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({
    super.key,
    required this.controller,
  });

  static const ident = 24.0;
  final GameController controller;

  @override
  Widget build(BuildContext context) {
    return NavigationDrawer(
      children: [
        const SizedBox(height: 4),
        const DrawerSection(title: 'Menu'),
        MenuItem(
          title: 'Novo jogo',
          icon: Icons.restart_alt_rounded,
          onTap: () => _showNewGameDialog(context),
        ),
        const Divider(thickness: 1, indent: ident, endIndent: ident),
        MenuItem(
          title: 'Como jogar',
          icon: Icons.help_outline_rounded,
          onTap: () => Navigator.of(context).pushNamed('/instructions'),
        ),
        if (kDebugMode)
          MenuItem(
            title: 'Show all words DEBUG',
            icon: Icons.remove_red_eye,
            onTap: () {
              controller.switchWordsVisibility();
              Navigator.of(context).pop();
            },
          ),
      ],
    );
  }

  Future<void> _showNewGameDialog(BuildContext context) {
    return showTwoButtonsDialog(
      context,
      title: 'Iniciar um novo jogo?',
      content: 'Ao iniciar um novo jogo você perderá todo o '
          'progresso atual, deseja continuar?',
      onPressedOk: () {
        Navigator.of(context).pushReplacementNamed('/');
        controller.restart();
      },
    );
  }
}

class MenuItem extends StatelessWidget {
  const MenuItem({
    super.key,
    required this.title,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final IconData icon;
  final VoidCallBack onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).colorScheme;
    const border = RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(32)),
    );
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4),
      child: ListTile(
        leading: Icon(icon, color: theme.onSecondaryContainer),
        title: Text(title, style: TextStyle(color: theme.onSecondaryContainer)),
        shape: border,
        onTap: onTap,
      ),
    );
  }
}

class DrawerSection extends StatelessWidget {
  const DrawerSection({
    super.key,
    required this.title,
  });

  static const ident = 16.0;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4),
      child: Column(
        children: [
          ListTile(leading: Text(title), dense: true),
          // const Divider(thickness: 1, indent: ident, endIndent: ident),
        ],
      ),
    );
  }
}

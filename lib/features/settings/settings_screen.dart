import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Ajustes',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _buildSectionHeader(context, 'Apariencia'),
          const SizedBox(height: 12),
          _buildSettingTile(
            context,
            'Modo Oscuro',
            'Reduce la fatiga visual en la noche',
            Icons.dark_mode_outlined,
            trailing: Switch(
              value: themeMode == ThemeMode.dark,
              onChanged: (value) {
                ref.read(themeModeProvider.notifier).state = value
                    ? ThemeMode.dark
                    : ThemeMode.light;
              },
              activeThumbColor: JadeColors.primary,
            ),
          ),
          const SizedBox(height: 32),
          _buildSectionHeader(context, 'Cuenta y Seguridad'),
          const SizedBox(height: 12),
          _buildSettingTile(
            context,
            'Perfil',
            'Gestiona tu información personal',
            Icons.person_outline,
            onTap: () {},
          ),
          const SizedBox(height: 12),
          _buildSettingTile(
            context,
            'Notificaciones',
            'Configura tus alertas de bienestar',
            Icons.notifications_none_outlined,
            onTap: () {},
          ),
          const SizedBox(height: 32),
          _buildSectionHeader(context, 'Acerca de'),
          const SizedBox(height: 12),
          _buildSettingTile(
            context,
            'Privacidad',
            'Tus datos son solo tuyos',
            Icons.lock_outline,
            onTap: () {},
          ),
          const SizedBox(height: 12),
          _buildSettingTile(
            context,
            'Versión',
            'JADE v1.0.0 (Prototipo)',
            Icons.info_outline,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleSmall?.copyWith(
        color: JadeColors.primary,
        fontWeight: FontWeight.bold,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildSettingTile(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon, {
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: JadeColors.primary.withValues(alpha: 0.05),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: JadeColors.primary),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.6),
            fontSize: 12,
          ),
        ),
        trailing: trailing ?? const Icon(Icons.chevron_right, size: 20),
      ),
    );
  }
}

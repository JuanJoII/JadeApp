import 'package:flutter/material.dart';
import '../core/theme.dart';

class JadeQuietInput extends StatelessWidget {
  final String label;
  final String hintText;
  final TextEditingController? controller;
  final int maxLines;

  const JadeQuietInput({
    super.key,
    required this.label,
    required this.hintText,
    this.controller,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4.0, bottom: 8.0),
          child: Text(
            label,
            style: theme.textTheme.labelLarge?.copyWith(
              color: isDark
                  ? JadeColors.darkOnSurface.withValues(alpha: 0.7)
                  : JadeColors.onSurface.withValues(alpha: 0.7),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: isDark
                ? JadeColors.darkSurfaceContainer
                : JadeColors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(16),
          ),
          child: TextField(
            controller: controller,
            maxLines: maxLines,
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: TextStyle(
                color:
                    (isDark ? JadeColors.darkOnSurface : JadeColors.onSurface)
                        .withValues(alpha: 0.3),
              ),
              contentPadding: const EdgeInsets.all(20),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: JadeColors.primary.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
            ),
            style: theme.textTheme.bodyLarge,
          ),
        ),
      ],
    );
  }
}

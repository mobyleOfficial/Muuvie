import 'package:flutter/material.dart';

class ReleaseDateYearsScreen extends StatelessWidget {
  final int decade;
  final VoidCallback onAnyTap;
  final void Function(int year) onYearTap;

  const ReleaseDateYearsScreen({
    super.key,
    required this.decade,
    required this.onAnyTap,
    required this.onYearTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final years = List.generate(10, (i) => decade + 9 - i);

    return ColoredBox(
      color: Theme.of(context).colorScheme.surface,
      child: ListView.builder(
        itemCount: years.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return ListTile(
              leading: Icon(Icons.select_all, color: colorScheme.primary),
              title: const Text('Any'),
              trailing: Icon(
                Icons.chevron_right,
                color: colorScheme.onSurfaceVariant,
              ),
              onTap: onAnyTap,
            );
          }

          final year = years[index - 1];

          return ListTile(
            leading: Icon(
              Icons.calendar_today_outlined,
              color: colorScheme.onSurface,
            ),
            title: Text('$year'),
            trailing: Icon(
              Icons.chevron_right,
              color: colorScheme.onSurfaceVariant,
            ),
            onTap: () => onYearTap(year),
          );
        },
      ),
    );
  }
}

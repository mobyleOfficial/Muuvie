import 'package:flutter/material.dart';

class ReleaseDateDecadesScreen extends StatelessWidget {
  final VoidCallback onUpcomingTap;
  final void Function(int decade, String label) onDecadeTap;

  static const _decades = [
    2020,
    2010,
    2000,
    1990,
    1980,
    1970,
    1960,
    1950,
    1940,
    1930,
    1920,
    1910,
    1900,
    1890,
    1880,
    1870,
  ];

  const ReleaseDateDecadesScreen({
    super.key,
    required this.onUpcomingTap,
    required this.onDecadeTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ColoredBox(
      color: Theme.of(context).colorScheme.surface,
      child: ListView.builder(
        itemCount: _decades.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return ListTile(
              leading: Icon(Icons.upcoming, color: colorScheme.primary),
              title: const Text('Upcoming'),
              trailing: Icon(
                Icons.chevron_right,
                color: colorScheme.onSurfaceVariant,
              ),
              onTap: onUpcomingTap,
            );
          }

          final decade = _decades[index - 1];
          final label = '${decade}s';

          return ListTile(
            leading: Icon(
              Icons.calendar_month_outlined,
              color: colorScheme.onSurface,
            ),
            title: Text(label),
            trailing: Icon(
              Icons.chevron_right,
              color: colorScheme.onSurfaceVariant,
            ),
            onTap: () => onDecadeTap(decade, label),
          );
        },
      ),
    );
  }
}

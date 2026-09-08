import 'package:flutter/material.dart';

class GarmentSelectionPage extends StatelessWidget {
  final VoidCallback onOpenSkirt;
  final VoidCallback? onOpenTrouser;

  const GarmentSelectionPage({
    super.key,
    required this.onOpenSkirt,
    this.onOpenTrouser,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Schnittmuster')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              'Kleidungsstück auswählen',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 6),
            const Text('Wähle das Schnittmuster, das du erstellen möchtest.'),
            const SizedBox(height: 20),
            Card(
              child: ListTile(
                leading: const Icon(Icons.checkroom_outlined, size: 34),
                title: const Text('Rock'),
                subtitle: const Text('Individueller Grundrock nach Körpermaßen'),
                trailing: const Icon(Icons.chevron_right),
                onTap: onOpenSkirt,
              ),
            ),
            const SizedBox(height: 8),
            Card(
              child: ListTile(
                leading: const Icon(Icons.checkroom_outlined, size: 34),
                title: const Text('Hose'),
                subtitle: Text(
                  onOpenTrouser == null
                      ? 'Grundschnitt wird vorbereitet'
                      : 'Individueller Grundschnitt nach Körpermaßen',
                ),
                trailing: onOpenTrouser == null
                    ? null
                    : const Icon(Icons.chevron_right),
                enabled: onOpenTrouser != null,
                onTap: onOpenTrouser,
              ),
            ),
            const SizedBox(height: 8),
            const Card(
              child: ListTile(
                leading: Icon(Icons.add_circle_outline, size: 34),
                title: Text('Weitere Schnittmuster'),
                subtitle: Text('Folgen später'),
                enabled: false,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

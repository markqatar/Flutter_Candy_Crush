import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

/// Pagina delle opzioni di gioco (volume, stile board, accesso account)
class OptionsPage extends StatefulWidget {
  const OptionsPage({Key? key}) : super(key: key);

  @override
  State<OptionsPage> createState() => _OptionsPageState();
}

class _OptionsPageState extends State<OptionsPage> {
  double _volume = 0.5;
  int _selectedTheme = 0;
  final List<String> _themes = [
    'classic',
    'fruit',
    'ice',
    'chocolate',
  ];

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(t.translate('options'))),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(t.translate('volume'), style: const TextStyle(fontSize: 18)),
            Slider(
              value: _volume,
              min: 0,
              max: 1,
              divisions: 10,
              label: (_volume * 100).round().toString(),
              onChanged: (v) => setState(() => _volume = v),
            ),
            const SizedBox(height: 32),
            Text(t.translate('board_style'),
                style: const TextStyle(fontSize: 18)),
            DropdownButton<int>(
              value: _selectedTheme,
              items: List.generate(
                  _themes.length,
                  (i) => DropdownMenuItem(
                        value: i,
                        child: Text(t.translate(_themes[i])),
                      )),
              onChanged: (v) => setState(() => _selectedTheme = v!),
            ),
            const Spacer(),
            Center(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.account_circle),
                label: Text(t.translate('account')),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const AccountPage()),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Pagina di gestione account utente
class AccountPage extends StatelessWidget {
  const AccountPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(t.translate('account'))),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const CircleAvatar(
                    radius: 32, child: Icon(Icons.person, size: 40)),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(t.translate('player_name'),
                        style: const TextStyle(fontSize: 18)),
                    Text(t.translate('edit_avatar'),
                        style: const TextStyle(color: Colors.blue)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 32),
            Text(t.translate('login_methods'),
                style: const TextStyle(fontSize: 18)),
            ListTile(
              leading: const Icon(Icons.email),
              title: const Text('Email'),
              trailing: const Icon(Icons.check_circle, color: Colors.green),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.apple),
              title: const Text('Apple'),
              trailing: const Icon(Icons.link),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.facebook),
              title: const Text('Facebook'),
              trailing: const Icon(Icons.link),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: Text(t.translate('logout')),
              onTap: () {},
            ),
            const Spacer(),
            Center(
              child: TextButton(
                child: Text(t.translate('delete_account'),
                    style: const TextStyle(color: Colors.red)),
                onPressed: () {},
              ),
            ),
          ],
        ),
      ),
    );
  }
}

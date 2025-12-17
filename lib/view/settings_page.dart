
import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Settings', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 24),

            // Account Settings
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Account',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),
                    const ListTile(
                      leading: Icon(Icons.person),
                      title: Text('Profile Information'),
                    ),
                    const Divider(),
                    const ListTile(
                      leading: Icon(Icons.lock),
                      title: Text('Change Password'),
                    ),
                    const Divider(),
                    const ListTile(
                      leading: Icon(Icons.notifications),
                      title: Text('Notification Settings'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // App Settings
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'App Settings',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),
                    const ListTile(
                      leading: Icon(Icons.palette),
                      title: Text('Theme'),
                    ),
                    const Divider(),
                    const ListTile(
                      leading: Icon(Icons.language),
                      title: Text('Language'),
                    ),
                    const Divider(),
                    const ListTile(
                      leading: Icon(Icons.backup),
                      title: Text('Backup & Restore'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Support
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Support',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),
                    const ListTile(
                      leading: Icon(Icons.help),
                      title: Text('Help Center'),
                    ),
                    const Divider(),
                    const ListTile(
                      leading: Icon(Icons.contact_support),
                      title: Text('Contact Support'),
                    ),
                    const Divider(),
                    const ListTile(
                      title: Text('About'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      // bottomNavigationBar: const BottomNavBar(selectedIndex: 3),
    );
  }
}

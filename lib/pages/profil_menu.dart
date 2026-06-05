import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProfileMenu extends StatelessWidget {
  final Color? backgroundColor;
  final Color? foregroundColor;

  const ProfileMenu({
    super.key,
    this.backgroundColor,
    this.foregroundColor,
  });

  Future<void> logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();

    if (!context.mounted) return;

    Navigator.pushNamedAndRemoveUntil(
      context,
      '/login',
      (route) => false,
    );
  }

  String getInitial(User? user) {
    final email = user?.email ?? '';

    if (email.isEmpty) return 'U';

    return email.substring(0, 1).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return PopupMenuButton<String>(
      tooltip: 'Profil',
      offset: const Offset(0, 48),
      padding: EdgeInsets.zero,
      onSelected: (value) {
        if (value == 'logout') {
          logout(context);
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem<String>(
          enabled: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Login sebagai',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                user?.email ?? 'User',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        const PopupMenuDivider(),
        const PopupMenuItem<String>(
          value: 'logout',
          child: Row(
            children: [
              Icon(Icons.logout),
              SizedBox(width: 10),
              Text('Logout'),
            ],
          ),
        ),
      ],
      child: SizedBox(
        width: 48,
        height: 48,
        child: Center(
          child: CircleAvatar(
            radius: 18,
            backgroundColor: backgroundColor ?? Colors.white,
            child: Text(
              getInitial(user),
              style: TextStyle(
                color: foregroundColor ?? Theme.of(context).primaryColor,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

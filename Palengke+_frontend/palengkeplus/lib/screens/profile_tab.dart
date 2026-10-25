import 'vendor/vendor_dashboard.dart';
import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../widgets/leaf_mark.dart';
import '../services/api_service.dart';

class ProfileTab extends StatefulWidget {
  final VoidCallback onSettings;
  final String role;
  final String vendorUser;
  final Future<void> Function(String role, String user)? onRoleChanged;
  const ProfileTab({
    super.key,
    required this.onSettings,
    this.role = 'consumer',
    this.vendorUser = '',
    this.onRoleChanged,
  });
  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  final settings = {
    'Price Alerts': true,
    'Weekly Report': true,
    'Budget Warning': true,
  };

  @override
  Widget build(BuildContext context) => SafeArea(
    child: ListView(
      padding: const EdgeInsets.fromLTRB(16, 22, 16, 24),
      children: [
        const Text(
          'MY ACCOUNT',
          style: TextStyle(
            color: green,
            fontSize: 11,
            fontWeight: FontWeight.w800,
          ),
        ),
        const Text(
          '👤 Profile',
          style: TextStyle(
            color: navy,
            fontSize: 26,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: navy,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 27,
                backgroundColor: const Color(0xFF10A39B),
                child: Text(
                  widget.role == 'vendor' ? '🏪' : '👩‍🍳',
                  style: const TextStyle(fontSize: 28),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.role == 'vendor'
                          ? (widget.vendorUser.isNotEmpty
                              ? 'Vendor: ${widget.vendorUser}'
                              : 'Vendor Mode')
                          : 'Consumer access',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      widget.role == 'vendor'
                          ? 'Add & manage your live stall prices'
                          : 'Public browsing · no account required',
                      style: const TextStyle(color: Colors.white70),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Official DA-4A CALABARZON reference data',
                      style: TextStyle(color: Colors.white70),
                    ),
                    if (widget.role == 'vendor' && widget.vendorUser.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      FilledButton.icon(
                        style: FilledButton.styleFrom(
                          backgroundColor: green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (c) => VendorDashboard(
                              vendorUser: widget.vendorUser,
                              api: ApiService(),
                            ),
                          ),
                        ),
                        icon: const Icon(Icons.store, size: 16),
                        label: const Text(
                          'Manage My Stall (Dashboard)',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              LeafMark(
                size: 32,
                color: Colors.white.withValues(alpha: 0.18),
                rotation: 0.35,
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: line),
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Account mode',
                  style: TextStyle(fontWeight: FontWeight.w800, color: navy),
                ),
                const SizedBox(height: 8),
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: 'consumer', label: Text('Consumer')),
                    ButtonSegment(value: 'vendor', label: Text('Vendor')),
                  ],
                  selected: {widget.role},
                  onSelectionChanged: (s) async {
                    final next = s.first;
                    if (next == 'vendor' && widget.vendorUser.isEmpty) {
                      await _showVendorLogin();
                    } else {
                      await widget.onRoleChanged?.call(next, widget.vendorUser);
                      if (mounted) setState(() {});
                    }
                  },
                ),
                const SizedBox(height: 8),
                Text(
                  widget.role == 'vendor'
                      ? 'Vendor mode active: You can post stall prices and open your Vendor Dashboard.'
                      : 'Consumer mode: View official DA reference prices and market stall offerings.',
                  style: const TextStyle(color: Colors.blueGrey, fontSize: 12),
                ),
                if (widget.role == 'vendor') ...[
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    children: [
                      TextButton.icon(
                        onPressed: () => _showVendorLogin(),
                        icon: const Icon(Icons.swap_horiz, size: 16),
                        label: Text(
                          widget.vendorUser.isEmpty
                              ? 'Login / Register'
                              : 'Switch Vendor',
                        ),
                      ),
                      if (widget.vendorUser.isNotEmpty)
                        TextButton.icon(
                          onPressed: () async {
                            await widget.onRoleChanged?.call('consumer', '');
                            if (mounted) setState(() {});
                          },
                          icon: const Icon(Icons.logout, size: 16, color: red),
                          label: const Text(
                            'Logout vendor',
                            style: TextStyle(color: red),
                          ),
                        ),
                    ],
                  ),
                ] else ...[
                  const SizedBox(height: 6),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      onPressed: () => _showVendorLogin(),
                      icon: const Icon(Icons.store, size: 16, color: green),
                      label: const Text(
                        'Are you a vendor? Login / Register here',
                        style: TextStyle(
                          color: green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        _settingsCard(
          'Alert Preferences',
          '🔔',
          settings.entries
              .map(
                (entry) => SwitchListTile(
                  title: Text(entry.key),
                  subtitle: Text(
                    _settingDescription(entry.key),
                    style: const TextStyle(
                      color: Colors.blueGrey,
                      fontSize: 12,
                    ),
                  ),
                  value: entry.value,
                  activeThumbColor: green,
                  onChanged: (value) =>
                      setState(() => settings[entry.key] = value),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 16),
        _settingsCard('Preferences', '⚙️', [
          ListTile(
            leading: const Icon(Icons.dns_outlined, color: navy),
            title: const Text('Server connection'),
            subtitle: Text(
              ApiService.activeBaseUrl,
              style: const TextStyle(fontSize: 11, color: Colors.blueGrey),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: widget.onSettings,
          ),
          const ListTile(
            leading: Icon(Icons.language, color: navy),
            title: Text('Language'),
            trailing: Text('Filipino / English'),
          ),
          const ListTile(
            leading: Icon(Icons.info_outline, color: navy),
            title: Text('App Version'),
            trailing: Text('v1.0.0'),
          ),
        ]),
      ],
    ),
  );

  Widget _settingsCard(String title, String icon, List<Widget> children) =>
      Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: line),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 6),
              child: Row(
                children: [
                  Text(icon, style: const TextStyle(fontSize: 16)),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: navy,
                    ),
                  ),
                ],
              ),
            ),
            ...children,
          ],
        ),
      );

  String _settingDescription(String key) => switch (key) {
    'Price Alerts' => 'When prices move \u00B15%',
    'Weekly Report' => 'Market summary every Sunday',
    'Budget Warning' => 'When planned spend reaches 80%',
    _ => 'Market updates are shown in Palengke+.',
  };

  Future<void> _showVendorLogin() async {
    final api = ApiService();
    final uCtrl = TextEditingController(text: widget.vendorUser);
    final pCtrl = TextEditingController();
    final mCtrl = TextEditingController();
    bool isLogin = true;
    bool isLoading = false;
    String? dialogError;

    await showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          title: Text(isLogin ? 'Vendor Login' : 'Vendor Register'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (dialogError != null) ...[
                  Container(
                    padding: const EdgeInsets.all(8),
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline, size: 16, color: red),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            dialogError!,
                            style: const TextStyle(color: red, fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                TextField(
                  controller: uCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Username',
                    hintText: 'e.g. nanay_maria',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: pCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                ),
                if (!isLogin) ...[
                  const SizedBox(height: 10),
                  TextField(
                    controller: mCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Market / Stall Name',
                      hintText: 'e.g. Calamba Public Market Stall #12',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
                const SizedBox(height: 8),
                TextButton(
                  onPressed: isLoading
                      ? null
                      : () => setS(() {
                            isLogin = !isLogin;
                            dialogError = null;
                          }),
                  child: Text(
                    isLogin
                        ? "Don't have a vendor account? Register"
                        : 'Already have an account? Login',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: isLoading ? null : () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: green),
              onPressed: isLoading
                  ? null
                  : () async {
                      final u = uCtrl.text.trim();
                      final p = pCtrl.text.trim();
                      final m = mCtrl.text.trim();
                      if (u.length < 3) {
                        setS(() => dialogError = 'Username must be at least 3 characters');
                        return;
                      }
                      if (p.length < 4) {
                        setS(() => dialogError = 'Password must be at least 4 characters');
                        return;
                      }
                      if (!isLogin && m.length < 2) {
                        setS(() => dialogError = 'Please specify your market or stall name');
                        return;
                      }
                      setS(() {
                        isLoading = true;
                        dialogError = null;
                      });
                      try {
                        Map<String, dynamic> res;
                        if (isLogin) {
                          res = await api.vendorLogin(username: u, password: p);
                        } else {
                          res = await api.vendorRegister(username: u, password: p, market: m);
                        }
                        final user = (res['username'] ?? u).toString();
                        await widget.onRoleChanged?.call('vendor', user);
                        if (ctx.mounted) Navigator.pop(ctx);
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                isLogin
                                    ? 'Logged in as $user'
                                    : 'Registered and logged in as $user',
                              ),
                            ),
                          );
                          setState(() {});
                        }
                      } catch (e) {
                        final cleanErr = e
                            .toString()
                            .replaceAll(RegExp(r'^Exception:\s*'), '');
                        setS(() {
                          isLoading = false;
                          dialogError = cleanErr;
                        });
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(cleanErr)),
                          );
                        }
                      }
                    },
              child: isLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(isLogin ? 'Login' : 'Register'),
            ),
          ],
        ),
      ),
    );
  }
}


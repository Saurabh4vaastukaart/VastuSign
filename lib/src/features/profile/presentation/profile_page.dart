import 'package:flutter/material.dart';

import '../../../core/config/app_config.dart';
import '../../../core/data/local_database.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/brand_mark.dart';
import '../../../core/widgets/premium_scaffold.dart';
import '../data/auth_repository.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _auth = AuthRepository();
  var _trueNorth = false;
  var _language = 'English';
  CloudSession? _session;
  var _busy = false;

  @override
  void initState() {
    super.initState();
    _loadSession();
  }

  Future<void> _loadSession() async {
    final session = await _auth.currentSession();
    if (mounted) setState(() => _session = session);
  }

  @override
  Widget build(BuildContext context) {
    return PremiumScaffold(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(22, 16, 22, 32),
        children: [
          const BrandMark(size: 38),
          const SizedBox(height: 28),
          Text('Profile & preferences', style: Theme.of(context).textTheme.displaySmall?.copyWith(fontSize: 35)),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [AppColors.midnight, AppColors.navy]),
              borderRadius: BorderRadius.circular(26),
            ),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 29,
                  backgroundColor: AppColors.lightGold,
                  child: Icon(Icons.person_rounded, color: AppColors.midnight),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _session?.name ?? 'Guest user',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        _session?.email ?? 'Sign in to sync measurements',
                        style: const TextStyle(color: Colors.white60),
                      ),
                    ],
                  ),
                ),
                FilledButton.tonal(
                  onPressed: _busy
                      ? null
                      : _session == null
                          ? () => _showSignIn(context)
                          : _syncNow,
                  child: Text(_session == null ? 'Sign in' : 'Sync'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 26),
          _SettingsGroup(
            title: 'Compass',
            children: [
              SwitchListTile.adaptive(
                value: _trueNorth,
                activeThumbColor: AppColors.emerald,
                title: const Text('Prefer True North (coming soon)'),
                subtitle: const Text('Requires verified location-based magnetic declination.'),
                secondary: const Icon(Icons.explore_outlined),
                onChanged: null,
              ),
              _SettingsTile(
                icon: Icons.tune_rounded,
                title: 'Calibration preferences',
                subtitle: 'Accuracy limits and boundary warnings',
                onTap: () => _showCalibrationSettings(context),
              ),
            ],
          ),
          const SizedBox(height: 18),
          _SettingsGroup(
            title: 'App',
            children: [
              _SettingsTile(
                icon: Icons.language_rounded,
                title: 'Language',
                subtitle: _language,
                onTap: () => _chooseLanguage(context),
              ),
              _SettingsTile(
                icon: Icons.notifications_none_rounded,
                title: 'Notifications',
                subtitle: 'Report and calibration reminders',
                onTap: () => _showSimpleInfo(context, 'Notifications', 'Notification preferences will be available after sign-in.'),
              ),
            ],
          ),
          const SizedBox(height: 18),
          _SettingsGroup(
            title: 'Privacy & support',
            children: [
              _SettingsTile(
                icon: Icons.shield_outlined,
                title: 'Privacy and permissions',
                subtitle: 'Camera, location, and report data',
                onTap: () => _showSimpleInfo(context, 'Privacy by design', 'VastuSign will not store camera frames or precise location unless you explicitly choose to save them.'),
              ),
              _SettingsTile(
                icon: Icons.delete_outline_rounded,
                title: 'Delete my data',
                subtitle: 'Remove account and saved reports',
                onTap: () => _showDeleteData(context),
              ),
              _SettingsTile(
                icon: Icons.support_agent_rounded,
                title: 'Help and support',
                subtitle: AppConfig.supportEmail,
                onTap: () => _showSimpleInfo(context, 'Support', 'Support channels will be configured with the final brand domain.'),
              ),
            ],
          ),
          const SizedBox(height: 22),
          Center(
            child: Text(
              'VastuSign · 1.0.0 · ${AppConfig.cloudEnabled ? 'Cloud ready' : 'Offline edition'}',
              style: const TextStyle(color: AppColors.muted, fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }

  void _showSignIn(BuildContext context) {
    final name = TextEditingController();
    final email = TextEditingController();
    final password = TextEditingController();
    var register = false;
    var submitting = false;
    String? error;
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, setSheetState) => Padding(
          padding: EdgeInsets.fromLTRB(
            24,
            4,
            24,
            MediaQuery.viewInsetsOf(context).bottom + 28,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.cloud_sync_rounded, size: 42, color: AppColors.gold),
                const SizedBox(height: 12),
                Text(
                  register ? 'Create your account' : 'Sign in to VastuSign',
                  style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                Text(
                  AppConfig.cloudEnabled
                      ? 'Your local analysis stays on this phone until you tap Sync.'
                      : 'This APK was built without a cloud server URL. Offline analysis still works.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 18),
                if (register) ...[
                  TextField(
                    controller: name,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(labelText: 'Name'),
                  ),
                  const SizedBox(height: 10),
                ],
                TextField(
                  controller: email,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(labelText: 'Email'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: password,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Password (8+ characters)'),
                ),
                if (error != null) ...[
                  const SizedBox(height: 10),
                  Text(error!, style: const TextStyle(color: AppColors.coral)),
                ],
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: submitting || !AppConfig.cloudEnabled
                        ? null
                        : () async {
                            setSheetState(() {
                              submitting = true;
                              error = null;
                            });
                            try {
                              final session = register
                                  ? await _auth.register(
                                      name: name.text.trim(),
                                      email: email.text.trim(),
                                      password: password.text,
                                    )
                                  : await _auth.login(
                                      email: email.text.trim(),
                                      password: password.text,
                                    );
                              if (!mounted) return;
                              setState(() => _session = session);
                              if (sheetContext.mounted) Navigator.pop(sheetContext);
                            } catch (exception) {
                              setSheetState(() {
                                submitting = false;
                                error = exception.toString();
                              });
                            }
                          },
                    child: Text(submitting ? 'Please wait…' : register ? 'Create account' : 'Sign in'),
                  ),
                ),
                TextButton(
                  onPressed: submitting
                      ? null
                      : () => setSheetState(() {
                            register = !register;
                            error = null;
                          }),
                  child: Text(register ? 'Already have an account? Sign in' : 'New here? Create account'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _syncNow() async {
    final session = _session;
    if (session == null) return;
    setState(() => _busy = true);
    try {
      final measurements = await LocalDatabase.instance.loadMeasurements();
      final count = await _auth.syncMeasurements(session, measurements);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$count measurements synced securely.')),
      );
    } catch (exception) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sync failed: $exception')),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _chooseLanguage(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              value: 'English',
              groupValue: _language,
              title: const Text('English'),
              onChanged: (value) {
                setState(() => _language = value!);
                Navigator.pop(context);
              },
            ),
            RadioListTile<String>(
              value: 'हिन्दी',
              groupValue: _language,
              title: const Text('हिन्दी'),
              onChanged: (value) {
                setState(() => _language = value!);
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 14),
          ],
        ),
      ),
    );
  }

  void _showCalibrationSettings(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => const Padding(
        padding: EdgeInsets.fromLTRB(24, 4, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Calibration preferences', style: TextStyle(fontSize: 21, fontWeight: FontWeight.w700)),
            SizedBox(height: 12),
            ListTile(contentPadding: EdgeInsets.zero, leading: Icon(Icons.speed_rounded), title: Text('Required accuracy'), trailing: Text('±5° or better')),
            ListTile(contentPadding: EdgeInsets.zero, leading: Icon(Icons.timer_outlined), title: Text('Stable reading time'), trailing: Text('1.5 seconds')),
            ListTile(contentPadding: EdgeInsets.zero, leading: Icon(Icons.swap_horiz_rounded), title: Text('Boundary warnings'), trailing: Text('Always on')),
          ],
        ),
      ),
    );
  }

  void _showDeleteData(BuildContext context) {
    showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.delete_forever_outlined, color: AppColors.coral),
        title: const Text('Delete saved data?'),
        content: const Text('This removes local measurements, reports, and the saved cloud session from this phone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete local data')),
        ],
      ),
    ).then((confirmed) async {
      if (confirmed != true) return;
      await LocalDatabase.instance.deleteAllUserData();
      if (!mounted) return;
      setState(() => _session = null);
      ScaffoldMessenger.of(this.context).showSnackBar(
        const SnackBar(content: Text('Local app data deleted.')),
      );
    });
  }

  void _showSimpleInfo(BuildContext context, String title, String content) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))],
      ),
    );
  }
}

class _SettingsGroup extends StatelessWidget {
  const _SettingsGroup({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 3, bottom: 8),
          child: Text(title.toUpperCase(), style: const TextStyle(color: AppColors.gold, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1)),
        ),
        Container(
          decoration: BoxDecoration(color: AppColors.warmWhite, borderRadius: BorderRadius.circular(22), border: Border.all(color: AppColors.outline)),
          child: Column(children: children),
        ),
      ],
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({required this.icon, required this.title, required this.subtitle, required this.onTap});

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.gold),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right_rounded),
      onTap: onTap,
    );
  }
}

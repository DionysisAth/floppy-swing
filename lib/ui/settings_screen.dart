import 'package:flutter/material.dart';

import '../app.dart';
import '../services/online_service.dart';
import 'online_ui.dart';
import 'theme.dart';
import 'widgets.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final services = AppServices.of(context);
    final progress = services.progress;
    return Scaffold(
      backgroundColor: const Color(0xFFE6F4FF),
      body: ContentArea(
        child: ListenableBuilder(
          listenable: Listenable.merge([progress, services.ads, services.online]),
          builder: (context, _) => ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Row(
                children: [
                  RoundButton(
                    icon: Icons.arrow_back_rounded,
                    tooltip: 'Back',
                    onPressed: () => Navigator.of(context).pop(),
                    size: 22,
                  ),
                  const SizedBox(width: 12),
                  Text('SETTINGS', style: display(36, color: AppColors.blue)),
                ],
              ),
              const SizedBox(height: 20),
              Panel(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _label(Icons.music_note_rounded, 'Music'),
                    Slider(
                      value: progress.musicVolume,
                      onChanged: progress.setMusicVolume,
                      onChangeEnd: (_) => services.audio.startMusic(),
                    ),
                    _label(Icons.volume_up_rounded, 'Sound effects'),
                    Slider(
                      value: progress.sfxVolume,
                      onChanged: progress.setSfxVolume,
                      onChangeEnd: (_) => services.audio.play('boing.wav'),
                    ),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      value: progress.musicVolume == 0 && progress.sfxVolume == 0,
                      onChanged: (mute) {
                        progress.setMusicVolume(mute ? 0 : 0.6);
                        progress.setSfxVolume(mute ? 0 : 1);
                        services.audio.startMusic();
                      },
                      title: Text('Mute everything', style: body(18, weight: 600)),
                    ),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      value: progress.haptics,
                      onChanged: progress.setHaptics,
                      title: Text('Vibration', style: body(18, weight: 600)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _onlinePanel(context),
              const SizedBox(height: 16),
              if (services.ads.privacyOptionsRequired) ...[
                ChunkyButton(
                  onPressed: services.ads.showPrivacyOptions,
                  label: 'Privacy options',
                  icon: Icons.privacy_tip_rounded,
                  color: AppColors.blue,
                  shade: AppColors.blueDark,
                  fontSize: 20,
                ),
                const SizedBox(height: 10),
              ],
              ChunkyButton(
                onPressed: () => _confirmReset(context),
                label: 'Reset progress',
                icon: Icons.delete_forever_rounded,
                color: AppColors.grey,
                shade: AppColors.greyDark,
                fontSize: 20,
              ),
              const SizedBox(height: 24),
              Text(
                'Floppy Swing 1.0\nFonts: Lilita One & Fredoka (SIL OFL)',
                textAlign: TextAlign.center,
                style: body(13, color: AppColors.greyDark),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _onlinePanel(BuildContext context) {
    final services = AppServices.of(context);
    final online = services.online;
    final profile = online.profile;
    final status = switch (online.status) {
      OnlineStatus.disabled => 'Off (no game server set)',
      OnlineStatus.connecting => 'Connecting...',
      OnlineStatus.offline => "Offline - can't reach the server",
      OnlineStatus.online => 'Online as ${profile?.name ?? '?'}',
    };
    return Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _label(Icons.cloud_rounded, 'Online'),
          const SizedBox(height: 4),
          Text(status, style: body(15, weight: 600, color: AppColors.greyDark)),
          if (online.isOnline) ...[
            Text(
              'Progress is backed up to the cloud automatically.',
              style: body(13, weight: 600, color: AppColors.greyDark),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _small('Change name', Icons.edit_rounded, () => _rename(context)),
                _small('Move to a new phone', Icons.send_to_mobile_rounded, () => _showTransferCode(context)),
                _small('Delete my online data', Icons.person_remove_rounded, () => _deleteAccount(context)),
              ],
            ),
          ],
          if (online.enabled) ...[
            const SizedBox(height: 8),
            _small('I have a code from my old phone', Icons.download_rounded, () => _enterTransferCode(context)),
          ],
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: () => _editServer(context),
            icon: const Icon(Icons.dns_rounded, size: 18),
            label: Text('Game server: ${online.enabled ? online.serverUrl : 'none'}', style: body(13, weight: 600)),
          ),
        ],
      ),
    );
  }

  Widget _small(String label, IconData icon, VoidCallback onPressed) => ChunkyButton(
    onPressed: onPressed,
    label: label,
    icon: icon,
    fontSize: 16,
    color: AppColors.blue,
    shade: AppColors.blueDark,
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
  );

  Future<String?> _ask(BuildContext context, String title, {String initial = '', String? hint}) {
    final field = TextEditingController(text: initial);
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: field,
          autofocus: true,
          decoration: InputDecoration(hintText: hint),
          onSubmitted: (v) => Navigator.pop(context, v),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, field.text), child: const Text('OK')),
        ],
      ),
    );
  }

  Future<void> _rename(BuildContext context) async {
    final online = AppServices.of(context).online;
    final name = await _ask(context, 'Your name', initial: online.profile?.name ?? '', hint: '3-16 letters');
    if (name == null || !context.mounted) return;
    await onlineAction(context, () => online.rename(name));
  }

  Future<void> _deleteAccount(BuildContext context) async {
    final services = AppServices.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete your online data?'),
        content: const Text(
          'This removes your name, scores, friends, ghosts, clips and cloud save from the game server. '
          'Progress on this phone stays.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;
    final done = await onlineAction(context, () async {
      await services.online.deleteAccount();
      services.progress.cloudRevision = 0;
      return true;
    });
    if (done == true && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Your online data was deleted.')));
    }
  }

  Future<void> _showTransferCode(BuildContext context) async {
    final code = await onlineAction(context, AppServices.of(context).online.transferCode);
    if (code == null || !context.mounted) return;
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Move to a new phone'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('On your new phone, open Settings > Online > "I have a code" and enter:'),
            const SizedBox(height: 12),
            SelectableText(code, style: display(36, color: AppColors.blue, shadow: false).copyWith(letterSpacing: 4)),
            const SizedBox(height: 8),
            const Text('The code works once, for 24 hours.'),
          ],
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Done'))],
      ),
    );
  }

  Future<void> _enterTransferCode(BuildContext context) async {
    final services = AppServices.of(context);
    final code = await _ask(context, 'Code from your old phone', hint: '8 letters');
    if (code == null || code.trim().isEmpty || !context.mounted) return;
    final ok = await onlineAction(context, () async {
      await services.online.redeemTransfer(code);
      await services.cloud.accountChanged();
      return true;
    });
    if (ok == true && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Welcome back! Your progress is here.')));
    }
  }

  Future<void> _editServer(BuildContext context) async {
    final services = AppServices.of(context);
    final url = await _ask(
      context,
      'Game server address',
      initial: services.online.serverUrl,
      hint: 'https://your-server.example.com',
    );
    if (url == null || !context.mounted) return;
    await services.online.setServer(url);
    await services.cloud.accountChanged();
  }

  Widget _label(IconData icon, String text) => Row(
    children: [
      Icon(icon, color: AppColors.greyDark),
      const SizedBox(width: 8),
      Text(text, style: body(18, weight: 600)),
    ],
  );

  Future<void> _confirmReset(BuildContext context) async {
    final progress = AppServices.of(context).progress;
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset progress?'),
        content: const Text('This wipes your stars, coins and skins. It cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Reset')),
        ],
      ),
    );
    if (ok == true) await progress.reset();
  }
}

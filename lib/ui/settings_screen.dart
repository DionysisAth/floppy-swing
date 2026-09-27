import 'package:flutter/material.dart';

import '../app.dart';
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
      body: SafeArea(
        child: ListenableBuilder(
          listenable: Listenable.merge([progress, services.ads]),
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
                'Floppy Swing 0.1 (MVP)\nFonts: Lilita One & Fredoka (SIL OFL)',
                textAlign: TextAlign.center,
                style: body(13, color: AppColors.greyDark),
              ),
            ],
          ),
        ),
      ),
    );
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

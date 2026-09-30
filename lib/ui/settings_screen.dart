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
      body: ContentArea(
        child: ListenableBuilder(
          listenable: Listenable.merge([progress, services.ads, services.games]),
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
                        progress.setMusicVolume(mute ? 0 : 0.45);
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
                    if (services.reminders case final reminders?)
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        value: progress.reminders && progress.remindersAsked,
                        onChanged: reminders.setEnabled,
                        title: Text('Daily Challenge reminders', style: body(18, weight: 600)),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _gamesPanel(context),
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

  /// Google Play Games / Game Center: sign-in state, leaderboards,
  /// achievements. Cloud save runs by itself once signed in.
  Widget _gamesPanel(BuildContext context) {
    final games = AppServices.of(context).games;
    final name = games.serviceName;
    return Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _label(Icons.cloud_rounded, name),
          const SizedBox(height: 6),
          if (!games.available)
            Text(
              'Leaderboards, achievements and cloud save come with $name. Not set up in this build yet.',
              style: body(15, color: AppColors.greyDark, weight: 600),
            )
          else ...[
            Text(
              games.signedIn
                  ? 'Signed in${(games.playerName ?? '').isEmpty ? '' : ' as ${games.playerName}'}. '
                        'Progress is backed up to your $name account.'
                  : 'Sign in to back up your progress and join the leaderboards.',
              style: body(15, color: AppColors.greyDark, weight: 600),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (!games.signedIn) _small('Sign in', Icons.login_rounded, games.signIn),
                _small('Leaderboards', Icons.emoji_events_rounded, games.showLeaderboard),
                _small('Achievements', Icons.military_tech_rounded, games.showAchievements),
              ],
            ),
          ],
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

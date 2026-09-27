import 'package:flutter/material.dart';

import '../app.dart';
import '../services/online_service.dart';
import 'theme.dart';
import 'widgets.dart';

/// Runs an online call, showing a friendly message if it fails.
Future<T?> onlineAction<T>(BuildContext context, Future<T> Function() call) async {
  final messenger = ScaffoldMessenger.maybeOf(context);
  try {
    return await call();
  } on OnlineException catch (e) {
    messenger?.showSnackBar(SnackBar(content: Text(e.message)));
    return null;
  }
}

/// Shown in place of online content when there's no server or no signal.
class OfflineNotice extends StatelessWidget {
  const OfflineNotice({super.key});

  @override
  Widget build(BuildContext context) {
    final online = AppServices.of(context).online;
    return ListenableBuilder(
      listenable: online,
      builder: (context, _) => Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Panel(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  online.enabled ? Icons.wifi_off_rounded : Icons.cloud_off_rounded,
                  size: 56,
                  color: AppColors.greyDark,
                ),
                const SizedBox(height: 8),
                Text(
                  online.enabled ? "You're offline" : 'Online features are off',
                  textAlign: TextAlign.center,
                  style: display(26, color: AppColors.ink, shadow: false),
                ),
                const SizedBox(height: 6),
                Text(
                  online.enabled
                      ? "Can't reach the game server. Check your connection."
                      : 'This build has no game server set. Add one in Settings > Online.',
                  textAlign: TextAlign.center,
                  style: body(15, weight: 600),
                ),
                if (online.enabled) ...[
                  const SizedBox(height: 14),
                  ChunkyButton(
                    onPressed: online.status == OnlineStatus.connecting ? null : online.start,
                    label: online.status == OnlineStatus.connecting ? 'Connecting...' : 'Try again',
                    icon: Icons.refresh_rounded,
                    color: AppColors.blue,
                    shade: AppColors.blueDark,
                    fontSize: 20,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Standard header for online screens: back button, title, trailing widget.
class ScreenHeader extends StatelessWidget {
  const ScreenHeader({super.key, required this.title, required this.color, this.trailing});
  final String title;
  final Color color;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
    child: Row(
      children: [
        RoundButton(
          icon: Icons.arrow_back_rounded,
          tooltip: 'Back',
          onPressed: () => Navigator.of(context).pop(),
          size: 22,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(title, style: display(34, color: color)),
          ),
        ),
        ?trailing,
      ],
    ),
  );
}

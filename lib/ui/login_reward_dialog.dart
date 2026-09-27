import 'package:flutter/material.dart';

import '../app.dart';
import 'theme.dart';
import 'widgets.dart';

/// Shows the daily login calendar and claims today's reward.
Future<void> showLoginReward(BuildContext context) async {
  final services = AppServices.of(context);
  final progress = services.progress;
  if (!progress.loginRewardReady) return;
  final day = progress.nextLoginDay;
  await showDialog<void>(
    context: context,
    barrierDismissible: false,
    barrierColor: AppColors.scrim,
    builder: (context) => Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(20),
      child: Panel(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('DAILY BONUS', style: display(34, color: AppColors.orange)),
            Text('Come back every day for bigger rewards!', textAlign: TextAlign.center, style: body(15, weight: 600)),
            const SizedBox(height: 14),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 8,
              runSpacing: 8,
              children: [
                for (var d = 1; d <= services.economy.loginRewards.length; d++)
                  _DayTile(day: d, reward: services.economy.loginRewards[d - 1], today: d == day, past: d < day),
              ],
            ),
            const SizedBox(height: 16),
            ChunkyButton(
              onPressed: () {
                progress.claimLoginReward();
                services.audio.play('buy.wav');
                Navigator.of(context).pop();
              },
              label: 'Claim',
              icon: Icons.redeem_rounded,
              color: AppColors.green,
              shade: AppColors.greenDark,
            ),
          ],
        ),
      ),
    ),
  );
}

class _DayTile extends StatelessWidget {
  const _DayTile({required this.day, required this.reward, required this.today, required this.past});
  final int day;
  final ({int coins, int gems}) reward;
  final bool today;
  final bool past;

  @override
  Widget build(BuildContext context) => Container(
    width: 72,
    padding: const EdgeInsets.symmetric(vertical: 8),
    decoration: BoxDecoration(
      color: today ? const Color(0xFFFFF4C9) : (past ? const Color(0xFFE4F7E9) : const Color(0xFFF3EEE6)),
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: today ? AppColors.orange : AppColors.ink, width: today ? 4 : 2),
    ),
    child: Column(
      children: [
        Text('Day $day', style: body(13, weight: 800)),
        const SizedBox(height: 4),
        if (past)
          const Icon(Icons.check_circle_rounded, color: AppColors.greenDark, size: 30)
        else ...[
          if (reward.coins > 0)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [const CoinIcon(size: 16), Text(' ${reward.coins}', style: body(14, weight: 800))],
            ),
          if (reward.gems > 0)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [const GemIcon(size: 16), Text(' ${reward.gems}', style: body(14, weight: 800))],
            ),
        ],
      ],
    ),
  );
}

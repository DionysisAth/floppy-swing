import 'package:flutter/material.dart';

import '../app.dart';
import '../game/cosmetics.dart';
import '../game/season.dart';
import '../game/skins.dart';
import 'shop_screen.dart';
import 'theme.dart';
import 'widgets.dart';

const _purple = Color(0xFF8F6BC7);
const _purpleDark = Color(0xFF5F3F99);

/// Season Pass: XP bar, the free and premium tracks, and claiming.
class SeasonScreen extends StatelessWidget {
  const SeasonScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final services = AppServices.of(context);
    final progress = services.progress;
    return Scaffold(
      backgroundColor: const Color(0xFFEDE3FF),
      body: ContentArea(
        child: ListenableBuilder(
          listenable: progress,
          builder: (context, _) {
            final index = progress.seasonIndex;
            final theme = Season.theme(index);
            final tier = progress.seasonTier;
            final xpInTier = progress.seasonXp - tier * Season.xpPerTier;
            return Column(
              children: [
                Padding(
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
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('SEASON PASS', style: display(18, color: _purple)),
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerLeft,
                              child: Text(theme.name, style: display(30, color: _purpleDark, shadow: false)),
                            ),
                          ],
                        ),
                      ),
                      GemBadge(gems: progress.gems),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Panel(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Text('Tier $tier', style: display(24, color: AppColors.ink, shadow: false)),
                            const Spacer(),
                            Text('${Season.daysLeft(progress.today)} days left', style: body(15, weight: 700)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: LinearProgressIndicator(
                            value: tier >= Season.tiers ? 1 : xpInTier / Season.xpPerTier,
                            minHeight: 16,
                            backgroundColor: const Color(0xFFE6DDF5),
                            color: _purple,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          tier >= Season.tiers
                              ? 'Season complete!'
                              : '$xpInTier / ${Season.xpPerTier} XP  ·  Earn XP by finishing levels, dailies and Endless runs',
                          textAlign: TextAlign.center,
                          style: body(13, weight: 600, color: AppColors.greyDark),
                        ),
                        if (!progress.premiumPass) ...[
                          const SizedBox(height: 10),
                          ChunkyButton(
                            onPressed: progress.gems >= Season.premiumGems
                                ? () {
                                    if (progress.unlockPremiumPass()) services.audio.play('buy.wav');
                                  }
                                : null,
                            color: _purple,
                            shade: _purpleDark,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text('Unlock Premium  ', style: display(20)),
                                const GemIcon(size: 20),
                                Text(' ${Season.premiumGems}', style: display(20)),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                  child: Row(
                    children: [
                      const SizedBox(width: 44),
                      Expanded(child: Center(child: Text('FREE', style: display(18, color: AppColors.greenDark, shadow: false)))),
                      const SizedBox(width: 10),
                      Expanded(child: Center(child: Text('PREMIUM', style: display(18, color: _purple, shadow: false)))),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    itemCount: Season.tiers,
                    itemBuilder: (context, i) {
                      final t = i + 1;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Row(
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: t <= tier ? _purple : Colors.white,
                                shape: BoxShape.circle,
                                border: Border.all(color: AppColors.ink, width: 3),
                              ),
                              child: Text('$t', style: display(16, color: t <= tier ? Colors.white : AppColors.ink, shadow: false)),
                            ),
                            const SizedBox(width: 8),
                            Expanded(child: _RewardTile(tier: t, premium: false)),
                            const SizedBox(width: 10),
                            Expanded(child: _RewardTile(tier: t, premium: true)),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _RewardTile extends StatelessWidget {
  const _RewardTile({required this.tier, required this.premium});
  final int tier;
  final bool premium;

  @override
  Widget build(BuildContext context) {
    final services = AppServices.of(context);
    final progress = services.progress;
    final reward = Season.reward(progress.seasonIndex, tier, premium: premium);
    final claimed = progress.seasonClaimed(tier, premium: premium);
    final ready = progress.canClaimSeason(tier, premium: premium);
    final locked = premium && !progress.premiumPass;
    final item = reward.item;
    final Widget content;
    if (item != null) {
      final isSkin = skins.any((s) => s.id == item);
      content = Column(
        children: [
          SizedBox(
            height: 64,
            child: isSkin ? SkinPreview(skin: skinById(item)) : CosmeticPreview(item: cosmeticById(item)),
          ),
          FittedBox(
            child: Text(
              isSkin ? skinById(item).name : cosmeticById(item).name,
              style: body(13, weight: 800),
            ),
          ),
        ],
      );
    } else {
      content = SizedBox(
        height: 40,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (reward.gems > 0) const GemIcon(size: 22) else const CoinIcon(size: 22),
            Text(' ${reward.gems > 0 ? reward.gems : reward.coins}', style: display(20, color: AppColors.ink, shadow: false)),
          ],
        ),
      );
    }
    return GestureDetector(
      onTap: ready
          ? () {
              if (progress.claimSeason(tier, premium: premium) != null) {
                services.audio.play('buy.wav');
                services.analytics.seasonReward(tier, premium);
              }
            }
          : null,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: ready ? const Color(0xFFFFF4C9) : (claimed ? const Color(0xFFE4F7E9) : Colors.white),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: ready ? AppColors.orange : AppColors.ink, width: ready ? 4 : 2),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Opacity(opacity: claimed ? 0.35 : (locked ? 0.6 : 1), child: content),
            if (claimed) const Icon(Icons.check_circle_rounded, color: AppColors.greenDark, size: 30),
            if (locked && !claimed)
              const Positioned(top: 0, right: 0, child: Icon(Icons.lock_rounded, color: _purpleDark, size: 18)),
          ],
        ),
      ),
    );
  }
}

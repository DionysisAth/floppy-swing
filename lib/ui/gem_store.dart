import 'package:flutter/material.dart';

import '../app.dart';
import '../game/cosmetics.dart';
import '../game/store_products.dart';
import '../services/purchase_service.dart';
import 'theme.dart';
import 'widgets.dart';

/// Shows the purchase service's messages ("Thanks!", errors) as snackbars
/// while [child] is on screen, and rebuilds it when the store changes.
class PurchaseMessages extends StatefulWidget {
  const PurchaseMessages({super.key, required this.child});

  final Widget child;

  @override
  State<PurchaseMessages> createState() => _PurchaseMessagesState();
}

class _PurchaseMessagesState extends State<PurchaseMessages> {
  PurchaseService? _purchases;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final p = AppServices.of(context).purchases;
    if (p != _purchases) {
      _purchases?.removeListener(_onChange);
      _purchases = p..addListener(_onChange);
    }
  }

  @override
  void dispose() {
    _purchases?.removeListener(_onChange);
    super.dispose();
  }

  void _onChange() {
    if (!mounted) return;
    final message = _purchases?.takeMessage();
    if (message != null) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(message, style: body(15, color: Colors.white, weight: 700)),
          ),
        );
      AppServices.of(context).audio.play('buy.wav');
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

/// The real-money part of the shop: Starter Pack, No Ads, gem packs and
/// "Restore purchases".
class GemStore extends StatelessWidget {
  const GemStore({super.key});

  @override
  Widget build(BuildContext context) {
    final services = AppServices.of(context);
    final progress = services.progress;
    final store = services.purchases;
    return PurchaseMessages(
      child: ListenableBuilder(
        listenable: Listenable.merge([progress, store]),
        builder: (context, _) => ListView(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
          children: [
            if (!store.available)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Panel(
                  padding: const EdgeInsets.all(12),
                  color: const Color(0xFFFFF4C9),
                  child: Text(
                    "The store can't be reached right now. Check your connection and try again later.",
                    textAlign: TextAlign.center,
                    style: body(14, weight: 700),
                  ),
                ),
              ),
            for (final p in [starterPack, removeAds])
              if (!progress.ownsProduct(p))
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _OfferCard(product: p, highlight: p == starterPack),
                ),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.9,
              children: [for (final p in gemPacks) _GemPackCard(product: p)],
            ),
            const SizedBox(height: 16),
            Center(
              child: TextButton(
                onPressed: store.available ? store.restore : null,
                child: Text('Restore purchases', style: body(15, weight: 800, color: AppColors.greyDark)),
              ),
            ),
            if (store.busy)
              const Center(
                child: Padding(padding: EdgeInsets.all(8), child: CircularProgressIndicator()),
              ),
          ],
        ),
      ),
    );
  }
}

/// Buy button with the store's localized price.
class BuyButton extends StatelessWidget {
  const BuyButton({super.key, required this.product, this.fontSize = 20});

  final StoreProduct product;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final services = AppServices.of(context);
    final store = services.purchases;
    return ListenableBuilder(listenable: store, builder: (context, _) => _button(services, store));
  }

  Widget _button(AppServices services, PurchaseService store) {
    final enabled = store.available && !store.busy && services.progress.canBuyProduct(product);
    return ChunkyButton(
      onPressed: enabled
          ? () {
              services.analytics.purchaseStarted(product.id);
              store.buy(product);
            }
          : null,
      label: store.priceOf(product),
      fontSize: fontSize,
      color: AppColors.green,
      shade: AppColors.greenDark,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    );
  }
}

class _OfferCard extends StatelessWidget {
  const _OfferCard({required this.product, this.highlight = false});

  final StoreProduct product;
  final bool highlight;

  @override
  Widget build(BuildContext context) => Panel(
    padding: const EdgeInsets.all(14),
    color: highlight ? const Color(0xFFFFF4C9) : Colors.white,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Icon(
              product.removesAds ? Icons.block_rounded : Icons.card_giftcard_rounded,
              size: 44,
              color: product.removesAds ? AppColors.pink : AppColors.yellowDark,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product.name, style: display(24, color: AppColors.ink, shadow: false)),
                  Text(product.tagline, style: body(13, color: AppColors.greyDark)),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Wrap(
                spacing: 8,
                runSpacing: 4,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  if (product.gems > 0) GemBadge(gems: product.gems),
                  if (product.coins > 0) CoinBadge(coins: product.coins),
                  for (final id in product.items)
                    Text('+ ${cosmeticById(id).name}', style: body(14, weight: 800, color: AppColors.ink)),
                ],
              ),
            ),
            const SizedBox(width: 8),
            BuyButton(product: product, fontSize: 18),
          ],
        ),
      ],
    ),
  );
}

class _GemPackCard extends StatelessWidget {
  const _GemPackCard({required this.product});

  final StoreProduct product;

  @override
  Widget build(BuildContext context) => Panel(
    padding: const EdgeInsets.all(10),
    color: product.bestValue ? const Color(0xFFE1F6FF) : Colors.white,
    child: Column(
      children: [
        if (product.bestValue)
          Text('BEST VALUE', style: display(14, color: AppColors.pink, shadow: false))
        else
          const SizedBox(height: 17),
        Expanded(
          child: FittedBox(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const GemIcon(size: 34),
                Text(' ${product.gems}', style: display(34, color: AppColors.ink, shadow: false)),
              ],
            ),
          ),
        ),
        FittedBox(
          child: Text(product.name, style: display(18, color: AppColors.ink, shadow: false)),
        ),
        Text(product.tagline, maxLines: 1, style: body(11, color: AppColors.greyDark)),
        const SizedBox(height: 6),
        BuyButton(product: product),
      ],
    ),
  );
}

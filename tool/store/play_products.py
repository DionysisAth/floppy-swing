#!/usr/bin/env python3
"""Creates or updates the in-app products on Google Play (new one-time
products API), priced in USD and converted by Google to every country, and
activates them. Safe to re-run after changing a price.

    PLAY_SERVICE_ACCOUNT=key.json python3 tool/store/play_products.py [product_id ...]
"""
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from play_publish import API, PACKAGE, check, session  # noqa: E402

# Mirrors lib/game/store_products.dart.
PRODUCTS = [
    ('gems_small', 'Handful of Gems', '80 gems to spend on revives, skips, cosmetics and the Premium Pass.', '0.99'),
    ('gems_medium', 'Bag of Gems', '450 gems (+12% bonus).', '4.99'),
    ('gems_large', 'Chest of Gems', '1,000 gems (+25% bonus). Best value!', '9.99'),
    ('gems_huge', 'Vault of Gems', '2,200 gems (+37% bonus).', '19.99'),
    ('starter_pack', 'Starter Pack', '300 gems, 2,500 coins and the Laser rope. Once only!', '2.99'),
    ('remove_ads', 'No Ads', 'No more ads between levels. Bonus videos stay optional.', '2.99'),
    ('season_pass', 'Premium Pass', "Unlocks this season's premium reward track.", '4.99'),
]

def money(usd):
    units, cents = usd.split('.')
    return {'currencyCode': 'USD', 'units': units, 'nanos': int(cents.ljust(9, '0'))}

def create(s, pid, title, desc, usd):
    conv = check(s.post(f'{API}/pricing:convertRegionPrices', json={'price': money(usd)}))
    version = conv['regionVersion']['version']
    configs = [{'regionCode': rc, 'price': v['price'], 'availability': 'AVAILABLE'}
               for rc, v in sorted(conv['convertedRegionPrices'].items())]
    other = conv['convertedOtherRegionsPrice']
    body = {
        'packageName': PACKAGE, 'productId': pid,
        'listings': [{'languageCode': 'en-US', 'title': title, 'description': desc}],
        'purchaseOptions': [{
            'purchaseOptionId': 'default',
            'buyOption': {'legacyCompatible': True, 'multiQuantityEnabled': False},
            'regionalPricingAndAvailabilityConfigs': configs,
            'newRegionsConfig': {'usdPrice': other['usdPrice'], 'eurPrice': other['eurPrice'], 'availability': 'AVAILABLE'},
        }],
    }
    r = s.patch(f'{API}/onetimeproducts/{pid}', params={'allowMissing': 'true', 'regionsVersion.version': version,
                                                        'updateMask': 'listings,purchaseOptions'}, json=body)
    if not r.ok:
        return f'{pid}: create failed {r.status_code} {r.text[:600]}'
    a = s.post(f'{API}/oneTimeProducts/{pid}/purchaseOptions:batchUpdateStates', json={'requests': [
        {'activatePurchaseOptionRequest': {'packageName': PACKAGE, 'productId': pid, 'purchaseOptionId': 'default'}}]})
    return f'{pid}: created ${usd}, ' + ('active' if a.ok else f'activate failed {a.status_code} {a.text[:400]}')

if __name__ == '__main__':
    s = session()
    only = sys.argv[1:]
    for p in PRODUCTS:
        if only and p[0] not in only:
            continue
        print(create(s, *p))

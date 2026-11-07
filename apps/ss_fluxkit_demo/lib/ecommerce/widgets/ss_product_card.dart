import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../models/ss_demo_product.dart';
import '../theme/ss_shop_colors.dart';
import 'ss_demo_product_art.dart';

class SSProductCard extends StatelessWidget {
  const SSProductCard({super.key, required this.product});

  final SSDemoProduct product;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push('/product/${product.id}'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AspectRatio(
              aspectRatio: 1,
              child: SSDemoProductArt(
                artKey: product.artKey,
                size: double.infinity,
                borderRadius: 0,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 13, height: 1.25),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SSPriceText(cents: product.priceCents, fontSize: 15),
                      Text(
                        product.soldLabel,
                        style: const TextStyle(
                          fontSize: 11,
                          color: SSShopColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

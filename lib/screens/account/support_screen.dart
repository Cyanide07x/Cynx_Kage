
import 'package:flutter/material.dart';

import '../../widgets/searchbar.dart';
import 'account_action_button.dart';

// Keep FAQ content separate from the UI for easy editing.
class _SupportFaq {
  final String question;
  final String answer;

  const _SupportFaq({
    required this.question,
    required this.answer,
  });
}

const List<_SupportFaq> _supportFaqs = [
  _SupportFaq(
    question: 'Where is my order?',
    answer:
        'Open the Orders section in your account and select your order '
        'to view its latest status and delivery information.',
  ),
  _SupportFaq(
    question: 'How do I return an item?',
    answer:
        'Open your order details and check the item’s return eligibility '
        'for instructions on starting a return.',
  ),
  _SupportFaq(
    question: 'When will I get my refund?',
    answer:
        'Refunds are processed after the return is approved. The time '
        'needed for the amount to appear depends on your payment method.',
  ),
];

class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 25),
            _buildHeader(context),
            const SizedBox(height: 20),

            // The header stays fixed while the content scrolls.
            Expanded(
              child: ScrollConfiguration(
                behavior: ScrollConfiguration.of(context)
                    .copyWith(scrollbars: false),
                child: CustomScrollView(
                  slivers: [
                    _buildIntroduction(context),

                    // Pins the search bar below the fixed header.
                    SliverPersistentHeader(
                      pinned: true,
                      delegate: _SearchBarDelegate(),
                    ),

                    _buildSupportContent(context),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              border: Border.all(color: colors.outlineVariant),
              borderRadius: BorderRadius.circular(10),
            ),
            child: IconButton(
              padding: EdgeInsets.zero,
              onPressed: () => Navigator.of(context).maybePop(),
              icon: Icon(
                Icons.arrow_back,
                color: colors.onSurface,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Help & Support',
                  style: TextStyle(
                    color: colors.onSurface,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "We've got your back.",
                  style: TextStyle(
                    color: colors.onSurfaceVariant,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIntroduction(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      sliver: SliverToBoxAdapter(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'How can we\nhelp you?',
              style: TextStyle(
                color: colors.onSurface,
                fontSize: 28,
                fontWeight: FontWeight.bold,
                height: 1.1,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Find answers or talk to our team.',
              style: TextStyle(
                color: colors.onSurfaceVariant,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSupportContent(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(20, 25, 20, 20),
      sliver: SliverToBoxAdapter(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Browse topics',
              style: TextStyle(
                color: colors.onSurface,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),

            AccountActionButton(
              icon: Icons.inventory_2_outlined,
              title: 'Orders & delivery',
              onTap: () {},
            ),
            const SizedBox(height: 15),

            AccountActionButton(
              icon: Icons.swap_horiz_rounded,
              title: 'Returns & refunds',
              onTap: () {},
            ),
            const SizedBox(height: 15),

            AccountActionButton(
              icon: Icons.credit_card_outlined,
              title: 'Payments',
              onTap: () {},
            ),
            const SizedBox(height: 15),

            AccountActionButton(
              icon: Icons.straighten_rounded,
              title: 'Size & fit',
              onTap: () {},
            ),
            const SizedBox(height: 24),

            Text(
              'Quick answers',
              style: TextStyle(
                color: colors.onSurface,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            // Each FAQ uses its own question and answer.
            ..._supportFaqs.map(
              (faq) => _FaqTile(faq: faq),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

// Reusable FAQ dropdown.
class _FaqTile extends StatelessWidget {
  final _SupportFaq faq;

  const _FaqTile({required this.faq});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
        ),
        child: ExpansionTile(
          collapsedBackgroundColor: colors.surface,
          backgroundColor: colors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          collapsedShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          title: Text(
            faq.question,
            style: TextStyle(
              color: colors.onSurface,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
          trailing: Icon(
            Icons.keyboard_arrow_down,
            color: colors.onSurfaceVariant,
          ),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  faq.answer,
                  style: TextStyle(
                    color: colors.onSurfaceVariant,
                    fontSize: 12,
                    height: 1.5,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Keeps the search bar visible once it reaches the top of the scroll area.
class _SearchBarDelegate extends SliverPersistentHeaderDelegate {
  static const double _height = 62;

  @override
  double get minExtent => _height;

  @override
  double get maxExtent => _height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 8,
      ),
      child: AnimatedSearchBar(
        hint: 'Search for answers',
        height: 46,
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _SearchBarDelegate oldDelegate) => false;
}

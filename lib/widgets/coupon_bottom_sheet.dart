import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CouponBottomSheet extends StatefulWidget {
  final double subtotal;
  final String? currentAppliedCode;
  final ValueChanged<String> onApply;

  const CouponBottomSheet({
    super.key,
    required this.subtotal,
    this.currentAppliedCode,
    required this.onApply,
  });

  @override
  State<CouponBottomSheet> createState() => _CouponBottomSheetState();
}

class _CouponBottomSheetState extends State<CouponBottomSheet> {
  final TextEditingController _manualController = TextEditingController();

  @override
  void dispose() {
    _manualController.dispose();
    super.dispose();
  }

  void _applyCode(String code) {
    final trimmed = code.trim().toUpperCase();
    if (trimmed.isEmpty) return;
    Navigator.of(context).pop();
    widget.onApply(trimmed);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final now = DateTime.now();

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.82,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFF1C1C1E),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(
          top: BorderSide(color: Color(0xFF333338), width: 1.2),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFF4A4A52),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 12),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Icon(Icons.local_offer_outlined, color: colors.primary, size: 22),
                const SizedBox(width: 10),
                Text(
                  'Available Coupons',
                  style: TextStyle(
                    color: colors.onSurface,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: Icon(Icons.close, color: colors.onSurfaceVariant),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
          const Divider(),

          // Manual code entry
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _manualController,
                    textCapitalization: TextCapitalization.characters,
                    decoration: InputDecoration(
                      hintText: 'Enter coupon code',
                      isDense: true,
                      filled: true,
                      fillColor: const Color(0xFF26262B),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xFF383840)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: colors.primary),
                      ),
                    ),
                    onSubmitted: (val) => _applyCode(val),
                  ),
                ),
                const SizedBox(width: 10),
                FilledButton(
                  onPressed: () => _applyCode(_manualController.text),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text('Apply'),
                ),
              ],
            ),
          ),

          // Live coupon list
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('coupons')
                  .where('isActive', isEqualTo: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Unable to load coupons.',
                      style: TextStyle(color: colors.onSurfaceVariant),
                    ),
                  );
                }

                final docs = snapshot.data?.docs ?? [];

                // Filter out expired & exhausted coupons
                final validDocs = docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final expiresAt = data['expiresAt'];
                  if (expiresAt is Timestamp && expiresAt.toDate().isBefore(now)) {
                    return false;
                  }
                  final maxUses = (data['maxUses'] as num?)?.toInt();
                  final usedCount = (data['usedCount'] as num?)?.toInt() ?? 0;
                  if (maxUses != null && usedCount >= maxUses) {
                    return false;
                  }
                  return true;
                }).toList();

                if (validDocs.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        'No coupons available right now.',
                        style: TextStyle(color: colors.onSurfaceVariant),
                      ),
                    ),
                  );
                }

                // Split into applicable vs locked coupons
                final applicable = <Map<String, dynamic>>[];
                final locked = <Map<String, dynamic>>[];

                for (final doc in validDocs) {
                  final data = doc.data() as Map<String, dynamic>;
                  final code = (data['code'] as String? ?? doc.id).toUpperCase();
                  final discountType = data['discountType'] as String? ?? 'percentage';
                  final discountValue =
                      ((data['discountValue'] ?? data['discounValue']) as num?)
                              ?.toDouble() ??
                          0.0;
                  final minSubtotal =
                      (data['minSubtotal'] as num?)?.toDouble() ?? 0.0;
                  final maxDiscount = (data['maxDiscount'] as num?)?.toDouble();
                  final description = (data['description'] as String?)?.trim();

                  // Calculate estimated savings
                  double estimatedSavings = 0.0;
                  if (discountType == 'percentage') {
                    estimatedSavings = (widget.subtotal * discountValue) / 100;
                    if (maxDiscount != null &&
                        maxDiscount > 0 &&
                        estimatedSavings > maxDiscount) {
                      estimatedSavings = maxDiscount;
                    }
                  } else {
                    estimatedSavings = discountValue;
                  }
                  if (estimatedSavings > widget.subtotal) {
                    estimatedSavings = widget.subtotal;
                  }

                  final item = {
                    'code': code,
                    'discountType': discountType,
                    'discountValue': discountValue,
                    'minSubtotal': minSubtotal,
                    'maxDiscount': maxDiscount,
                    'description': description,
                    'savings': estimatedSavings,
                  };

                  if (widget.subtotal >= minSubtotal) {
                    applicable.add(item);
                  } else {
                    locked.add(item);
                  }
                }

                return ListView(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                  children: [
                    // Applicable Section
                    if (applicable.isNotEmpty) ...[
                      _sectionHeader(
                        'APPLICABLE COUPONS (${applicable.length})',
                        colors.primary,
                      ),
                      const SizedBox(height: 8),
                      ...applicable.map((c) => _buildApplicableCard(c, colors)),
                      const SizedBox(height: 16),
                    ],

                    // Locked Section
                    if (locked.isNotEmpty) ...[
                      _sectionHeader(
                        'COUPONS WITH HIGHER CART VALUE',
                        colors.onSurfaceVariant,
                      ),
                      const SizedBox(height: 8),
                      ...locked.map((c) => _buildLockedCard(c, colors)),
                    ],
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title, Color color) {
    return Text(
      title,
      style: TextStyle(
        color: color,
        fontSize: 12,
        fontWeight: FontWeight.w700,
        letterSpacing: 1,
      ),
    );
  }

  Widget _buildApplicableCard(Map<String, dynamic> c, ColorScheme colors) {
    final code = c['code'] as String;
    final isCurrent = widget.currentAppliedCode == code;
    final savings = (c['savings'] as double).round();
    final discountType = c['discountType'] as String;
    final discountValue = (c['discountValue'] as double).round();
    final minSubtotal = (c['minSubtotal'] as double).round();

    final discountTag = discountType == 'percentage'
        ? '$discountValue% OFF'
        : '₹$discountValue OFF';

    String desc = c['description'] as String? ?? '';
    if (desc.isEmpty) {
      desc = minSubtotal > 0
          ? 'On orders above ₹$minSubtotal'
          : 'Valid on all orders';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF26262B),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isCurrent ? colors.primary : const Color(0xFF383840),
          width: isCurrent ? 1.5 : 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: colors.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        code,
                        style: TextStyle(
                          color: colors.primary,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      discountTag,
                      style: TextStyle(
                        color: colors.onSurface,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Save ₹$savings with this code',
                  style: TextStyle(
                    color: colors.primary,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  desc,
                  style: TextStyle(
                    color: colors.onSurfaceVariant,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          if (isCurrent)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: colors.primary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.check, size: 14, color: colors.primary),
                  const SizedBox(width: 4),
                  Text(
                    'APPLIED',
                    style: TextStyle(
                      color: colors.primary,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            )
          else
            OutlinedButton(
              onPressed: () => _applyCode(code),
              style: OutlinedButton.styleFrom(
                foregroundColor: colors.primary,
                side: BorderSide(color: colors.primary),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'APPLY',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLockedCard(Map<String, dynamic> c, ColorScheme colors) {
    final code = c['code'] as String;
    final minSubtotal = (c['minSubtotal'] as double).round();
    final needed = (minSubtotal - widget.subtotal).round();
    final discountType = c['discountType'] as String;
    final discountValue = (c['discountValue'] as double).round();

    final discountTag = discountType == 'percentage'
        ? '$discountValue% OFF'
        : '₹$discountValue OFF';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF202024),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF303036)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.lock_outline, size: 20, color: colors.onSurfaceVariant),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      code,
                      style: TextStyle(
                        color: colors.onSurfaceVariant,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      discountTag,
                      style: TextStyle(
                        color: colors.onSurfaceVariant,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Text(
                  'Add ₹$needed more to unlock this coupon',
                  style: TextStyle(
                    color: Colors.orange.shade700,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Applicable on orders above ₹$minSubtotal',
                  style: TextStyle(
                    color: colors.onSurfaceVariant.withValues(alpha: 0.7),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: colors.surfaceContainerHighest.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              'Min ₹$minSubtotal',
              style: TextStyle(
                color: colors.onSurfaceVariant,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}


import 'package:flutter/material.dart';

class CouponWidget extends StatefulWidget {
  final bool isLoading;
  final String? appliedCode;
  final double? discountAmount;
  final String? message;
  final bool isError;
  final ValueChanged<String> onApply;
  final VoidCallback onRemove;

  const CouponWidget({
    super.key,
    this.isLoading = false,
    this.appliedCode,
    this.discountAmount,
    this.message,
    this.isError = false,
    required this.onApply,
    required this.onRemove,
  });

  @override
  State<CouponWidget> createState() => _CouponWidgetState();
}

class _CouponWidgetState extends State<CouponWidget> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _money(double amount) => '₹${amount.toStringAsFixed(2)}';

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isApplied = widget.appliedCode != null;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.local_offer_outlined, color: colors.primary),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Apply Coupon',
                  style: TextStyle(
                    color: colors.onSurface,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (isApplied)
                Icon(Icons.check_circle, color: colors.primary),
            ],
          ),
          const SizedBox(height: 14),

          if (!isApplied) ...[
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    enabled: !widget.isLoading,
                    textCapitalization: TextCapitalization.characters,
                    autocorrect: false,
                    decoration: InputDecoration(
                      hintText: 'Enter coupon code',
                      isDense: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 14,
                      ),
                    ),
                    onSubmitted: (_) => _submit(),
                  ),
                ),
                const SizedBox(width: 10),
                FilledButton(
                  onPressed: widget.isLoading ? null : _submit,
                  child: widget.isLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : const Text('Apply'),
                ),
              ],
            ),
          ] else ...[
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.appliedCode!,
                        style: TextStyle(
                          color: colors.primary,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'You saved ${_money(widget.discountAmount ?? 0)}',
                        style: TextStyle(
                          color: colors.onSurfaceVariant,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: widget.isLoading ? null : widget.onRemove,
                  child: const Text('Remove'),
                ),
              ],
            ),
          ],

          if (widget.message != null &&
              widget.message!.trim().isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              widget.message!,
              style: TextStyle(
                color: widget.isError
                    ? colors.error
                    : colors.primary,
                fontSize: 13,
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _submit() {
    final code = _controller.text.trim().toUpperCase();

    if (code.isEmpty || widget.isLoading) return;

    widget.onApply(code);
  }
}

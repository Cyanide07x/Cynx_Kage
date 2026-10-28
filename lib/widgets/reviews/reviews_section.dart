import 'package:flutter/material.dart';

import 'review_card.dart';
import 'review_loading_state.dart';
import 'review_model.dart';
import 'review_summary.dart';
import 'write_review_widget.dart';

enum ReviewViewState {
  loaded,
  loading,
  empty,
  error,
}

class ReviewsSection extends StatefulWidget {
  final ProductRatingSummary summary;
  final List<ReviewItem> reviews;

  const ReviewsSection({
    super.key,
    this.summary = ReviewMockData.sampleSummary,
    this.reviews = ReviewMockData.sampleReviews,
  });

  @override
  State<ReviewsSection> createState() => _ReviewsSectionState();
}

class _ReviewsSectionState extends State<ReviewsSection> {
  bool _showWriteReview = false;
  int _selectedFilterIndex = 0;
  ReviewViewState _viewState = ReviewViewState.loaded;

  final List<String> _filters = [
    'All',
    '5 ★',
    '4 ★',
    'Verified',
  ];

  List<ReviewItem> get _filteredReviews {
    switch (_selectedFilterIndex) {
      case 1:
        return widget.reviews.where((r) => r.rating >= 5.0).toList();
      case 2:
        return widget.reviews
            .where((r) => r.rating >= 4.0 && r.rating < 5.0)
            .toList();
      case 3:
        return widget.reviews.where((r) => r.isVerifiedPurchase).toList();
      default:
        return widget.reviews;
    }
  }

  void _showAllReviewsModal() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final colors = Theme.of(context).colorScheme;

        return DraggableScrollableSheet(
          initialChildSize: 0.85,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (context, scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                border: Border.all(color: colors.outlineVariant),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  // Drag handle
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: colors.outlineVariant,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Modal header
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'All Reviews (${widget.summary.totalReviews})',
                          style: TextStyle(
                            color: colors.onSurface,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: Icon(Icons.close, color: colors.onSurface),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  Expanded(
                    child: ListView.builder(
                      controller: scrollController,
                      padding: const EdgeInsets.all(20),
                      itemCount: widget.reviews.length,
                      itemBuilder: (context, index) {
                        return ReviewCard(review: widget.reviews[index]);
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header Row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'CUSTOMER REVIEWS',
                  style: TextStyle(
                    color: colors.onSurface,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Real feedback from verified buyers',
                  style: TextStyle(
                    color: colors.onSurfaceVariant,
                    fontSize: 12,
                  ),
                ),
              ],
            ),

            // Write review button
            OutlinedButton.icon(
              onPressed: () {
                setState(() {
                  _showWriteReview = !_showWriteReview;
                });
              },
              icon: Icon(
                _showWriteReview ? Icons.close : Icons.rate_review_outlined,
                size: 14,
                color: colors.primary,
              ),
              label: Text(
                _showWriteReview ? 'Close' : 'Write Review',
                style: TextStyle(
                  color: colors.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: colors.primary.withValues(alpha: 0.5)),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Rating Summary Widget
        ReviewSummary(summary: widget.summary),

        const SizedBox(height: 16),

        // Inline Write Review Form (when opened)
        if (_showWriteReview) ...[
          WriteReviewWidget(
            onCancel: () {
              setState(() {
                _showWriteReview = false;
              });
            },
            onReviewSubmitted: () {
              // Local preview: can close form after brief delay
            },
          ),
          const SizedBox(height: 20),
        ],

        // Filter chips row
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: List.generate(_filters.length, (index) {
              final isSelected = _selectedFilterIndex == index;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(_filters[index]),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _selectedFilterIndex = index;
                      });
                    }
                  },
                  labelStyle: TextStyle(
                    color: isSelected ? colors.onPrimary : colors.onSurface,
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                  selectedColor: colors.primary,
                  backgroundColor: colors.surface,
                  side: BorderSide(
                    color: isSelected ? colors.primary : colors.outlineVariant,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                ),
              );
            }),
          ),
        ),

        const SizedBox(height: 16),

        // Main Review Content according to _viewState
        _buildContentForState(colors),

        const SizedBox(height: 12),

        // "See All Reviews" button (when loaded)
        if (_viewState == ReviewViewState.loaded && widget.reviews.isNotEmpty)
          SizedBox(
            width: double.infinity,
            height: 44,
            child: OutlinedButton(
              onPressed: _showAllReviewsModal,
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: colors.outlineVariant),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                'See All ${widget.summary.totalReviews} Reviews',
                style: TextStyle(
                  color: colors.onSurface,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),

        const SizedBox(height: 16),

        // UI State Preview Bar (Allows user to inspect Loaded, Loading, Empty, Error states)
        _buildStatePreviewBar(colors),
      ],
    );
  }

  Widget _buildContentForState(ColorScheme colors) {
    switch (_viewState) {
      case ReviewViewState.loading:
        return const ReviewLoadingSkeleton();

      case ReviewViewState.empty:
        return ReviewEmptyState(
          onWriteReview: () {
            setState(() {
              _viewState = ReviewViewState.loaded;
              _showWriteReview = true;
            });
          },
        );

      case ReviewViewState.error:
        return ReviewErrorState(
          onRetry: () {
            setState(() {
              _viewState = ReviewViewState.loaded;
            });
          },
        );

      case ReviewViewState.loaded:
        final list = _filteredReviews;
        if (list.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Text(
                'No reviews match this filter.',
                style: TextStyle(color: colors.onSurfaceVariant, fontSize: 13),
              ),
            ),
          );
        }
        return Column(
          children: list.map((review) => ReviewCard(review: review)).toList(),
        );
    }
  }

  /// Small developer preview control to easily preview all 4 states
  Widget _buildStatePreviewBar(ColorScheme colors) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: colors.surface.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          Icon(Icons.tune_rounded, size: 14, color: colors.onSurfaceVariant),
          const SizedBox(width: 8),
          Text(
            'UI State:',
            style: TextStyle(color: colors.onSurfaceVariant, fontSize: 11),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: ReviewViewState.values.map((state) {
                  final isCurrent = _viewState == state;
                  return Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          _viewState = state;
                        });
                      },
                      borderRadius: BorderRadius.circular(4),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: isCurrent
                              ? colors.primary.withValues(alpha: 0.2)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: isCurrent
                                ? colors.primary
                                : colors.outlineVariant.withValues(alpha: 0.3),
                            width: 0.8,
                          ),
                        ),
                        child: Text(
                          state.name.toUpperCase(),
                          style: TextStyle(
                            color: isCurrent ? colors.primary : colors.onSurfaceVariant,
                            fontSize: 10,
                            fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

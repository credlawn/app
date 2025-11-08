import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class SkeletonLoadingWidget extends StatelessWidget {
  const SkeletonLoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Summary Cards Skeleton
            _buildSummaryCardsSkeleton(),
            const SizedBox(height: 24),

            // Call Summary Skeleton
            _buildCallSummarySkeleton(),
            const SizedBox(height: 24),

            // Status Chart Skeleton
            _buildStatusChartSkeleton(),
            const SizedBox(height: 24),

            // Performance Trends Skeleton
            _buildPerformanceTrendsSkeleton(),
            const SizedBox(height: 24),

            // Conversion Funnel Skeleton
            _buildConversionFunnelSkeleton(),
            const SizedBox(height: 24),

            // Recent Leads Skeleton
            _buildRecentLeadsSkeleton(),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCardsSkeleton() {
    return Row(
      children: [
        Expanded(child: _buildCardSkeleton()),
        const SizedBox(width: 16),
        Expanded(child: _buildCardSkeleton()),
      ],
    );
  }

  Widget _buildCardSkeleton() {
    return Container(
      height: 100,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 80,
            height: 12,
            color: Colors.white,
          ),
          const SizedBox(height: 8),
          Container(
            width: 40,
            height: 24,
            color: Colors.white,
          ),
          const Spacer(),
          Container(
            width: 60,
            height: 16,
            color: Colors.white,
          ),
        ],
      ),
    );
  }

  Widget _buildCallSummarySkeleton() {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 180,
            height: 18,
            color: Colors.white,
          ),
          const SizedBox(height: 20),
          ...List.generate(5, (index) => Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Container(
                    height: 14,
                    color: Colors.white,
                  ),
                ),
                Container(
                  width: 60,
                  height: 16,
                  color: Colors.white,
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildStatusChartSkeleton() {
    return Container(
      height: 350,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 140,
            height: 18,
            color: Colors.white,
          ),
          const SizedBox(height: 20),
          Expanded(
            child: Container(
              color: Colors.white,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: 120,
                    height: 14,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: 100,
                    height: 12,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(3, (index) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Container(
                    width: 60,
                    height: 12,
                    color: Colors.white,
                  ),
                ],
              ),
            )),
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceTrendsSkeleton() {
    return Container(
      height: 300,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 160,
            height: 18,
            color: Colors.white,
          ),
          const SizedBox(height: 20),
          Expanded(
            child: Container(
              color: Colors.white,
              child: Column(
                children: [
                  // Chart area
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 20),
                      color: Colors.white,
                    ),
                  ),
                  // Legend
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(3, (index) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Container(
                        width: 80,
                        height: 12,
                        color: Colors.white,
                      ),
                    )),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConversionFunnelSkeleton() {
    return Container(
      height: 280,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 140,
            height: 18,
            color: Colors.white,
          ),
          const SizedBox(height: 20),
          ...List.generate(5, (index) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Container(
                    height: 14,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 4,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      height: 32,
                      width: 200 * (1 - index * 0.15), // Decreasing width
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildRecentLeadsSkeleton() {
    return Container(
      height: 300,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 120,
            height: 18,
            color: Colors.white,
          ),
          const SizedBox(height: 16),
          ...List.generate(6, (index) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 120,
                        height: 14,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 4),
                      Container(
                        width: 80,
                        height: 12,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 60,
                  height: 14,
                  color: Colors.white,
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }
}

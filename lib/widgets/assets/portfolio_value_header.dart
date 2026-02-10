import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:investy/utils/app_colors.dart';
import 'package:investy/utils/format_utils.dart';
import 'package:investy/widgets/assets/percentage_badge.dart';
import 'package:investy/datamodel/portfolio_value_snapshot_model.dart';

class PortfolioValueHeader extends StatelessWidget {
  final String portfolioValue;
  final double percentageChange;
  final List<PortfolioValueSnapshot>? valueHistory;

  const PortfolioValueHeader({
    super.key,
    required this.portfolioValue,
    required this.percentageChange,
    this.valueHistory,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Portfolio value',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textGrey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  portfolioValue,
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Text(
                  '24hr:',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textGrey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 6),
                PercentageBadge(percentage: percentageChange),
              ],
            ),
          ],
        ),
        const SizedBox(height: 24),
        // Chart
        Container(
          width: double.infinity,
          height: 200,
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: _buildChart(),
        ),
      ],
    );
  }

  Widget _buildChart() {
    if (valueHistory == null || valueHistory!.isEmpty) {
      // Show placeholder if no data
      return Center(
        child: Text(
          'No chart data available',
          style: TextStyle(
            fontSize: 14,
            color: AppColors.textGrey,
          ),
        ),
      );
    }

    // Sort by timestamp (oldest first)
    final sortedData = List<PortfolioValueSnapshot>.from(valueHistory!)
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

    // Prepare chart data
    List<FlSpot> spots;
    
    // Handle single data point case - duplicate it to create a visible line
    if (sortedData.length == 1) {
      final singleValue = sortedData.first.totalValue;
      spots = [
        FlSpot(0.0, singleValue),
        FlSpot(1.0, singleValue), // Duplicate point to create a visible line
      ];
    } else {
      spots = sortedData.asMap().entries.map((entry) {
        return FlSpot(entry.key.toDouble(), entry.value.totalValue);
      }).toList();
    }

    // Calculate min and max values for y-axis
    final values = sortedData.map((s) => s.totalValue).toList();
    final rawMinValue = values.reduce((a, b) => a < b ? a : b);
    final rawMaxValue = values.reduce((a, b) => a > b ? a : b);
    final range = rawMaxValue - rawMinValue;
    
    // Handle edge case: all values are the same (range is 0 or very small)
    double minValue;
    double maxValue;
    double niceInterval;
    double padding;
    
    if (range == 0 || range.isNaN || range.isInfinite || range < 0.01) {
      // Use a small padding around the single value
      final centerValue = rawMinValue;
      padding = centerValue == 0 ? 100.0 : (centerValue * 0.1).abs();
      minValue = centerValue - padding;
      maxValue = centerValue + padding;
      niceInterval = padding / 2;
    } else {
      padding = range * 0.1; // 10% padding
    
    // Calculate nice round numbers for y-axis
    double _niceNumber(double value, bool round) {
      if (value == 0 || value.isNaN || value.isInfinite) return 1.0;
      final expString = value.abs().toStringAsExponential().split('e')[1];
      final log10 = int.parse(expString);
      final magnitude = math.pow(10, log10).toDouble();
      final normalized = value / magnitude;
      
      double niceFraction;
      if (round) {
        if (normalized <= 1.5) {
          niceFraction = 1.0;
        } else if (normalized <= 3) {
          niceFraction = 2.0;
        } else if (normalized <= 7) {
          niceFraction = 5.0;
        } else {
          niceFraction = 10.0;
        }
      } else {
        if (normalized <= 1) {
          niceFraction = 1.0;
        } else if (normalized <= 2) {
          niceFraction = 2.0;
        } else if (normalized <= 5) {
          niceFraction = 5.0;
        } else {
          niceFraction = 10.0;
        }
      }
      return niceFraction * magnitude;
    }
    
    // Calculate nice interval to get maximum 5 labels
    // Start with range/4 to get 5 labels (min, max, and 3 in between)
    niceInterval = _niceNumber(range / 4, true);
    
    // Validate niceInterval before using it
    if (niceInterval == 0 || niceInterval.isNaN || niceInterval.isInfinite) {
      niceInterval = _niceNumber(range / 4, false);
      if (niceInterval == 0 || niceInterval.isNaN || niceInterval.isInfinite) {
        // Fallback to a simple fraction of the range
        niceInterval = range / 4;
        if (niceInterval == 0 || niceInterval.isNaN || niceInterval.isInfinite) {
          niceInterval = 1.0; // Ultimate fallback
        }
      }
    }
    
    // Ensure we don't get more than 5 labels by checking the count
    double divisionResult = (rawMaxValue - rawMinValue) / niceInterval;
    if (divisionResult.isNaN || divisionResult.isInfinite) {
      // Fallback to simple calculation
      niceInterval = range / 4;
      if (niceInterval == 0 || niceInterval.isNaN || niceInterval.isInfinite) {
        niceInterval = 1.0;
      }
      // Recalculate divisionResult with the fixed niceInterval
      divisionResult = (rawMaxValue - rawMinValue) / niceInterval;
      // Final safety check
      if (divisionResult.isNaN || divisionResult.isInfinite) {
        divisionResult = 1.0; // Ultimate fallback
      }
    }
    
    int labelCount = divisionResult.ceil() + 1;
    
    // If we have more than 5 labels, increase the interval
    if (labelCount > 5) {
      final newInterval = _niceNumber(range / (labelCount - 1), true);
      if (newInterval != 0 && !newInterval.isNaN && !newInterval.isInfinite) {
        niceInterval = newInterval;
      }
      // Recalculate to ensure we're still within 5
      final newDivisionResult = (rawMaxValue - rawMinValue) / niceInterval;
      if (!newDivisionResult.isNaN && !newDivisionResult.isInfinite) {
        labelCount = newDivisionResult.ceil() + 1;
      }
      if (labelCount > 5) {
        // Force to exactly 4 intervals (5 labels)
        final forcedInterval = _niceNumber(range / 4, false);
        if (forcedInterval != 0 && !forcedInterval.isNaN && !forcedInterval.isInfinite) {
          niceInterval = forcedInterval;
        }
      }
    }
    
    // Round min and max to nice intervals
    minValue = (rawMinValue / niceInterval).floor() * niceInterval;
    maxValue = ((rawMaxValue / niceInterval).ceil() * niceInterval);
    }

    // Format x-axis labels (month abbreviations)
    // Show only a few labels to keep it minimalistic
    final monthLabels = <String>[];
    
    // Handle single data point case
    if (sortedData.length == 1) {
      final month = sortedData.first.timestamp.month;
      final monthNames = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 
                         'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      monthLabels.add(monthNames[month - 1]);
      monthLabels.add(''); // Empty label for the duplicate point
    } else {
      final labelInterval = (sortedData.length / 5).ceil();
      for (int i = 0; i < sortedData.length; i++) {
        if (i % labelInterval == 0 || i == sortedData.length - 1) {
          final month = sortedData[i].timestamp.month;
          final monthNames = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 
                             'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
          monthLabels.add(monthNames[month - 1]);
        } else {
          monthLabels.add('');
        }
      }
    }

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: false,
        ),
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (touchedSpot) => Colors.white,
            tooltipRoundedRadius: 8,
            tooltipPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            tooltipBorder: BorderSide(
              color: Colors.grey[300]!,
              width: 1,
            ),
            tooltipMargin: 8,
            fitInsideHorizontally: true,
            fitInsideVertically: true,
            getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
              return touchedBarSpots.map((barSpot) {
                final value = barSpot.y;
                return LineTooltipItem(
                  FormatUtils.formatCurrency(value),
                  TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                );
              }).toList();
            },
          ),
          handleBuiltInTouches: true,
          touchSpotThreshold: 20,
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index >= 0 && index < monthLabels.length && monthLabels[index].isNotEmpty) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      monthLabels[index],
                      style: TextStyle(
                        fontSize: 10,
                        color: AppColors.textGrey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                }
                return const Text('');
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: niceInterval,
              getTitlesWidget: (value, meta) {
                // Hide bottom (min) and top (max) values
                if ((value - minValue).abs() < 0.01 || (value - maxValue).abs() < 0.01) {
                  return const Text('');
                }
                
                // Format value nicely
                String displayValue;
                if (value >= 1000000) {
                  displayValue = '${(value / 1000000).toStringAsFixed(1)}M';
                } else if (value >= 1000) {
                  displayValue = '${(value / 1000).toStringAsFixed(0)}k';
                } else {
                  displayValue = value.toStringAsFixed(0);
                }
                return Text(
                  displayValue,
                  style: TextStyle(
                    fontSize: 10,
                    color: AppColors.textGrey,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.right,
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(
          show: false,
        ),
        minX: 0,
        maxX: sortedData.length == 1 ? 1.0 : (spots.length - 1).toDouble(),
        minY: minValue - padding,
        maxY: maxValue + padding,
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: sortedData.length > 2, // Only curve if we have more than 2 points
            color: AppColors.primary,
            barWidth: 2,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: sortedData.length == 1, // Show dot for single data point
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 4,
                  color: AppColors.primary,
                  strokeWidth: 2,
                  strokeColor: Colors.white,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              color: AppColors.primary.withValues(alpha: 0.1),
            ),
          ),
        ],
      ),
    );
  }
}

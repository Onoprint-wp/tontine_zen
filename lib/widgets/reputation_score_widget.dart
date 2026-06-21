import 'package:flutter/material.dart';
import '../utils/constants.dart';

class ReputationScoreWidget extends StatelessWidget {
  final int score;
  final double size;

  const ReputationScoreWidget({
    super.key,
    required this.score,
    this.size = 100.0,
  });

  Color _getScoreColor(int s) {
    if (s < 50) return AppConstants.alertColor;
    if (s < 80) return AppConstants.scoreColor;
    return AppConstants.primaryColor;
  }

  String _getScoreStatus(int s) {
    if (s < 50) return 'Risqué';
    if (s < 80) return 'Moyen';
    return 'Excellent';
  }

  @override
  Widget build(BuildContext context) {
    final color = _getScoreColor(score);
    final status = _getScoreStatus(score);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: size,
              height: size,
              child: CircularProgressIndicator(
                value: score / 100,
                strokeWidth: size * 0.08,
                backgroundColor: AppConstants.backgroundColor,
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$score',
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(
                        color: AppConstants.textPrimaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: size * 0.3,
                      ),
                ),
                Text(
                  '/100',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontSize: size * 0.12,
                        color: AppConstants.textSecondaryColor,
                      ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(100),
            border: Border.all(color: color.withOpacity(0.5), width: 1),
          ),
          child: Text(
            status,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
          ),
        ),
      ],
    );
  }
}

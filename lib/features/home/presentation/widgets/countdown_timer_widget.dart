// import 'dart:async';
// import 'package:flutter/material.dart';
// import '../../../../../core/theme/app_colors.dart';
// import '../../../../../core/theme/app_text_styles.dart';

// class CountdownTimerWidget extends StatefulWidget {
//   const CountdownTimerWidget({super.key});

//   @override
//   State<CountdownTimerWidget> createState() => _CountdownTimerWidgetState();
// }

// class _CountdownTimerWidgetState extends State<CountdownTimerWidget> {
//   late Timer _timer;
//   Duration _timeLeft = Duration.zero;
//   final DateTime _targetDate = DateTime(2026, 4, 10);

//   @override
//   void initState() {
//     super.initState();
//     _calculateTimeLeft();
//     _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
//       _calculateTimeLeft();
//     });
//   }

//   void _calculateTimeLeft() {
//     final now = DateTime.now();
//     final difference = _targetDate.difference(now);

//     if (difference.isNegative) {
//       _timeLeft = Duration.zero;
//       _timer.cancel();
//     } else {
//       if (mounted) {
//         setState(() {
//           _timeLeft = difference;
//         });
//       }
//     }
//   }

//   @override
//   void dispose() {
//     _timer.cancel();
//     super.dispose();
//   }

//   String _formatTime(int time) {
//     return time.toString().padLeft(2, '0');
//   }

//   @override
//   Widget build(BuildContext context) {

//     // We want breakdown: Days, Hours, Minutes, Seconds
//     // days = floor(diff / (1000 * 60 * 60 * 24))
//     // hours = floor((diff / (1000 * 60 * 60)) % 24)
//     // minutes = floor((diff / 1000 / 60) % 60)
//     // seconds = floor((diff / 1000) % 60)

//     final days = _timeLeft.inDays;
//     final hours = _timeLeft.inHours % 24;
//     final minutes = _timeLeft.inMinutes % 60;
//     final seconds = _timeLeft.inSeconds % 60;

//     return Container(
//       padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           _buildTimeItem(days, 'DAYS'),
//           _buildSeparator(),
//           _buildTimeItem(hours, 'HRS'),
//           _buildSeparator(),
//           _buildTimeItem(minutes, 'MINS'),
//           _buildSeparator(),
//           _buildTimeItem(seconds, 'SECS'),
//         ],
//       ),
//     );
//   }

//   Widget _buildTimeItem(int value, String label) {
//     return Column(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         Text(
//           _formatTime(value),
//           style: AppTextStyles.headlineMedium.copyWith(
//             color: Colors.white,
//             fontWeight: FontWeight.bold,
//             letterSpacing: 1.5,
//           ),
//         ),
//         const SizedBox(height: 4),
//         Text(
//           label,
//           style: AppTextStyles.labelSmall.copyWith(
//             color: AppColors.textSecondary,
//             letterSpacing: 1.2,
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildSeparator() {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 8),
//       height: 40,
//       alignment: Alignment.topCenter,
//       child: Text(
//         ':',
//         style: AppTextStyles.headlineMedium.copyWith(
//           color: Colors.white,
//           fontWeight: FontWeight.bold,
//         ),
//       ),
//     );
//   }
// }

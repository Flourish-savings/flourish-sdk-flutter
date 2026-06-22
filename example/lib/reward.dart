import 'package:flourish_flutter_sdk/flourish.dart';
import 'package:flutter/material.dart';

class RewardsScreen extends StatelessWidget {
  final Flourish flourish;

  /// Optional deep-link target. When provided, the Flourish module opens
  /// directly on this page (e.g. a specific partner store) instead of the
  /// default entry point.
  final String? redirectTo;
  final String? resourceId;

  const RewardsScreen({
    super.key,
    required this.flourish,
    this.redirectTo,
    this.resourceId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffFFFFFF),
      body: Center(
        child: flourish.home(
          redirectTo: redirectTo,
          resourceId: resourceId,
        ),
      ),
    );
  }
}

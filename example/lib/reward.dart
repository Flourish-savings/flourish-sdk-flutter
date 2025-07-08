import 'package:flourish_flutter_sdk/flourish.dart';
import 'package:flutter/material.dart';

class RewardsScreen extends StatelessWidget {
  final Flourish flourish;

  const RewardsScreen({
    super.key,
    required this.flourish,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffFFFFFF),
      body: Center(
        child: flourish.home(),
      ),
    );
  }
}

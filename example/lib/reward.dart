import 'package:flourish_flutter_sdk/flourish.dart';
import 'package:flutter/material.dart';

class RewardsScreen extends StatefulWidget {
  final Flourish flourish;

  const RewardsScreen({Key? key, required this.flourish}) : super(key: key);

  @override
  State<RewardsScreen> createState() => _RewardsScreenState();
}

class _RewardsScreenState extends State<RewardsScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffFFFFFF),
      body: Center(
        child: widget.flourish.home(),
      ),
    );
  }
}

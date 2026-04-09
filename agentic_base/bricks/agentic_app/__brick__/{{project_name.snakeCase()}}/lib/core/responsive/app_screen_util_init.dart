import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Wraps the app with ScreenUtilInit using a 375x812 (iPhone 13 mini) design
/// canvas. All sp/dp/r values in the app scale relative to this baseline.
class AppScreenUtilInit extends StatelessWidget {
  const AppScreenUtilInit({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      builder: (context, _) => child,
    );
  }
}

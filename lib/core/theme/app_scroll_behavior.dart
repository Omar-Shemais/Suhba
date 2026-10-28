import 'dart:ui';
import 'package:flutter/material.dart';

/// فيزياء تمرير انسيابية عالية المرونة مع محاكاة زنبركية طبيعية فاخرة (Smooth Spring Dynamics)
class SmoothBouncingScrollPhysics extends BouncingScrollPhysics {
  const SmoothBouncingScrollPhysics({
    super.parent,
    super.decelerationRate = ScrollDecelerationRate.normal,
  });

  @override
  SmoothBouncingScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return SmoothBouncingScrollPhysics(
      parent: buildParent(ancestor),
      decelerationRate: decelerationRate,
    );
  }

  @override
  SpringDescription get spring => SpringDescription.withDampingRatio(
    mass: 0.5,
    stiffness: 110.0,
    ratio: 0.96, // ارتداد زنبركي انسيابي وممتع بدون تذبذب مزعج وبدون جمود
  );

  @override
  double frictionFactor(double overscrollFraction) {
    // مقاومة سحب مرنة وسلسة تمنح إحساساً انسيابياً رائعاً عند التمرير والارتداد
    return 0.55 * (1 - overscrollFraction) * (1 - overscrollFraction);
  }
}

/// سلوك تمرير عام للتطبيق يوفر فيزياء ارتدادية فاخرة ويزيل التشوهات الافتراضية
class AppScrollBehavior extends MaterialScrollBehavior {
  const AppScrollBehavior();

  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
    PointerDeviceKind.trackpad,
    PointerDeviceKind.stylus,
  };

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    return const SmoothBouncingScrollPhysics(
      parent: AlwaysScrollableScrollPhysics(),
    );
  }

  @override
  Widget buildOverscrollIndicator(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    // إزالة توهج أندرويد الحاد وتشوهات التمطيط القاسية
    // لتمكين الارتداد الزنبركي السلس الطبيعي (Bouncing Physics)
    return child;
  }
}
